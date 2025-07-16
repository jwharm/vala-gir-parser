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
        cls.parent.node = resolve_type<Class> (cls, cls.parent.text);

        /* Resolve class.glib_type_struct to a record */
        cls.glib_type_struct.node = resolve_type<Record> (cls, cls.glib_type_struct.text);

        /* Resolve class.glib_ref_func, glib_unref_func, set_value_func and
         * get_value_func to a method or function */
        cls.glib_ref_func.node = resolve_c_identifier<Callable> (cls.glib_ref_func.text, cls.source);
        cls.glib_unref_func.node = resolve_c_identifier<Callable> (cls.glib_unref_func.text, cls.source);
        cls.glib_set_value_func.node = resolve_c_identifier<Callable> (cls.glib_set_value_func.text, cls.source);
        cls.glib_get_value_func.node = resolve_c_identifier<Callable> (cls.glib_get_value_func.text, cls.source);

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
        implements.interface.node = resolve_type<Interface> (implements, implements.name);
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
        iface.glib_type_struct.node = resolve_type<Record> (iface, iface.glib_type_struct.text);
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
        property.getter.node = get_child_by_name<Method> (property.parent_node, property.getter.text);
        property.setter.node = get_child_by_name<Method> (property.parent_node, property.setter.text);
        property.accept_children (this);
    }

    public override void visit_record (Record record) {
        /* Resolve record.copy_function and free_function to a method or function */
        record.copy_function.node = resolve_c_identifier<Callable> (record.copy_function.text, record.source);
        record.free_function.node = resolve_c_identifier<Callable> (record.free_function.text, record.source);
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
        union.copy_function.node = resolve_c_identifier<Callable> (union.copy_function.text, union.source);
        union.free_function.node = resolve_c_identifier<Callable> (union.free_function.text, union.source);

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

    /* Find a child node with the requested name and type in the immediate
     * children of the requested node. Returns null when not found. */
    private static T? get_child_by_name<T> (Node node, string? child_node_name) {
        if (child_node_name == null) {
            return null;
        }

        T result = null;
        node.accept_children (new ForeachVisitor (child => {
            if (child is T && child is Named && child_node_name == ((Named) child).name) {
                result = (T) child;
                return ForeachResult.STOP;
            }

            return ForeachResult.SKIP;
        }));
        return result;
    }

    /* Resolve a type name relative to the namespace of this node. The type name
     * can be "Namespace.TypeName" or, when the type is in the same namespace,
     * simply "TypeName". */
    private T? resolve_type<T> (Node node, string? name) {
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
            T id = get_child_by_name<T> (ns, type_name);
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
        T id = get_child_by_name<T> (target_namespace, identifier_name);
        if (id == null) {
            context.report.warning (node.source, "Type '%s' not found in namespace %s", identifier_name, target_namespace.name);
        }

        return id;
    }

    /* Resolve the requested C identifier in all namespaces in the Gir context.
     * Returns null if the C identifier is not found. */
    private T? resolve_c_identifier<T> (string? c_identifier, Xml.Reference? source) {
        if (c_identifier == null) {
            return null;
        }

        T result = null;

        /* Lookup all namespaces with a c:symbol-prefix that matches the
         * requested c-identifier. */
        Gee.List<Namespace> namespaces = context.get_namespaces_by_prefix (c_identifier);

        /* Visit all nodes in each of the returned namespaces, to find one with
         * the requested type and c-identifier. */
        foreach (Namespace ns in namespaces) {
            ns.accept_children (new ForeachVisitor (child => {
                if (child is T && child is CallableAttrs && (c_identifier == ((CallableAttrs) child).c_identifier)) {
                    result = (T) child;
                    return ForeachResult.STOP;
                }

                return ForeachResult.CONTINUE;
            }));

            if (result != null) {
                return result;
            }
        }

        if (result == null) {
            context.report.warning (source, "C identifier '%s' not found", c_identifier);
        }

        return result;
    }

    /* Resolve CallableAttrs cross-references to the corresponding Gir Method or
     * Function node. The attributes (shadows, shadowed-by, async-func,
     * sync-func and finish-func) contain a function or method name (in the
     * nodes own scope) so it's a relatively simple lookup. */
    private static void resolve_callable_attrs (Gir.CallableAttrs callable) {
        callable.shadowed_by.node      = get_child_by_name<Callable> (callable, callable.shadowed_by.text);
        callable.shadows.node          = get_child_by_name<Callable> (callable, callable.shadows.text);
        callable.glib_async_func.node  = get_child_by_name<Callable> (callable, callable.glib_async_func.text);
        callable.glib_sync_func.node   = get_child_by_name<Callable> (callable, callable.glib_sync_func.text);
        callable.glib_finish_func.node = get_child_by_name<Callable> (callable, callable.glib_finish_func.text);
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
