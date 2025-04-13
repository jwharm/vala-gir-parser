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

    /* The Gir reference to use when reporting errors */
    private Xml.Reference? source = null;

    /**
     * Create a new Gir Resolver that will lookup repositories in the provided
     * context.
     */
    public Resolver (Context context) {
        this.context = context;
    }

    public override void visit_alias (Alias alias) {
        alias.accept_children (this);
        alias.resolved = true;
    }

    public override void visit_anonymous_record (AnonymousRecord record) {
        record.accept_children (this);
        record.resolved = true;
    }

    public override void visit_array (Array array) {
        this.source = array.source;

        /* Resolve array.length */
        if (array.length_unresolved != -1) {
            /* array field, length is in another field */
            if (array.parent_node is Field) {
                var fields = get_gir_fields (array.parent_node.parent_node);
                array.length = fields[array.length_unresolved];
            }
            
            /* array parameter, length is in another parameter */
            else if (array.parent_node is Parameter) {
                var parameters = (Parameters) array.parent_node.parent_node;
                array.length = parameters.parameters[array.length_unresolved];
            }
            
            /* array return-value, length is in a parameter */
            else if (array.parent_node is ReturnValue) {
                var parameters = ((Callable) array.parent_node.parent_node).parameters;
                array.length = parameters.parameters[array.length_unresolved];
            }
        }

        array.accept_children (this);
        array.resolved = true;
    }

    public override void visit_attribute (Attribute attribute) {
        attribute.accept_children (this);
        attribute.resolved = true;
    }

    public override void visit_bitfield (Bitfield bitfield) {
        bitfield.accept_children (this);
        bitfield.resolved = true;
    }

    public override void visit_boxed (Boxed boxed) {
        boxed.accept_children (this);
        boxed.resolved = true;
    }

    public override void visit_c_include (CInclude c_include) {
        c_include.accept_children (this);
        c_include.resolved = true;
    }

    public override void visit_callback (Callback callback) {
        callback.accept_children (this);
        callback.resolved = true;
    }

    public override void visit_class (Class cls) {
        this.source = cls.source;
        var ns = get_namespace (cls);
        
        /* Resolve class.parent */
        if (cls.parent_unresolved != null) {
            cls.parent = resolve_type (ns, cls.parent_unresolved) as Class;
        }

        /* Resolve class.glib_type_struct */
        if (cls.glib_type_struct_unresolved != null) {
            cls.glib_type_struct = resolve_type (ns, cls.glib_type_struct_unresolved) as Record;
        }

        /* TODO: Resolve identifiers */

        cls.accept_children (this);
        cls.resolved = true;
    }

    public override void visit_constant (Constant constant) {
        constant.accept_children (this);
        constant.resolved = true;
    }

    public override void visit_constructor (Constructor constructor) {
        constructor.accept_children (this);
        constructor.resolved = true;
    }

    public override void visit_doc_deprecated (DocDeprecated doc_deprecated) {
        doc_deprecated.accept_children (this);
        doc_deprecated.resolved = true;
    }

    public override void visit_doc_format (DocFormat doc_format) {
        doc_format.accept_children (this);
        doc_format.resolved = true;
    }

    public override void visit_doc_stability (DocStability doc_stability) {
        doc_stability.accept_children (this);
        doc_stability.resolved = true;
    }

    public override void visit_doc_version (DocVersion doc_version) {
        doc_version.accept_children (this);
        doc_version.resolved = true;
    }

    public override void visit_doc (Doc doc) {
        doc.accept_children (this);
        doc.resolved = true;
    }

    public override void visit_docsection (Docsection docsection) {
        docsection.accept_children (this);
        docsection.resolved = true;
    }

    public override void visit_enumeration (Enumeration enumeration) {
        enumeration.accept_children (this);
        enumeration.resolved = true;
    }

    public override void visit_field (Field field) {
        field.accept_children (this);
        field.resolved = true;
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        function_inline.accept_children (this);
        function_inline.resolved = true;
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        function_macro.accept_children (this);
        function_macro.resolved = true;
    }

    public override void visit_function (Function function) {
        function.accept_children (this);
        function.resolved = true;
    }

    public override void visit_implements (Implements implements) {
        this.source = implements.source;

        /* Resolve implements.name */
        var ns = get_namespace (implements);
        implements.target = resolve_type (ns, implements.name) as Interface;
        
        implements.accept_children (this);
        implements.resolved = true;
    }

    public override void visit_include (Include include) {
        this.source = include.source;

        /* Resolve include.name */
        include.target = context.get_repository (include.name + "-" + include.version);
        include.accept_children (this);
        include.resolved = true;
    }

    public override void visit_instance_parameter (InstanceParameter instance_parameter) {
        instance_parameter.accept_children (this);
        instance_parameter.resolved = true;
    }

    public override void visit_interface (Interface iface) {
        this.source = iface.source;

        /* Resolve interface.glib_type_struct */
        var ns = get_namespace (iface);
        if (iface.glib_type_struct_unresolved != null) {
            iface.glib_type_struct = resolve_type (ns, iface.glib_type_struct_unresolved) as Record;
        }

        iface.accept_children (this);
        iface.resolved = true;
    }

    public override void visit_member (Member member) {
        member.accept_children (this);
        member.resolved = true;
    }

    public override void visit_method_inline (MethodInline method_inline) {
        method_inline.accept_children (this);
        method_inline.resolved = true;
    }

    public override void visit_method (Method method) {
        method.accept_children (this);
        method.resolved = true;
    }

    public override void visit_namespace (Namespace ns) {
        ns.accept_children (this);
        ns.resolved = true;
    }

    public override void visit_package (Package package) {
        package.accept_children (this);
        package.resolved = true;
    }

    public override void visit_parameter (Parameter parameter) {
        this.source = parameter.source;

        /* Resolve parameter.closure */
        if (parameter.closure_unresolved != -1) {
            var parameters = (Parameters) parameter.parent_node;
            parameter.closure = parameters.parameters[parameter.closure_unresolved];
        }

        /* Resolve parameter.destroy */
        if (parameter.destroy_unresolved != -1) {
            var parameters = (Parameters) parameter.parent_node;
            parameter.destroy = parameters.parameters[parameter.destroy_unresolved];
        }
        
        parameter.accept_children (this);
        parameter.resolved = true;
    }

    public override void visit_parameters (Parameters parameters) {
        parameters.accept_children (this);
        parameters.resolved = true;
    }

    public override void visit_prerequisite (Prerequisite prerequisite) {
        this.source = prerequisite.source;

        /* Resolve prerequisite.name */
        var ns = get_namespace (prerequisite);
        prerequisite.target = resolve_type (ns, prerequisite.name);
        prerequisite.accept_children (this);
        prerequisite.resolved = true;
    }

    public override void visit_property (Property property) {
        property.accept_children (this);
        property.resolved = true;
    }

    public override void visit_record (Record record) {
        record.accept_children (this);
        record.resolved = true;
    }

    public override void visit_repository (Repository repository) {
        repository.accept_children (this);
        repository.resolved = true;
    }

    public override void visit_return_value (ReturnValue return_value) {
        this.source = return_value.source;

        /* Resolve return_value.closure */
        if (return_value.closure_unresolved != -1) {
            var parameters = ((Callable) return_value.parent_node).parameters;
            return_value.closure = parameters.parameters[return_value.closure_unresolved];
        }

        /* Resolve return_value.destroy */
        if (return_value.destroy_unresolved != -1) {
            var parameters = ((Callable) return_value.parent_node).parameters;
            return_value.destroy = parameters.parameters[return_value.destroy_unresolved];
        }

        return_value.accept_children (this);
        return_value.resolved = true;
    }

    public override void visit_signal (Signal sig) {
        sig.accept_children (this);
        sig.resolved = true;
    }

    public override void visit_source_position (SourcePosition source_position) {
        source_position.accept_children (this);
        source_position.resolved = true;
    }

    public override void visit_type (TypeRef type) {
        this.source = type.source;

        /* Resolve type.name */
        var ns = get_namespace (type);
        if (! (type.name in SIMPLE_TYPES || type.name == "none" || type.name == "va_list")) {
            type.target = resolve_type (ns, type.name);
        }
        
        type.accept_children (this);
        type.resolved = true;
    }

    public override void visit_union (Union union) {
        union.accept_children (this);
        union.resolved = true;
    }

    public override void visit_varargs (Varargs varargs) {
        varargs.accept_children (this);
        varargs.resolved = true;
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        virtual_method.accept_children (this);
        virtual_method.resolved = true;
    }

    /********************/
    /* Helper functions */
    /********************/

    /* Get the namespace of this Gir node */
    private static Namespace get_namespace (Gir.Node node) {
        if (node is Namespace) {
            return (Namespace) node;
        }

        if (node.parent_node != null) {
            return get_namespace (node.parent_node);
        }

        assert_not_reached (); /* A node should always be in a namespace */
    }

    /* Find a registered type with the requested name in the requested
     * namespace. If not found, this will report een error and return null. */
    private Identifier? get_identifier (Namespace ns, string name) {
        foreach (var alias in ns.aliases) {
            if (alias.name == name) {
                return alias;
            }
        }
        
        foreach (var bitfield in ns.bitfields) {
            if (bitfield.name == name) {
                return bitfield;
            }
        }
        
        foreach (var boxed in ns.boxeds) {
            if (boxed.name == name) {
                return boxed;
            }
        }

        foreach (var callback in ns.callbacks) {
            if (callback.name == name) {
                return callback;
            }
        }
        
        foreach (var cls in ns.classes) {
            if (cls.name == name) {
                return cls;
            }
        }
        
        foreach (var enumeration in ns.enums) {
            if (enumeration.name == name) {
                return enumeration;
            }
        }
        
        foreach (var iface in ns.interfaces) {
            if (iface.name == name) {
                return iface;
            }
        }
        
        foreach (var record in ns.records) {
            if (record.name == name) {
                return record;
            }
        }

        Gir.Xml.Report.error (source, "Type '%s' not found in namespace %s", name, ns.name);
        return null;
    }

    /* Resolve a type name. It can be "Namespace.TypeName" or, when the type is
     * in the same namespace, simply "TypeName". */
    private Identifier? resolve_type (Namespace ns, string name) {
        string type_name = name;

        /* GType is actually GObject.Type */
        if (type_name == "GType") {
            type_name = "GObject.Type";
        }

        int dot = type_name.index_of_char ('.', 0);
        if (dot == -1) {
            /* Lookup in the same namespace */
            return get_identifier (ns, type_name);
        }

        /* Lookup the target namespace */
        string namespace_name = type_name.substring (0, dot);
        var target_repo = context.get_repository_by_name (namespace_name);
        if (target_repo == null) {
            Gir.Xml.Report.error (source, "Namespace '%s' not found", namespace_name);
            return null;
        }

        /* Lookup the type name in the target namespace */
        var target_namespace = target_repo.namespaces.first ();
        string identifier_name = type_name.substring (dot + 1);
        return get_identifier (target_namespace, identifier_name);
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
