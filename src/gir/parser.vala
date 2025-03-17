/* vala-gir-parser
 * Copyright (C) 2025 Jan-Willem Harmannij
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

using Vala;

public class Gir.Parser {
    private SourceFile source_file;
    private SourceLocation begin;
    private SourceLocation end;
    
    /**
     * Get a list that only contains nodes with the specified type.
     */
    private static Vala.List<T> get_nodes<T> (ArrayList<Node> list) {
        var result = new ArrayList<T> ();
        var type = typeof (T);
        foreach (var node in list) {
            if (node.get_type ().is_a (type)) {
                result.add (node);
            }
        }
        return result;
    }

    /**
     * Get the first child node with the specified type, or `null` if not found.
     */
    private static T? get_node<T> (ArrayList<Node> children) {
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
    private static bool get_bool (Vala.Map<string, string> attrs, string key, bool if_not_set = false) {
        return (key in attrs) ? ("1" == attrs[key]) : if_not_set;
    }

    /**
     * Get the int value of this key
     */
    private static int get_int (Vala.Map<string, string> attrs, string key, int if_not_set = -1) {
        return (key in attrs) ? (int.parse (attrs[key])) : if_not_set;
    }
    
    /**
     * Get the string value of this key
     */
    private static string? get_string (Vala.Map<string, string> attrs, string key, string? if_not_set = null) {
        return (key in attrs) ? (attrs[key]) : if_not_set;
    }

    /**
     * Create a Gir Parser for the provided source file.
     *
     * @param  source_file a valid Gir file
     */
    public Parser (SourceFile source_file) {
        this.source_file = source_file;
    }

    /**
     * Parse the provided Gir file into a tree of Gir Nodes.
     *
     * @return the Repository, or null in case the gir file is invalid
     */
    public Repository? parse() {
        var reader = new MarkupReader (source_file.filename);
        
        /* Find the first START_ELEMENT token in the XML file */
        while (true) {
            var token_type = reader.read_token (out begin, out end);
            if (token_type == START_ELEMENT) {
                return parse_element (reader) as Repository;
            } else if (token_type == EOF) {
                var source = new SourceReference (source_file, begin, end);
                Report.error (source, "No repository found");
                return null;
            }
        }
    }

    /* Parse one XML element (recursively), and return a new Gir Node */
    private Node parse_element (MarkupReader reader) {
        var element = reader.name;
        var children = new Vala.ArrayList<Node> ();
        var attrs = reader.get_attributes ();
        var content = new StringBuilder ();
        var source = new SourceReference (source_file, begin, end);

        /* Keep parsing XML until an END_ELEMENT or EOF token is reached */
        while (true) {
            var token = reader.read_token (out begin, out end);
            if (token == MarkupTokenType.START_ELEMENT) {
                /* Recursively create a child node and add it to the list */
                Node node = parse_element (reader);
                children.add (node);
            } else if (token == MarkupTokenType.TEXT) {
                content.append (reader.content);
            } else {
                break;
            }
        }
        
        Node new_node;
        switch (element) {
        case "alias":
            new_node = new Alias (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <AnyType> (children),
                source);
            break;
        case "array":
            new_node = new Array (
                get_string (attrs, "name"),
                get_bool (attrs, "zero-terminated"),
                get_int (attrs, "fixed-size"),
                get_bool (attrs, "introspectable"),
                get_int (attrs, "length"),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_bool (attrs, "throws"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "class":
            new_node = new Class (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
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
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "value"),
                get_string (attrs, "c:type"),
                get_string (attrs, "c:identifier"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <AnyType> (children),
                source);
            break;
        case "constructor":
            new_node = new Constructor (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                source);
            break;
        case "enumeration":
            new_node = new Enumeration (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "glib:error-domain"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_nodes <Member> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                source);
            break;
        case "field":
            new_node = new Field (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_bool (attrs, "writable"),
                get_bool (attrs, "readable"),
                get_bool (attrs, "private"),
                get_int (attrs, "bits"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                source);
            break;
        case "function-inline":
            new_node = new FunctionInline (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                source);
            break;
        case "function-macro":
            new_node = new FunctionMacro (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                source);
            break;
        case "function":
            new_node = new Function (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "glib:boxed":
            new_node = new Boxed (
                get_string (attrs, "name"),
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                source);
            break;
        case "glib:signal":
            new_node = new Signal (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_bool (attrs, "detailed"),
                When.from_string (get_string (attrs, "when")),
                get_bool (attrs, "action"),
                get_bool (attrs, "no-hooks"),
                get_bool (attrs, "no-recurse"),
                get_string (attrs, "emitter"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "implements":
            new_node = new Implements (get_string (attrs, "name"), source);
            break;
        case "include":
            new_node = new Include (
                get_string (attrs, "name"),
                get_string (attrs, "version"),
                source);
            break;
        case "instance-parameter":
            new_node = new InstanceParameter (
                get_string (attrs, "name"),
                get_bool (attrs, "nullable"),
                get_bool (attrs, "allow-none"),
                Direction.from_string (get_string (attrs, "direction")),
                get_bool (attrs, "caller-allocates"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_node <TypeRef> (children),
                source);
            break;
        case "interface":
            new_node = new Interface (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "c:type"),
                get_string (attrs, "glib:type-struct"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "value"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "glib:nick"),
                get_string (attrs, "glib:name"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                source);
            break;
        case "method-inline":
            new_node = new MethodInline (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        case "method":
            new_node = new Method (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_string (attrs, "glib:set-property"),
                get_string (attrs, "glib:get-property"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_int (attrs, "closure"),
                get_int (attrs, "destroy"),
                Scope.from_string (get_string (attrs, "scope")),
                Direction.from_string (get_string (attrs, "direction")),
                get_bool (attrs, "caller-allocates"),
                get_bool (attrs, "optional"),
                get_bool (attrs, "skip"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_bool (attrs, "writable"),
                get_bool (attrs, "readable"),
                get_bool (attrs, "construct"),
                get_bool (attrs, "construct-only"),
                get_string (attrs, "setter"),
                get_string (attrs, "getter"),
                get_string (attrs, "default_value"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <AnyType> (children),
                source);
            break;
        case "record":
            new_node = new Record (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
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
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_nodes <Field> (children),
                get_nodes <Function> (children),
                get_nodes <FunctionInline> (children),
                get_nodes <Union> (children),
                get_nodes <Method> (children),
                get_nodes <MethodInline> (children),
                get_nodes <Constructor> (children),
                source);
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
                get_int (attrs, "closure"),
                Scope.from_string (get_string (attrs, "scope")),
                get_int (attrs, "destroy"),
                get_bool (attrs, "skip"),
                get_bool (attrs, "allow-none"),
                TransferOwnership.from_string (get_string (attrs, "transfer-ownership")),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
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
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <AnyType> (children),
                source);
            break;
        case "union":
            new_node = new Union (
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:type"),
                get_string (attrs, "c:symbol-prefix"),
                get_string (attrs, "glib:type-name"),
                get_string (attrs, "glib:get-type"),
                get_string (attrs, "copy-function"),
                get_string (attrs, "free-function"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
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
                get_bool (attrs, "introspectable"),
                get_bool (attrs, "deprecated"),
                get_string (attrs, "deprecated-version"),
                get_string (attrs, "version"),
                get_string (attrs, "stability"),
                get_string (attrs, "name"),
                get_string (attrs, "c:identifier"),
                get_string (attrs, "shadowed-by"),
                get_string (attrs, "shadows"),
                get_bool (attrs, "throws"),
                get_string (attrs, "moved-to"),
                get_string (attrs, "glib:async-func"),
                get_string (attrs, "glib:sync-func"),
                get_string (attrs, "glib:finish-func"),
                get_string (attrs, "invoker"),
                get_bool (attrs, "glib:static"),
                get_node <DocVersion> (children),
                get_node <DocStability> (children),
                get_node <Doc> (children),
                get_node <DocDeprecated> (children),
                get_node <SourcePosition> (children),
                get_nodes <Attribute> (children),
                get_node <Parameters> (children),
                get_node <ReturnValue> (children),
                source);
            break;
        default:
            Report.error (source, "Unsupported element '%s'", element);
            break;
        }

        foreach (var child in children) {
            child.parent_node = new_node;
        }

        return new_node;
    }
}
