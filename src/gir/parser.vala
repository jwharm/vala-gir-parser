/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

using Gir.Xml;

public class Gir.Parser : Object {
    /* These boolean attributes are default true, others are default false */
    public const string[] DEFAULT_TRUE_ATTRIBUTES = {
        "caller-allocates",
        "introspectable",
        "readable",
        "zero-terminated"
    };

    public Gir.Context context { get; set; }

    /**
     * Get a list that only contains nodes with the specified type
     */
    private static Gee.List<T> get_nodes<T> (Gee.ArrayList<Node> list) {
        var result = new Gee.ArrayList<T> ();
        var type = typeof (T);
        foreach (var node in list) {
            if (node.get_type ().is_a (type)) {
                result.add (node);
            }
        }
        return result;
    }

    /**
     * Get the first child node with the specified type, or `null` if not found
     */
    private static T? get_node<T> (Gee.ArrayList<Node> children) {
        var type = typeof (T);
        foreach (var child in children) {
            if (child.get_type ().is_a (type)) {
                return child;
            }
        }

        return null;
    }

    /**
     * Get the boolean value of this key ("1" is true, "0" is false)
     */
    private static bool get_bool (Gee.Map<string, string> attrs, string key) {
        return attrs.has_key (key) ? ("1" == attrs[key]) : (key in DEFAULT_TRUE_ATTRIBUTES);
    }

    /**
     * Get the int value of this key
     */
    private static int get_int (Gee.Map<string, string> attrs, string key, int if_not_set = -1) {
        return attrs.has_key (key) ? (int.parse (attrs[key])) : if_not_set;
    }
    
    /**
     * Get the string value of this key
     */
    private static string? get_string (Gee.Map<string, string> attrs, string key, string? if_not_set = null) {
        return attrs.has_key (key) ? (attrs[key]) : if_not_set;
    }

    /**
     * Create a Gir Parser for the provided Gir Context.
     */
    public Parser (Gir.Context context) {
        this.context = context;
    }

    /**
     * Parse enqueued Gir repositories and add the Gir nodes to the Gir Context.
     */
    public void parse () {
        foreach (var name_and_version in context.parser_queue) {
            context.add_repository (name_and_version, parse_repository (name_and_version));
        }
    }

    /**
     * Parse the requested repository from a Gir file into a tree of Gir nodes.
     *
     * @return the Repository, or null in case the gir file is invalid
     */
    public Repository? parse_repository (string name_and_version) {
        /* Find the gir file in one of the gir directories */
        string gir_filename = null;
        foreach (string dir in context.gir_directories) {
            if (FileUtils.test (dir, IS_DIR)) {
                string path = Path.build_filename (dir, name_and_version + ".gir", null);
                if (FileUtils.test (path, EXISTS)) {
                    gir_filename = path;
                    break;
                }
            }
        }

        /* If the gir file is not found anywhere, return null */
        if (gir_filename == null) {
            context.report.error (null, "No gir file found for %s", name_and_version);
            return null;
        }

        /* Parse the gir file */
        return parse_source_file (gir_filename);
    }

    public Repository? parse_source_file (string filename) {
        SourceLocation begin;
        SourceLocation end;
        var reader = new Gir.Xml.Reader (context, filename);
        
        /* Find the first START_ELEMENT token in the XML file */
        while (true) {
            var token_type = reader.read_token (out begin, out end);
            if (token_type == START_ELEMENT) {
                return parse_element (reader, new Reference (filename, begin, end)) as Repository;
            } else if (token_type == EOF) {
                var source = new Reference (filename, begin, end);
                context.report.error (source, "No repository found");
                return null;
            }
        }
    }

    /* Parse one XML element (recursively), and return a new Gir Node */
    private Node? parse_element (Gir.Xml.Reader reader, Reference source) {
        SourceLocation begin;
        SourceLocation end;
        var element = reader.name;
        var children = new Gee.ArrayList<Node> ();
        var attrs = reader.get_attributes ();
        var content = new StringBuilder ();

        /* Keep parsing XML until an END_ELEMENT or EOF token is reached */
        while (true) {
            var token = reader.read_token (out begin, out end);
            if (token == XmlTokenType.START_ELEMENT) {
                /* Recursively create a child node and add it to the list */
                Node? node = parse_element (reader, new Reference (source.filename, begin, end));
                if (node != null) {
                    children.add (node);
                }
            } else if (token == XmlTokenType.TEXT) {
                content.append (reader.content);
            } else {
                break;
            }
        }
        
        Node? new_node = null;
        switch (element) {
        case "alias":
            new_node = new Alias (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                parse_info_elements (children),
                get_node <AnyType> (children),
                source);
            break;
        case "array":
            new_node = new Array (
                get_string (attrs, "name"),
                get_bool (attrs, "zero-terminated"),
                get_int (attrs, "fixed-size"),
                get_bool (attrs, "introspectable"),
                get_string (attrs, "length"),
                get_string (attrs, "c:type"),
                get_node <AnyType> (children),
                source);
            break;
        case "attribute":
            new_node = new Attribute (
                get_string (attrs, "name"),
                get_string (attrs, "value"),
                source);
            break;
        case "bitfield":
            new_node = new Bitfield (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                parse_info_elements (children),
                get_nodes <Member> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                source);
            break;
        case "c:include":
            new_node = new CInclude (get_string (attrs, "name"), source);
            break;
        case "callback":
            new_node = new Callback (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_bool (attrs, "throws"),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "class":
            new_node = new Class (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "parent"),
                get_string (attrs, "glib:type-struct"),
                get_string (attrs, "glib:ref-func"),
                get_string (attrs, "glib:unref-func"),
                get_string (attrs, "glib:set-value-func"),
                get_string (attrs, "glib:get-value-func"),
                get_string (attrs, "c:type"),
                get_string (attrs, "c:symbol-prefix"),
                get_bool (attrs, "abstract"),
                get_bool (attrs, "glib:fundamental"),
                get_bool (attrs, "final"),
                parse_info_elements (children),
                get_nodes <Implements> (children),
                get_nodes <Constructor> (children),
                get_nodes <Method> (children),
                get_nodes <MethodInline> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                get_nodes <VirtualMethod> (children),
                get_nodes <Field> (children),
                get_nodes <Property> (children),
                get_nodes <Signal> (children),
                get_nodes <Union> (children),
                get_nodes <Constant> (children),
                get_nodes <Record> (children),
                get_nodes <Callback> (children),
                source);
            break;
        case "constant":
            new_node = new Constant (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "value"),
                get_string (attrs, "c:type"),
                get_string (attrs, "c:identifier"),
                parse_info_elements (children),
                get_node <AnyType> (children),
                source);
            break;
        case "constructor":
            new_node = new Constructor (
                parse_callable_attrs (attrs),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "doc-deprecated":
            new_node = new DocDeprecated (content.str.strip (), source);
            break;
        case "doc-format":
            new_node = new DocFormat (get_string (attrs, "name"), source);
            break;
        case "doc-stability":
            new_node = new DocStability (content.str.strip (), source);
            break;
        case "doc-version":
            new_node = new DocVersion (content.str.strip (), source);
            break;
        case "doc":
            new_node = new Doc (
                get_string (attrs, "filename"),
                get_string (attrs, "line"),
                get_string (attrs, "column"),
                content.str.strip (),
                source);
            break;
        case "docsection":
            new_node = new Docsection (
                get_string (attrs, "name"),
                parse_doc_elements (children),
                source);
            break;
        case "enumeration":
            new_node = new Enumeration (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "glib:error-domain"),
                parse_info_elements (children),
                get_nodes <Member> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                source);
            break;
        case "field":
            new_node = new Field (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_bool (attrs, "writable"),
                get_bool (attrs, "readable"),
                get_bool (attrs, "private"),
                get_int (attrs, "bits"),
                parse_info_elements (children),
                get_node <Callback> (children),
                get_node <AnyType> (children),
                source);
            break;
        case "function-inline":
            new_node = new FunctionInline (
                parse_callable_attrs (attrs),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                parse_doc_elements (children),
                source);
            break;
        case "function-macro":
            new_node = new FunctionMacro (
                parse_callable_attrs (attrs),
                parse_info_elements (children),
                get_node <Parameters> (children),
                source);
            break;
        case "function":
            new_node = new Function (
                parse_callable_attrs (attrs),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "glib:boxed":
            new_node = new Boxed (
                get_string (attrs, "glib:name"),
                parse_info_attrs (attrs),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                parse_info_elements (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                source);
            break;
        case "glib:signal":
            new_node = new Signal (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_bool (attrs, "detailed"),
                When.from_string (get_string (attrs, "when")),
                get_bool (attrs, "action"),
                get_bool (attrs, "no-hooks"),
                get_bool (attrs, "no-recurse"),
                get_string (attrs, "emitter"),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "implements":
            new_node = new Implements (get_string (attrs, "name"), source);
            break;
        case "include":
            /* Recursively parse the included repository */
            string name = get_string (attrs, "name");
            string version = get_string (attrs, "version");
            string name_and_version = name + "-" + version;
            if (! context.contains_repository (name_and_version)) {
                context.add_repository (name_and_version, parse_repository (name_and_version));
            }
            
            new_node = new Include (name, version, source);
            break;
        case "instance-parameter":
            new_node = new InstanceParameter (
                get_string (attrs, "name"),
                get_bool (attrs, "nullable"),
                get_bool (attrs, "allow-none"),
                Direction.from_string (get_string (attrs, "direction")),
                get_bool (attrs, "caller-allocates"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                parse_doc_elements (children),
                get_node <TypeRef> (children),
                source);
            break;
        case "interface":
            new_node = new Interface (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-struct"),
                parse_info_elements (children),
                get_nodes <Prerequisite> (children),
                get_nodes <Implements> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                get_node <Constructor> (children),
                get_nodes <Method> (children),
                get_nodes <MethodInline> (children),
                get_nodes <VirtualMethod> (children),
                get_nodes <Field> (children),
                get_nodes <Property> (children),
                get_nodes <Signal> (children),
                get_nodes <Callback> (children),
                get_nodes <Constant> (children),
                source);
            break;
        case "member":
            new_node = new Member (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "value"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "glib:nick"),
                get_string (attrs, "glib:name"),
                parse_info_elements (children),
                source);
            break;
        case "method-inline":
            new_node = new MethodInline (
                parse_callable_attrs (attrs),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "method":
            new_node = new Method (
                parse_callable_attrs (attrs),
                get_string (attrs, "glib:set-property"),
                get_string (attrs, "glib:get-property"),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "namespace":
            new_node = new Namespace (
                get_string (attrs, "name"),
                get_string (attrs, "version"),
                get_string (attrs, "c:identifier-prefixes"),
                get_string (attrs, "c:symbol-prefixes"),
                get_string (attrs, "c:prefix"),
                get_string (attrs, "shared-library"),
                get_nodes <Alias> (children),
                get_nodes <Class> (children),
                get_nodes <Interface> (children),
                get_nodes <Record> (children),
                get_nodes <Enumeration> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                get_nodes <FunctionMacro> (children),
                get_nodes <Union> (children),
                get_nodes <Bitfield> (children),
                get_nodes <Callback> (children),
                get_nodes <Constant> (children),
                get_nodes <Attribute> (children),
                get_nodes <Boxed> (children),
                get_nodes <Docsection> (children),
                source);
            break;
        case "package":
            new_node = new Package (get_string (attrs, "name"), source);
            break;
        case "parameter":
            new_node = new Parameter (
                get_string (attrs, "name"),
                get_bool (attrs, "nullable"),
                get_bool (attrs, "allow-none"),
                get_bool (attrs, "introspectable"),
                get_string (attrs, "closure"),
                get_string (attrs, "destroy"),
                Scope.from_string (get_string (attrs, "scope")),
                Direction.from_string (get_string (attrs, "direction")),
                get_bool (attrs, "caller-allocates"),
                get_bool (attrs, "optional"),
                get_bool (attrs, "skip"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                parse_doc_elements (children),
                get_node <AnyType> (children),
                get_node <Varargs> (children),
                get_nodes <Attribute> (children),
                source);
            break;
        case "parameters":
            new_node = new Parameters (
                get_nodes <Parameter> (children),
                get_node <InstanceParameter> (children),
                source);
            break;
        case "prerequisite":
            new_node = new Prerequisite (get_string (attrs, "name"), source);
            break;
        case "property":
            new_node = new Property (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_bool (attrs, "writable"),
                get_bool (attrs, "readable"),
                get_bool (attrs, "construct"),
                get_bool (attrs, "construct-only"),
                get_string (attrs, "setter"),
                get_string (attrs, "getter"),
                get_string (attrs, "default_value"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                parse_info_elements (children),
                get_node <AnyType> (children),
                source);
            break;
        case "record":
            if (attrs.has_key ("name")) {
                new_node = new Record (
                    parse_info_attrs (attrs),
                    get_string (attrs, "name"),
                    get_string (attrs, "c:type"),
                    get_bool (attrs, "disguised"),
                    get_bool (attrs, "opaque"),
                    get_bool (attrs, "pointer"),
                    get_string (attrs, "glib:type-name"),
                    get_string (attrs, "glib:get-type"),
                    get_string (attrs, "c:symbol-prefix"),
                    get_bool (attrs, "foreign"),
                    get_string (attrs, "glib:is-gtype-struct-for"),
                    get_string (attrs, "copy-function"),
                    get_string (attrs, "free-function"),
                    parse_info_elements (children),
                    get_nodes <Field> (children),
                    get_nodes <Function> (children),
                    get_nodes <FunctionInline> (children),
                    get_nodes <Union> (children),
                    get_nodes <Method> (children),
                    get_nodes <MethodInline> (children),
                    get_nodes <Constructor> (children),
                    source);
            } else {
                new_node = new AnonymousRecord (
                    parse_doc_elements (children),
                    get_nodes <Field> (children),
                    get_nodes <Union> (children),
                    source);
            }
            break;
        case "repository":
            new_node = new Repository (
                get_string (attrs, "version"),
                get_string (attrs, "c:identifier-prefixes"),
                get_string (attrs, "c:symbol-prefixes"),
                get_nodes <Include> (children),
                get_nodes <CInclude> (children),
                get_nodes <Package> (children),
                get_nodes <Namespace> (children),
                get_nodes <DocFormat> (children),
                source);
            break;
        case "return-value":
            new_node = new ReturnValue (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "nullable"),
                get_string (attrs, "closure"),
                Scope.from_string (get_string (attrs, "scope")),
                get_string (attrs, "destroy"),
                get_bool (attrs, "skip"),
                get_bool (attrs, "allow-none"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                parse_doc_elements (children),
                get_nodes <Attribute> (children),
                get_node <AnyType> (children),
                source);
            break;
        case "source-position":
            new_node = new SourcePosition (
                get_string (attrs, "filename"),
                get_string (attrs, "line"),
                get_string (attrs, "column"),
                source);
            break;
        case "type":
            new_node = new TypeRef (
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_bool (attrs, "introspectable"),
                parse_doc_elements (children),
                get_nodes <AnyType> (children),
                source);
            break;
        case "union":
            new_node = new Union (
                parse_info_attrs (attrs),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "copy-function"),
                get_string (attrs, "free-function"),
                parse_info_elements (children),
                get_nodes <Field> (children),
                get_nodes <Constructor> (children),
                get_nodes <Method> (children),
                get_nodes <MethodInline> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                get_nodes <Record> (children),
                source);
            break;
        case "varargs":
            new_node = new Varargs (source);
            break;
        case "virtual-method":
            new_node = new VirtualMethod (
                parse_callable_attrs (attrs),
                get_string (attrs, "invoker"),
                get_bool (attrs, "glib:static"),
                parse_info_elements (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        default:
            context.report.warning (source, "Skipping unsupported element '%s'", element);
            break;
        }

        foreach (var child in children) {
            child.parent_node = new_node;
        }

        return new_node;
    }

    private static InfoAttrsParameters parse_info_attrs (Gee.Map<string, string> attrs) {
        return InfoAttrsParameters () {
            introspectable = get_bool (attrs, "introspectable"),
            deprecated = get_bool (attrs, "deprecated"),
            deprecated_version = get_string (attrs, "deprecated-version"),
            version = get_string (attrs, "version"),
            stability = get_string (attrs, "stability")
        };
    }

    private static CallableAttrsParameters parse_callable_attrs (Gee.Map<string, string> attrs) {
        return CallableAttrsParameters () {
            info_attrs_parameters = parse_info_attrs (attrs),
            name = get_string (attrs, "name"),
            c_identifier = get_string (attrs, "c:identifier"),
            shadowed_by = new Link<Callable> (get_string (attrs, "shadowed-by")),
            shadows = new Link<Callable> (get_string (attrs, "shadows")),
            @throws = get_bool (attrs, "throws"),
            moved_to = get_string (attrs, "moved-to"),
            glib_async_func = new Link<Callable> (get_string (attrs, "glib:async-func")),
            glib_sync_func = new Link<Callable> (get_string (attrs, "glib:sync-func")),
            glib_finish_func = new Link<Callable> (get_string (attrs, "glib:finish-func"))
        };
    }

    private static DocElementsParameters parse_doc_elements (Gee.ArrayList<Node> children) {
        return DocElementsParameters () {
            doc_version = get_node <DocVersion> (children),
            doc_stability = get_node <DocStability> (children),
            doc = get_node <Doc> (children),
            doc_deprecated = get_node <DocDeprecated> (children),
            source_position = get_node <SourcePosition> (children)
        };
    }

    private static InfoElementsParameters parse_info_elements (Gee.ArrayList<Node> children) {
        return InfoElementsParameters () {
            doc_elements_parameters = parse_doc_elements (children),
            attributes = get_nodes <Attribute> (children)
        };
    }
}
