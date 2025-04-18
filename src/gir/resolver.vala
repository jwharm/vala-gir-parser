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

public class Gir.Resolver : Gir.Visitor {

    /* Do not try to lookup these types */
    private const string[] SIMPLE_TYPES = {
        "gboolean",
        "gchar",
        "gunichar",
        "gshort",
        "gushort",
        "gint",
        "guint",
        "glong",
        "gulong",
        "gint8",
        "guint8",
        "gint16",
        "guint16",
        "gint32",
        "guint32",
        "gint64",
        "guint64",
        "gfloat",
        "gdouble",
        "utf8",
        "filename",
        "gsize",
        "gssize",
        "gpointer"
    };

    /**
     * The Gir Context
     */
    public Context context { get; set; }

    /**
     * Create a new Gir Resolver that will lookup repositories in the provided
     * context.
     */
    public Resolver (Context context) {
        this.context = context;
    }

    public override void visit_alias (Alias alias) {
        alias.accept_children (this);
    }

    public override void visit_anonymous_record (AnonymousRecord record) {
        record.accept_children (this);
    }

    public override void visit_array (Array array) {
        /* Resolve array.length to a parameter (in a call) or field (in a struct) */
        if (array.length.text != null) {
            int idx = int.parse (array.length.text);

            /* array field, length is in another field */
            if (array.parent_node is Field) {
                var fields = get_gir_fields (array.parent_node.parent_node);
                array.length.node = fields[idx];
            }
            
            /* array parameter, length is in another parameter */
            else if (array.parent_node is Parameter) {
                var parameters = (Parameters) array.parent_node.parent_node;
                array.length.node = parameters.parameters[idx];
            }
            
            /* array return-value, length is in a parameter */
            else if (array.parent_node is ReturnValue) {
                var parameters = ((Callable) array.parent_node.parent_node).parameters;
                array.length.node = parameters.parameters[idx];
            }
        }

        array.accept_children (this);
    }

    public override void visit_attribute (Attribute attribute) {
        attribute.accept_children (this);
    }

    public override void visit_bitfield (Bitfield bitfield) {
        bitfield.accept_children (this);
    }

    public override void visit_boxed (Boxed boxed) {
        boxed.accept_children (this);
    }

    public override void visit_c_include (CInclude c_include) {
        c_include.accept_children (this);
    }

    public override void visit_callback (Callback callback) {
        callback.accept_children (this);
    }

    public override void visit_class (Class cls) {
        /* Resolve class.parent to a class */
        cls.parent.node = resolve_type (cls, cls.parent.text) as Class;

        /* Resolve class.glib_type_struct to a record */
        cls.glib_type_struct.node = resolve_type (cls, cls.glib_type_struct.text) as Record;

        /* Resolve class.glib_ref_func, glib_unref_func, set_value_func and
         * get_value_func to a method or function */
        cls.glib_ref_func.node = resolve_c_identifier (cls, cls.glib_ref_func.text) as Callable;
        cls.glib_unref_func.node = resolve_c_identifier (cls, cls.glib_unref_func.text) as Callable;
        cls.glib_set_value_func.node = resolve_c_identifier (cls, cls.glib_set_value_func.text) as Callable;
        cls.glib_get_value_func.node = resolve_c_identifier (cls, cls.glib_get_value_func.text) as Callable;

        cls.accept_children (this);
    }

    public override void visit_constant (Constant constant) {
        constant.accept_children (this);
    }

    public override void visit_constructor (Constructor constructor) {
        resolve_callable_attrs (constructor);
        constructor.accept_children (this);
    }

    public override void visit_doc_deprecated (DocDeprecated doc_deprecated) {
        doc_deprecated.accept_children (this);
    }

    public override void visit_doc_format (DocFormat doc_format) {
        doc_format.accept_children (this);
    }

    public override void visit_doc_stability (DocStability doc_stability) {
        doc_stability.accept_children (this);
    }

    public override void visit_doc_version (DocVersion doc_version) {
        doc_version.accept_children (this);
    }

    public override void visit_doc (Doc doc) {
        doc.accept_children (this);
    }

    public override void visit_docsection (Docsection docsection) {
        docsection.accept_children (this);
    }

    public override void visit_enumeration (Enumeration enumeration) {
        enumeration.accept_children (this);
    }

    public override void visit_field (Field field) {
        field.accept_children (this);
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        resolve_callable_attrs (function_inline);
        function_inline.accept_children (this);
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        resolve_callable_attrs (function_macro);
        function_macro.accept_children (this);
    }

    public override void visit_function (Function function) {
        function.accept_children (this);
    }

    public override void visit_implements (Implements implements) {
        /* Resolve implements.name to an interface */
        implements.interface.node = resolve_type (implements, implements.name) as Interface;
        implements.accept_children (this);
    }

    public override void visit_include (Include include) {
        /* Resolve include.name-version to a repository */
        include.repository.node = context.get_repository (include.repository.text);
        include.accept_children (this);
    }

    public override void visit_instance_parameter (InstanceParameter instance_parameter) {
        instance_parameter.accept_children (this);
    }

    public override void visit_interface (Interface iface) {
        /* Resolve interface.glib_type_struct to a record */
        iface.glib_type_struct.node = resolve_type (iface, iface.glib_type_struct.text) as Record;
        iface.accept_children (this);
    }

    public override void visit_member (Member member) {
        member.accept_children (this);
    }

    public override void visit_method_inline (MethodInline method_inline) {
        resolve_callable_attrs (method_inline);
        method_inline.accept_children (this);
    }

    public override void visit_method (Method method) {
        resolve_callable_attrs (method);
        method.accept_children (this);
    }

    public override void visit_namespace (Namespace ns) {
        ns.accept_children (this);
    }

    public override void visit_package (Package package) {
        package.accept_children (this);
    }

    public override void visit_parameter (Parameter parameter) {
        /* Resolve parameter.closure to a parameter */
        if (parameter.closure.text != null) {
            var parameters = (Parameters) parameter.parent_node;
            var idx = int.parse (parameter.closure.text);
            parameter.closure.node = parameters.parameters[idx];
        }

        /* Resolve parameter.destroy to a parameter */
        if (parameter.destroy.text != null) {
            var parameters = (Parameters) parameter.parent_node;
            var idx = int.parse (parameter.destroy.text);
            parameter.destroy.node = parameters.parameters[idx];
        }
        
        parameter.accept_children (this);
    }

    public override void visit_parameters (Parameters parameters) {
        parameters.accept_children (this);
    }

    public override void visit_prerequisite (Prerequisite prerequisite) {
        /* Resolve prerequisite.name to a class or interface */
        prerequisite.identifier.node = resolve_type (prerequisite, prerequisite.name);
        prerequisite.accept_children (this);
    }

    public override void visit_property (Property property) {
        /* Resolve property.getter and setter to a method or function */
        property.getter.node = get_child_by_name (property.parent_node, property.getter.text) as Method;
        property.setter.node = get_child_by_name (property.parent_node, property.setter.text) as Method;
        property.accept_children (this);
    }

    public override void visit_record (Record record) {
        /* Resolve record.copy_function and free_function to a method or function */
        record.copy_function.node = resolve_c_identifier (record, record.copy_function.text) as Callable;
        record.free_function.node = resolve_c_identifier (record, record.free_function.text) as Callable;
        record.accept_children (this);
    }

    public override void visit_repository (Repository repository) {
        repository.accept_children (this);
    }

    public override void visit_return_value (ReturnValue return_value) {
        /* Resolve return_value.closure to a parameter */
        if (return_value.closure.text != null) {
            var parameters = ((Callable) return_value.parent_node).parameters;
            var idx = int.parse (return_value.closure.text);
            return_value.closure.node = parameters.parameters[idx];
        }

        /* Resolve return_value.destroy to a parameter */
        if (return_value.destroy.text != null) {
            var parameters = ((Callable) return_value.parent_node).parameters;
            var idx = int.parse (return_value.closure.text);
            return_value.destroy.node = parameters.parameters[idx];
        }

        return_value.accept_children (this);
    }

    public override void visit_signal (Signal sig) {
        sig.accept_children (this);
    }

    public override void visit_source_position (SourcePosition source_position) {
        source_position.accept_children (this);
    }

    public override void visit_type (TypeRef type) {
        /* Resolve type.name to a registered type identifier */
        if (! (type.name in SIMPLE_TYPES || type.name == "none" || type.name == "va_list")) {
            type.identifier.node = resolve_type (type, type.name);
        }
        
        type.accept_children (this);
    }

    public override void visit_union (Union union) {
        /* Resolve union.copy_function and free_function to a method or function */
        union.copy_function.node = resolve_c_identifier (union, union.copy_function.text) as Callable;
        union.free_function.node = resolve_c_identifier (union, union.free_function.text) as Callable;

        union.accept_children (this);
    }

    public override void visit_varargs (Varargs varargs) {
        varargs.accept_children (this);
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        resolve_callable_attrs (virtual_method);
        virtual_method.accept_children (this);
    }

    /********************/
    /* Helper functions */
    /********************/

    /* Get the namespace of this Gir node */
    private static Namespace get_namespace (Gir.Node node) {
        if (node is Namespace) {
            return (Namespace) node;
        } else if (node.parent_node != null) {
            return get_namespace (node.parent_node);
        } else {
            assert_not_reached (); /* A node should always be in a namespace */
        }
    }

    /* Find a child node with the requested name in the requested node. If not
     * found, this will return null. */
    private static Node? get_child_by_name (Node node, string? child_node_name) {
        if (child_node_name == null) {
            return null;
        }

        var resolver = new NameResolver (child_node_name);
        node.accept_children (resolver);
        return resolver.result;
    }

    /* Resolve a type name relative to the namespace of this node. The type name
     * can be "Namespace.TypeName" or, when the type is in the same namespace,
     * simply "TypeName". */
    private Identifier? resolve_type (Node node, string? name) {
        if (name == null) {
            return null;
        }

        Namespace ns = get_namespace (node);
        string type_name = name;

        /* GType is actually GObject.Type */
        if (type_name == "GType") {
            type_name = "GObject.Type";
        }

        int dot = type_name.index_of_char ('.', 0);
        if (dot == -1) {
            /* Lookup in the same namespace */
            Identifier id = get_child_by_name (ns, type_name) as Identifier;
            if (id == null) {
                context.report.warning (node.source, "Type '%s' not found in namespace %s", type_name, ns.name);
            }

            return id;
        }

        /* Lookup the target namespace */
        string namespace_name = type_name.substring (0, dot);
        var target_repo = context.get_repository_by_name (namespace_name);
        if (target_repo == null) {
            context.report.warning (node.source, "Namespace '%s' not found", namespace_name);
            return null;
        }

        /* Lookup the type name in the target namespace */
        Namespace target_namespace = target_repo.namespaces.first ();
        string identifier_name = type_name.substring (dot + 1);
        Identifier id = get_child_by_name (target_namespace, identifier_name) as Identifier;
        if (id == null) {
            context.report.warning (node.source, "Type '%s' not found in namespace %s", identifier_name, target_namespace.name);
        }

        return id;
    }

    /* Use the CIdentifierResolver visitor class to resolve the requested
     * C identifier. Returns null if the C identifier is not found. */
    private Gir.Node? resolve_c_identifier (Gir.Node node, string? c_identifier) {
        if (c_identifier == null) {
            return null;
        }

        var resolver = new CIdentifierResolver (c_identifier);
        node.accept (resolver);
        if (!resolver.found) {
            context.report.warning (node.source, "C identifier '%s' not found", c_identifier);
        }
        
        return resolver.result;
    }

    /* Resolve CallableAttrs cross-references to the corresponding Gir Method or
     * Function node. The attributes (shadows, shadowed-by, async-func,
     * sync-func and finish-func) contain a function or method name (in the
     * nodes own scope) so it's a relatively simple lookup. */
    private static void resolve_callable_attrs (Gir.CallableAttrs callable) {
        callable.shadowed_by.node      = get_child_by_name (callable, callable.shadowed_by.text) as Callable;
        callable.shadows.node          = get_child_by_name (callable, callable.shadows.text) as Callable;
        callable.glib_async_func.node  = get_child_by_name (callable, callable.glib_async_func.text) as Callable;
        callable.glib_sync_func.node   = get_child_by_name (callable, callable.glib_sync_func.text) as Callable;
        callable.glib_finish_func.node = get_child_by_name (callable, callable.glib_finish_func.text) as Callable;
    }

    /* Get all fields that are declared in this node. When the node doesn't
     * have any fields, an empty list will be returned. */
    private static Gee.List<Field> get_gir_fields (Gir.Node node) {
        if (node is AnonymousRecord) {
            return ((AnonymousRecord) node).fields;
        } else if (node is Interface) {
            return ((Interface) node).fields;
        } else if (node is Class) {
            return ((Class) node).fields;
        } else if (node is Record) {
            return ((Record) node).fields;
        } else if (node is Union) {
            return ((Union) node).fields;
        } else {
            return new Gee.ArrayList<Field> ();
        }
    }
}

/**
 * Gir Node visitor to find a symbol with the given name. We only check the
 * node itself, so accept_children() for a NameResolver will only visit the
 * direct child nodes.
 */
private class Gir.NameResolver : Gir.Visitor {
    public string name;
    public bool found;
    public Node result;

    public NameResolver (string name) {
        this.name = name;
        this.found = false;
        this.result = null;
    }

    public override void visit_alias (Alias alias) {
        if (!found && name == alias.name) {
            result = alias;
            found = true;
        }
    }

    public override void visit_array (Array array) {
        if (!found && name == array.name) {
            result = array;
            found = true;
        }
    }

    public override void visit_attribute (Attribute attribute) {
        if (!found && name == attribute.name) {
            result = attribute;
            found = true;
        }
    }

    public override void visit_bitfield (Bitfield bitfield) {
        if (!found && name == bitfield.name) {
            result = bitfield;
            found = true;
        }
    }

    public override void visit_boxed (Boxed boxed) {
        if (!found && name == boxed.name) {
            result = boxed;
            found = true;
        }
    }

    public override void visit_c_include (CInclude c_include) {
        if (!found && name == c_include.name) {
            result = c_include;
            found = true;
        }
    }

    public override void visit_callback (Callback callback) {
        if (!found && name == callback.name) {
            result = callback;
            found = true;
        }
    }

    public override void visit_class (Class cls) {
        if (!found && name == cls.name) {
            result = cls;
            found = true;
        }
    }

    public override void visit_constant (Constant constant) {
        if (!found && name == constant.name) {
            result = constant;
            found = true;
        }
    }

    public override void visit_constructor (Constructor constructor) {
        if (!found && name == constructor.name) {
            result = constructor;
            found = true;
        }
    }

    public override void visit_enumeration (Enumeration enumeration) {
        if (!found && name == enumeration.name) {
            result = enumeration;
            found = true;
        }
    }

    public override void visit_field (Field field) {
        if (!found && name == field.name) {
            result = field;
            found = true;
        }
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        if (!found && name == function_inline.name) {
            result = function_inline;
            found = true;
        }
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        if (!found && name == function_macro.name) {
            result = function_macro;
            found = true;
        }
    }

    public override void visit_function (Function function) {
        if (!found && name == function.name) {
            result = function;
            found = true;
        }
    }

    public override void visit_implements (Implements implements) {
        if (!found && name == implements.name) {
            result = implements;
            found = true;
        }
    }

    public override void visit_include (Include include) {
        if (!found && name == include.name) {
            result = include;
            found = true;
        }
    }

    public override void visit_instance_parameter (InstanceParameter instance_parameter) {
        if (!found && name == instance_parameter.name) {
            result = instance_parameter;
            found = true;
        }
    }

    public override void visit_interface (Interface iface) {
        if (!found && name == iface.name) {
            result = iface;
            found = true;
        }
    }

    public override void visit_member (Member member) {
        if (!found && name == member.name) {
            result = member;
            found = true;
        }
    }

    public override void visit_method_inline (MethodInline method_inline) {
        if (!found && name == method_inline.name) {
            result = method_inline;
            found = true;
        }
    }

    public override void visit_method (Method method) {
        if (!found && name == method.name) {
            result = method;
            found = true;
        }
    }

    public override void visit_namespace (Namespace ns) {
        if (!found && name == ns.name) {
            result = ns;
            found = true;
        }
    }

    public override void visit_package (Package package) {
        if (!found && name == package.name) {
            result = package;
            found = true;
        }
    }

    public override void visit_parameter (Parameter parameter) {
        if (!found && name == parameter.name) {
            result = parameter;
            found = true;
        }
    }

    public override void visit_prerequisite (Prerequisite prerequisite) {
        if (!found && name == prerequisite.name) {
            result = prerequisite;
            found = true;
        }
    }

    public override void visit_property (Property property) {
        if (!found && name == property.name) {
            result = property;
            found = true;
        }
    }

    public override void visit_record (Record record) {
        if (!found && name == record.name) {
            result = record;
            found = true;
        }
    }

    public override void visit_signal (Signal sig) {
        if (!found && name == sig.name) {
            result = sig;
            found = true;
        }
    }

    public override void visit_type (TypeRef type) {
        if (!found && name == type.name) {
            result = type;
            found = true;
        }
    }

    public override void visit_union (Union union) {
        if (!found && name == union.name) {
            result = union;
            found = true;
        }
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        if (!found && name == virtual_method.name) {
            result = virtual_method;
            found = true;
        }
    }
}

/**
 * Gir Node visitor that will traverse the entire tree in order to find a symbol
 * with the given C identifier. We check the namespace and type definitions for
 * a matching "c:identifier-prefix" to make sure we're searching in the correct
 * place.
 */
private class Gir.CIdentifierResolver : Gir.Visitor {
    public string c_identifier;
    public bool found;
    public Node result;

    public CIdentifierResolver (string c_identifier) {
        this.c_identifier = c_identifier;
        this.found = false;
        this.result = null;
    }

    public override void visit_bitfield (Bitfield bitfield) {
        if (!found) {
            bitfield.accept_children (this);
        }
    }

    public override void visit_boxed (Boxed boxed) {
        if (!found && c_identifier.has_prefix (boxed.c_symbol_prefix)) {
            boxed.accept_children (this);
        }
    }

    public override void visit_class (Class cls) {
        if (!found && c_identifier.has_prefix (cls.c_symbol_prefix)) {
            cls.accept_children (this);
        }
    }

    public override void visit_constant (Constant constant) {
        if (!found && constant.c_identifier == c_identifier) {
            result = constant;
            found = true;
        }
    }

    public override void visit_constructor (Constructor constructor) {
        if (!found && constructor.c_identifier == c_identifier) {
            result = constructor;
            found = true;
        }
    }

    public override void visit_enumeration (Enumeration enumeration) {
        if (!found) {
            enumeration.accept_children (this);
        }
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        if (!found && function_inline.c_identifier == c_identifier) {
            result = function_inline;
            found = true;
        }
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        if (!found && function_macro.c_identifier == c_identifier) {
            result = function_macro;
            found = true;
        }
    }

    public override void visit_function (Function function) {
        if (!found && function.c_identifier == c_identifier) {
            result = function;
            found = true;
        }
    }

    public override void visit_interface (Interface iface) {
        if (!found && c_identifier.has_prefix (iface.c_symbol_prefix)) {
            iface.accept_children (this);
        }
    }

    public override void visit_member (Member member) {
        if (!found && member.c_identifier == c_identifier) {
            result = member;
            found = true;
        }
    }

    public override void visit_method_inline (MethodInline method_inline) {
        if (!found && method_inline.c_identifier == c_identifier) {
            result = method_inline;
            found = true;
        }
    }

    public override void visit_method (Method method) {
        if (!found && method.c_identifier == c_identifier) {
            result = method;
            found = true;
        }
    }

    public override void visit_namespace (Namespace ns) {
        if (!found && c_identifier.has_suffix (ns.c_symbol_prefixes)) {
            ns.accept_children (this);
        }
    }

    public override void visit_record (Record record) {
        if (!found && c_identifier.has_prefix (record.c_symbol_prefix)) {
            record.accept_children (this);
        }
    }

    public override void visit_repository (Repository repository) {
        if (!found) {
            repository.accept_children (this);
        }
    }

    public override void visit_union (Union union) {
        if (!found && c_identifier.has_prefix (union.c_symbol_prefix)) {
            union.accept_children (this);
        }
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        if (!found && virtual_method.c_identifier == c_identifier) {
            result = virtual_method;
            found = true;
        }
    }
}
