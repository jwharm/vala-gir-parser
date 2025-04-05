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

public class VapiBuilder : Gir.Visitor {

    /**
     * Keeps track of the last created Vala Symbol
     */
    private class SymbolStack {
        private ArrayList<Symbol> stack = new ArrayList<Symbol> ();

        public void push (Symbol sym) {
            stack.add (sym);
        }
    
        public Symbol peek () {
            return stack.get (stack.size - 1);
        }
    
        public Symbol pop () {
            return stack.remove_at (stack.size - 1);
        }
    }

    private SymbolStack stack;

    construct {
        stack = new SymbolStack ();
        stack.push (CodeContext.get ().root);
    }

    public override void visit_alias (Gir.Alias g_alias) {
        if (!g_alias.introspectable) {
            return;
        }

        var type_name = g_alias.anytype?.name;
        if (type_name == null) {
            Report.warning (g_alias.source, "Unsupported alias `%s'", g_alias.name);
            return;
        }

        var target = lookup (type_name);
        if (! (target == null || target is Struct || target is Class || target is Interface || target is Delegate)) {
            Report.warning (g_alias.source, "alias for `%s' is not supported", target.get_full_name ());
            return;
        }

        if (target is Class) {
            /* create class */
            Class v_class = new Class (g_alias.name, g_alias.source);
            v_class.access = PUBLIC;
            stack.peek ().add_class (v_class);
            stack.push (v_class);

            /* alias extends the target class and has the same type_id */
            var base_type = DataTypeBuilder.from_name (type_name, g_alias.source);
            v_class.add_base_type (base_type);
            v_class.set_attribute_string ("CCode", "type_id", target.get_attribute_string ("CCode", "type_id"));

            /* attributes */
            add_info_attrs (g_alias);

            /* Generate members */
            g_alias.accept_children (this);
            stack.pop ();
        }
        
        else if (target is Interface) {
            /* this is not a correct alias, but what can we do otherwise? */
            var v_iface = new Interface (g_alias.name, g_alias.source);
            v_iface.access = PUBLIC;
            stack.peek ().add_interface (v_iface);
            stack.push (v_iface);

            /* alias extends the target interface and has the same type_id */
            var prereq_type = DataTypeBuilder.from_name (type_name, g_alias.source);
            v_iface.add_prerequisite (prereq_type);
            v_iface.set_attribute_string ("CCode", "type_id", target.get_attribute_string ("CCode", "type_id"));

            /* attributes */
            add_info_attrs (g_alias);

            /* Generate members */
            g_alias.accept_children (this);
            stack.pop ();
        }
        
        else if (target is Delegate) {
            /* duplicate the aliased delegate */
            var orig = (Delegate) target;

            var v_dlg = new Delegate (g_alias.name, orig.return_type.copy (), g_alias.source);
            v_dlg.access = orig.access;

            foreach (var param in orig.get_parameters ()) {
                v_dlg.add_parameter (param.copy ());
            }

            var error_types = new ArrayList<DataType> ();
            orig.get_error_types (error_types, g_alias.source);
            foreach (var error_type in error_types) {
                v_dlg.add_error_type (error_type.copy ());
            }

            foreach (var attribute in orig.attributes) {
                v_dlg.add_attribute (attribute);
            }

            stack.peek ().add_delegate (v_dlg);
        }

        else if (target == null || target is Struct) {
            /* create struct */
            Struct v_struct = new Struct (g_alias.name, g_alias.source);
            v_struct.access = PUBLIC;
            stack.peek ().add_struct (v_struct);
            stack.push (v_struct);
            
            /* set type_id */
            v_struct.set_attribute_string ("CCode", "type_id", target.get_attribute_string ("CCode", "type_id"));

            /* set base_type and simple_type */
            var builder = new DataTypeBuilder (g_alias.anytype);
            var base_type = builder.build ();
            var simple_type = builder.is_simple_type ();

            if ((base_type as PointerType)?.base_type is VoidType) {
                /* gpointer, if it's a struct make it a simpletype */
                simple_type = true;
            }

            if (target is Struct && ((Struct) target).is_simple_type ()) {
                simple_type = true;
            }

            v_struct.base_type = base_type;
            v_struct.set_simple_type (simple_type);

            /* attributes */
            add_info_attrs (g_alias);

            /* Generate members */
            g_alias.accept_children (this);
            stack.pop ();
        }
    }

    public override void visit_bitfield (Gir.Bitfield g_bitfield) {
        if (!g_bitfield.introspectable) {
            return;
        }

        /* create enum */
        var v_sym = new Enum (g_bitfield.name, g_bitfield.source);
        v_sym.set_attribute ("Flags", true);
        v_sym.access = PUBLIC;
        stack.peek ().add_enum (v_sym);
        stack.push (v_sym);

        /* cname */
        if (g_bitfield.c_type != generate_identifier_cname (g_bitfield)) {
            v_sym.set_attribute_string ("CCode", "cname", g_bitfield.c_type);
        }

        /* cprefix */
        string? common_prefix = null;
        foreach (var g_member in g_bitfield.members) {
            var name = g_member.c_identifier.ascii_up ().replace ("-", "_");
            calculate_common_prefix (ref common_prefix, name);
        }
        v_sym.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* type_id */
        set_type_id (g_bitfield.glib_get_type);

        /* attributes */
        add_info_attrs (g_bitfield);

        /* Generate members */
        g_bitfield.accept_children (this);
        stack.pop ();
    }

    public override void visit_callback (Gir.Callback g_callback) {
        if (! g_callback.introspectable) {
            return;
        }

        /* return type */
        var v_return_type = build_return_type (g_callback.return_value);

        /* create the delegate */
        var v_delegate = new Delegate (g_callback.name, v_return_type, g_callback.source);
        v_delegate.access = PUBLIC;
        stack.peek ().add_delegate (v_delegate);
        stack.push (v_delegate);

        /* cname */
        if (g_callback.parent_node is Gir.Namespace) {
            /* string cname = generate_identifier_cname (g_callback);
             * 
             * generate_identifier_cname() doesn't work for a Gir.Callback
             * instance, because after casting to a Gir.Identifier, the "name"
             * property returns null. I'm reasonably sure this is a Vala bug,
             * but haven't looked into it yet. Apply a workaround for now.
             */
            var ns_prefix = get_ns_prefix (g_callback);
            string cname = ns_prefix == null ? null : ns_prefix + g_callback.name;
    
            if (g_callback.c_type != cname) {
                v_delegate.set_attribute_string ("CCode", "cname", g_callback.c_type);
            }
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (g_callback);
        }

        /* attributes */
        add_info_attrs (g_callback);

        /* throws */
        if (g_callback.throws) {
            v_delegate.add_error_type (new Vala.ErrorType (null, null));
        }

        /* Generate parameters */
        g_callback.accept_children (this);
        stack.pop ();
    }

    public override void visit_class (Gir.Class g_class) {
        if (!g_class.introspectable) {
            return;
        }

        /* create class */
        Class v_class = new Class (g_class.name, g_class.source);
        v_class.access = PUBLIC;
        v_class.is_abstract = g_class.abstract;
        v_class.is_sealed = g_class.final;
        stack.peek ().add_class (v_class);
        stack.push (v_class);

        /* parent class */
        if (g_class.parent != null) {
            var base_type = DataTypeBuilder.from_name (g_class.parent, g_class.source);
            v_class.add_base_type (base_type);
        }

        /* implemented interfaces */
        foreach (var g_imp in g_class.implements) {
            var imp_type = DataTypeBuilder.from_name (g_imp.name, g_imp.source);
            v_class.add_base_type (imp_type);
        }

        /* cname */
        if (g_class.c_type != generate_identifier_cname (g_class)) {
            v_class.set_attribute_string ("CCode", "cname", g_class.c_type);
        }

        /* attributes */
        add_info_attrs (g_class);

        /* type_cname */
        if (g_class.glib_type_struct != null
                && g_class.glib_type_struct != generate_type_cname (g_class)) {
            var type_cname = get_ns_prefix (g_class) + g_class.glib_type_struct;
            v_class.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* type_id */
        set_type_id (g_class.glib_get_type);

        /* ref_function */
        var custom_ref = find_method_with_suffix (g_class, "_ref");
        if (g_class.glib_ref_func != null) {
            v_class.set_attribute_string ("CCode", "ref_function", g_class.glib_ref_func);
        }
        else if (custom_ref != null) {
            v_class.set_attribute_string ("CCode", "ref_function", custom_ref);
        }

        /* unref_function */
        var custom_unref = find_method_with_suffix (g_class, "_unref");
        if (g_class.glib_unref_func != null) {
            v_class.set_attribute_string ("CCode", "unref_function", g_class.glib_unref_func);
        }
        else if (custom_unref != null) {
            v_class.set_attribute_string ("CCode", "unref_function", custom_unref);
        }

        /* always provide constructor in generated bindings
         * to indicate that implicit Object () chainup is allowed */
        bool no_introspectable_constructors = true;
        foreach (var ctor in g_class.constructors) {
            if (ctor.introspectable) {
                no_introspectable_constructors = false;
                break;
            }
        }

        if (no_introspectable_constructors) {
            var v_cm = new CreationMethod (null, null, g_class.source);
            v_cm.has_construct_function = false;
            v_cm.access = PROTECTED;
            v_class.add_method (v_cm);
        }

        /* Generate members */
        g_class.accept_children (this);
        stack.pop ();
    }

    public override void visit_constant (Gir.Constant g_constant) {
        if (! g_constant.introspectable) {
            return;
        }

        /* type */
        var type = new DataTypeBuilder (g_constant.anytype).build ();

        /* create constant */
        var v_const = new Constant (g_constant.name, type, null, g_constant.source);
        v_const.access = PUBLIC;
        stack.peek ().add_constant (v_const);
        stack.push (v_const);

        /* cname */
        v_const.set_attribute_string ("CCode", "cname", g_constant.c_type);

        /* attributes */
        add_info_attrs (g_constant);
        stack.pop ();
    }

    public override void visit_constructor (Gir.Constructor g_constructor) {
        if (! g_constructor.introspectable || is_constructor_for_abstract_class (g_constructor)) {
            return;
        }
        
        /* name */
        var name = get_constructor_name (g_constructor);

        /* create the constructor */
        var v_cm = new CreationMethod (null, name, g_constructor.source);
        v_cm.access = PUBLIC;
        v_cm.has_construct_function = false;
        stack.peek ().add_method (v_cm);
        stack.push (v_cm);

        /* c name */
        if (g_constructor.name != "new" && (! g_constructor.name.has_prefix ("new_"))) {
            v_cm.set_attribute_string ("CCode", "cname", g_constructor.c_identifier);
        }

        /* attributes and deprecation */
        add_info_attrs (g_constructor);
        add_callable_attrs (g_constructor);

        /* return type annotation */
        if (g_constructor.parent_node is Gir.Class) {
            var parent_c_type = ((Gir.Class) g_constructor.parent_node).c_type;
            var return_type = g_constructor.return_value.anytype;
            var return_c_type = (return_type as Gir.TypeRef)?.c_type;
            if (return_c_type != null &&
                    (parent_c_type == null || return_c_type != parent_c_type + "*")) {
                v_cm.set_attribute_string ("CCode", "type", return_c_type);
            }
        }

        /* throws */
        if (g_constructor.throws) {
            v_cm.add_error_type (new Vala.ErrorType (null, null));
        }

        /* Generate parameters */
        g_constructor.accept_children (this);
        stack.pop ();
    }

    public override void visit_enumeration (Gir.Enumeration g_enum) {
        if (!g_enum.introspectable) {
            return;
        }

        Symbol v_sym;
        if (g_enum.glib_error_domain != null) {
            /* create error domain */
            v_sym = new ErrorDomain (g_enum.name, g_enum.source);
            stack.peek ().add_error_domain ((ErrorDomain) v_sym);
        } else {
            /* create enum */
            v_sym = new Enum (g_enum.name, g_enum.source);
            stack.peek ().add_enum ((Enum) v_sym);
        }

        v_sym.access = PUBLIC;
        stack.push (v_sym);

        /* cname */
        if (g_enum.c_type != generate_identifier_cname (g_enum)) {
            v_sym.set_attribute_string ("CCode", "cname", g_enum.c_type);
        }

        /* cprefix */
        string? common_prefix = null;
        foreach (var g_member in g_enum.members) {
            var name = g_member.c_identifier.ascii_up ().replace ("-", "_");
            calculate_common_prefix (ref common_prefix, name);
        }
        v_sym.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* type_id */
        set_type_id (g_enum.glib_get_type);

        /* attributes */
        add_info_attrs (g_enum);

        /* Generate members */
        g_enum.accept_children (this);
        stack.pop ();

    }

    public override void visit_field (Gir.Field g_field) {
        if (!g_field.introspectable
                || g_field.private
                || g_field.name == "priv"
                || g_field.anytype == null) {
            return;
        }

        /* Skip the parent instance pointer in a class */
        if (g_field.parent_node is Gir.Class
                && ((Gir.Class) g_field.parent_node).parent != null
                && ((Gir.Class) g_field.parent_node).fields[0] == g_field) {
            return;
        }

        /* skip the parent instance pointer in a record */
        if (g_field.parent_node is Gir.Record
                && ((Gir.Record) g_field.parent_node).glib_is_gtype_struct_for != null
                && ((Gir.Record) g_field.parent_node).fields[0] == g_field) {
            return;
        }

        /* Everything else has precedence over a field */
        if (stack.peek ().scope.lookup (g_field.name) != null) {
            return;
        }

        /* type */
        var v_type = new DataTypeBuilder (g_field.anytype).build ();

        /* create field */
        var v_field = new Field (g_field.name, v_type, null, g_field.source);
        v_field.access = PUBLIC;
        stack.peek ().add_field (v_field);
        stack.push (v_field);

        /* attributes */
        add_info_attrs (g_field);

        /* array attributes */
        if (v_type is ArrayType) {
            var g_arr = (Gir.Array) g_field.anytype;
            unowned var v_arr_type = (ArrayType) v_type;

            /* fixed length */
            if (g_arr.fixed_size != -1) {
                v_arr_type.fixed_length = true;
                v_arr_type.length = new IntegerLiteral (g_arr.fixed_size.to_string ());
                v_field.set_attribute_bool ("CCode", "array_length", false);
            }

            /* length in another field */
            else if (g_arr.length != -1) {
                var fields = get_gir_fields (g_field.parent_node);
                var g_length_field = fields[g_arr.length];
                var g_type = g_length_field.anytype;
                var name = g_length_field.name;
                v_field.set_attribute_string ("CCode", "array_length_cname", name);

                /* int is the default and can be omitted */
                var g_type_name = g_type.name;
                if (g_type_name != "gint") {
                    v_field.set_attribute_string ("CCode", "array_length_type", g_type_name);
                }
            }

            /* no length specified */
            else {
                v_field.set_attribute_bool ("CCode", "array_length", false);
                /* If zero-terminated is missing, there's no length, there's no
                * fixed size, and the name attribute is unset, then zero-terminated
                * is true. */
                if (g_arr.zero_terminated || g_arr.name == null) {
                    v_field.set_attribute_bool ("CCode", "array_null_terminated", true);
                }
            }
        }

        stack.pop ();
    }

    public override void visit_function (Gir.Function g_function) {
        if (! g_function.introspectable
                || is_invoker_method (g_function)
                || is_signal_emitter_method (g_function)
                || is_property_accessor (g_function)) {
            return;
        }
        
        /* return type */
        var v_return_type = build_return_type (g_function.return_value);

        /* create a static method */
        var v_method = new Method (g_function.name, v_return_type, g_function.source);
        v_method.access = PUBLIC;
        v_method.binding = STATIC;
        stack.peek ().add_method (v_method);
        stack.push (v_method);

        /* When the first parameter is the parent type, the function should be
         * an instance method after all. This is usually the case for functions
         * operating on enums. */
        if (g_function.parameters != null && !g_function.parameters.parameters.is_empty) {
            var self = g_function.parameters.parameters[0];
            if (self.direction == UNDEFINED || self.direction == IN || self.caller_allocates) {
                var parent_type = (g_function.parent_node as Gir.Identifier)?.name;
                var self_type = (self.anytype as Gir.TypeRef)?.name;
                if (parent_type != null && self_type != null && self_type == parent_type) {
                    v_method.binding = INSTANCE;
                }                
            }
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (g_function);
        }

        /* c name */
        var c_identifier = g_function.c_identifier;
        if (c_identifier != generate_symbol_cname (g_function)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* attributes and deprecation */
        add_info_attrs (g_function);
        add_callable_attrs (g_function);

        /* throws */
        if (g_function.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        /* Generate parameters */
        g_function.accept_children (this);
        stack.pop ();
    }

    public override void visit_interface (Gir.Interface g_iface) {
        if (!g_iface.introspectable) {
            return;
        }

        /* create interface */
        var v_iface = new Interface (g_iface.name, g_iface.source);
        v_iface.access = PUBLIC;
        stack.peek ().add_interface (v_iface);
        stack.push (v_iface);

        /* prerequisite interfaces */
        foreach (var g_prereq in g_iface.prerequisites) {
            var prereq_type = DataTypeBuilder.from_name (g_prereq.name, g_prereq.source);
            v_iface.add_prerequisite (prereq_type);
        }

        /* when no prerequisites were specified, GLib.Object is the default */
        if (g_iface.prerequisites.is_empty) {
            v_iface.add_prerequisite (DataTypeBuilder.from_name ("GLib.Object"));
        }

        /* cname */
        if (g_iface.c_type != generate_identifier_cname (g_iface)) {
            v_iface.set_attribute_string ("CCode", "cname", g_iface.c_type);
        }

        /* attributes */
        add_info_attrs (g_iface);

        /* type_cname */
        if (g_iface.glib_type_struct != null
                && g_iface.glib_type_struct != generate_type_cname (g_iface)) {
            var type_cname = get_ns_prefix (g_iface) + g_iface.glib_type_struct;
            v_iface.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* type_id */
        set_type_id (g_iface.glib_get_type);

        /* Generate members */
        g_iface.accept_children (this);
        stack.pop ();
    }

    public override void visit_member (Gir.Member g_member) {
        var v_sym = stack.peek ();
        var common_prefix = v_sym.get_attribute_string ("CCode", "cprefix");
        var name = g_member.c_identifier
                           .substring (common_prefix.length)
                           .ascii_up ()
                           .replace ("-", "_");
        if (v_sym is Enum) {
            var v_value = new Vala.EnumValue (name, null, g_member.source, null);
            unowned var v_enum = (Enum) v_sym;
            v_enum.add_value (v_value);
        } else {
            var value = new IntegerLiteral (g_member.value);
            unowned var v_err = (ErrorDomain) v_sym;
            v_err.add_code (new ErrorCode.with_value (name, value, g_member.source));
        }
    }

    public override void visit_method (Gir.Method g_method) {
        if (! g_method.introspectable
                || is_invoker_method (g_method)
                || is_signal_emitter_method (g_method)
                || is_async_finish_method (g_method)
                || is_property_accessor (g_method)) {
            return;
        }

        /* return type */
        var v_return_type = build_return_type (g_method.return_value);

        /* the method itself */
        var v_method = new Method (g_method.name, v_return_type, g_method.source);
        v_method.access = PUBLIC;
        stack.peek ().add_method (v_method);
        stack.push (v_method);

        /* c name */
        var c_identifier = g_method.c_identifier;
        if (c_identifier != generate_symbol_cname (g_method)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* attributes and deprecation */
        add_info_attrs (g_method);
        add_callable_attrs (g_method);

        /* throws */
        if (g_method.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        /* async */
        if (g_method.glib_finish_func != null) {
            /* mark as async method */
            v_method.coroutine = true;

            /* copy the return-type from the finish-func */
            Gir.Method g_finish_func = get_async_finish_method (g_method);
            v_method.return_type = build_return_type (g_finish_func.return_value);

            /* when the finish-func throws */
            if ((! g_method.throws) && g_finish_func.throws) {
                v_method.add_error_type (new Vala.ErrorType (null, null));
            }
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (g_method);
        }

        /* Generate parameters */
        g_method.accept_children (this);
        stack.pop ();
    }

    public override void visit_namespace (Gir.Namespace g_ns) {
        Namespace v_ns = new Namespace (g_ns.name, g_ns.source);
        stack.peek ().add_namespace (v_ns);
        stack.push (v_ns);

        /* attributes */
        if (g_ns.parent_node is Gir.Repository) {
            v_ns.set_attribute_string ("CCode", "gir_namespace", g_ns.name);
            v_ns.set_attribute_string ("CCode", "gir_version", g_ns.version);
            v_ns.set_attribute_string ("CCode", "cprefix", g_ns.c_identifier_prefixes);
            v_ns.set_attribute_string ("CCode", "lower_case_cprefix", g_ns.c_symbol_prefixes + "_");
        }

        /* cheader_filename attribute */
        var c_includes = ((Gir.Repository) g_ns.parent_node).c_includes;
        var names = new string[c_includes.size];
        for (int i = 0; i < c_includes.size; i++) {
            names[i] = c_includes[i].name;
        }
        var cheader_filename = string.joinv (",", names);
        v_ns.set_attribute_string ("CCode", "cheader_filename", cheader_filename);

        /* Generate members */
        g_ns.accept_children (this);
        stack.pop ();
    }

    public override void visit_parameters (Gir.Parameters g_parameters) {
        var g_call = g_parameters.parent_node as Gir.Callable;
        var v_call = stack.peek () as Vala.Callable;

        /* set "DestroysInstance" attribute when ownership of `this` is
         * transferred to the method: This means the method will consume the
         * instance. */
        if (g_parameters.instance_parameter?.transfer_ownership == FULL) {
            v_call.set_attribute ("DestroysInstance", true);
        }

        for (int i = 0; i < g_parameters.parameters.size; i++) {
            Gir.Parameter g_par = g_parameters.parameters[i];
            Vala.Parameter v_par;

            /* varargs */
            if (g_par.varargs != null) {
                v_par = new Vala.Parameter.with_ellipsis (g_par.source);
                v_call.add_parameter (v_par);
                return;
            }

            /* instance_pos attribute: Specifies the position of the user_data
             * argument where Vala can pass the `this` parameter to treat the 
             * callback like an instance method. */
            if (g_call is Gir.Callback && g_par.closure != -1) {
                var pos = get_param_pos (g_call, i);
                v_call.set_attribute_double ("CCode", "instance_pos", pos);
            }

            /* skip hidden parameters */
            if (is_hidden_param (g_call, i)) {
                continue;
            }

            /* skip the first parameter of a function that was converted to an
             * instance method, because it acts as the instance parameter */
            if (i == 0 && g_call is Gir.Function && v_call is Vala.Method
                    && ((Vala.Method) v_call).binding == INSTANCE) {
                continue;
            }

            /* determine the datatype */
            var v_type = new DataTypeBuilder (g_par.anytype).build ();
            v_type.nullable = g_par.nullable || (g_par.allow_none && g_par.direction != OUT);

            /* create the parameter */
            v_par = new Vala.Parameter (g_par.name, v_type, g_par.source);
            v_call.add_parameter (v_par);
            stack.push (v_par);

            /* array parameter */
            if (v_type is ArrayType) {
                unowned var v_arr_type = (ArrayType) v_type;
                add_array_attrs (g_call, v_arr_type, g_par.anytype as Gir.Array);
                v_arr_type.element_type.value_owned = true;
            }

            /* out or ref parameter */
            if (g_par.direction == OUT) {
                v_par.direction = ParameterDirection.OUT;
            } else if (g_par.direction == INOUT) {
                v_par.direction = ParameterDirection.REF;
            }

            /* ownership transfer */
            if (g_par.transfer_ownership != NONE || g_par.destroy != -1) {
                v_type.value_owned = true;
            }

            /* ownership transfer of generic type arguments */
            foreach (var type_arg in v_type.get_type_arguments ()) {
                type_arg.value_owned = g_par.transfer_ownership != CONTAINER;
            }

            /* null-initializer for GCancellable parameters */
            if (v_type.to_string () == "GLib.Cancellable?") {
                v_par.initializer = new NullLiteral ();
            }

            stack.pop ();
        }
    }

    public override void visit_property (Gir.Property g_property) {
        if (!g_property.introspectable) {
            return;
        }

        var g_identifier = (Gir.Identifier) g_property.parent_node;

        /* data type */
        var v_type = new DataTypeBuilder (g_property.anytype).build ();
        v_type.value_owned = g_property.transfer_ownership != NONE;

        /* name */
        var name = g_property.name.replace ("-", "_");

        /* create the property */
        var v_prop = new Property (name, v_type, null, null, g_property.source);
        v_prop.access = PUBLIC;
        v_prop.is_abstract = g_property.parent_node is Gir.Interface;
        stack.peek ().add_property (v_prop);
        stack.push (v_prop);

        /* get-accessor */
        if (g_property.readable) {
            var getter_type = v_type.copy ();
            var getter = find_method_by_name (g_identifier, g_property.getter);
            if (getter != null) {
                getter_type.value_owned = getter.return_value.transfer_ownership != NONE;

                /* if the getter is virtual, then the property is virtual */
                if (is_invoker_method (getter)) {
                    v_prop.is_virtual = true;
                }

                /* getter method should start with "get_" */
                if (! getter.name.has_prefix ("get_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else {
                v_prop.set_attribute ("NoAccessorMethod", true);
                getter_type.value_owned = true;
            }

            v_prop.get_accessor = new PropertyAccessor (
                true,  /* readable */
                false, /* not writable */
                false, /* not construct */
                getter_type,
                null,
                null
            );
        }

        /* set-accessor */
        if (g_property.writable || g_property.construct_only) {
            var setter_type = v_type.copy ();
            var setter = find_method_by_name (g_identifier, g_property.setter);
            if (setter != null) {
                setter_type.value_owned = setter.parameters.parameters[0].transfer_ownership != NONE;

                /* setter method should start with "set_" */
                if (! setter.name.has_prefix ("set_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else if (! g_property.construct_only) {
                v_prop.set_attribute ("NoAccessorMethod", true);
            }

            if (v_prop.get_attribute ("NoAccessorMethod") != null) {
                setter_type.value_owned = false;
            }

            v_prop.set_accessor = new PropertyAccessor (
                false, /* not readable */
                g_property.writable && !g_property.construct_only,
                g_property.construct_only || g_property.construct,
                setter_type,
                null,
                null
            );
        }

        /* When accessor method was not found, set getter and setter ownership
         * to gobject defaults */
        if (v_prop.get_attribute ("NoAccessorMethod") != null) {
            if (v_prop.get_accessor != null) {
                v_prop.get_accessor.value_type.value_owned = true;
            }
            if (v_prop.set_accessor != null) {
                v_prop.set_accessor.value_type.value_owned = false;
            }
        }

        /* array attributes */
        if (v_type is ArrayType) {
            unowned var v_arr_type = (ArrayType) v_type;
            var g_arr_type = g_property.anytype as Gir.Array;
            add_array_attrs (null, v_arr_type, g_arr_type);
            v_arr_type.element_type.value_owned = true;
        }

        /* attributes */
        add_info_attrs (g_property);

        /* there is no information about the internal ownership, so assume
         * `owned` as default */
        v_prop.property_type.value_owned = true;

        stack.pop ();
    }

    public override void visit_record (Gir.Record g_record) {
        if (!g_record.introspectable || g_record.glib_is_gtype_struct_for != null) {
            return;
        }

        /* Check whether this record is a plain struct or a boxed type */
        bool is_boxed_type = g_record.glib_get_type != null;

        /* create a compact class (for a boxed type) or a plain struct */
        Symbol v_sym;
        if (is_boxed_type) {
            v_sym = new Class (g_record.name, g_record.source);
            v_sym.set_attribute ("Compact", true);
            stack.peek ().add_class ((Class) v_sym);
        } else {
            v_sym = new Struct (g_record.name, g_record.source);
            stack.peek ().add_struct ((Struct) v_sym);
        }
        
        v_sym.access = PUBLIC;
        stack.push (v_sym);

        /* c_name */
        if (g_record.c_type != generate_identifier_cname (g_record)) {
            v_sym.set_attribute_string ("CCode", "cname", g_record.c_type);
        }

        /* type_id */
        set_type_id (g_record.glib_get_type);

        /* attributes */
        add_info_attrs (g_record);

        /* copy_function */
        var custom_ref = find_method_with_suffix (g_record, "_ref");
        if (g_record.copy_function != null) {
            v_sym.set_attribute_string ("CCode", "copy_function", g_record.copy_function);
        }
        /* custom ref function */
        else if (custom_ref != null) {
            v_sym.set_attribute_string ("CCode", "ref_function", custom_ref);
        }
        /* boxed types default to g_boxed_copy */
        else if (g_record.glib_get_type != null) {
            v_sym.set_attribute_string ("CCode", "copy_function", "g_boxed_copy");
        }

        /* free_function */
        var custom_unref = find_method_with_suffix (g_record, "_unref");
        if (g_record.free_function != null) {
            v_sym.set_attribute_string ("CCode", "free_function", g_record.free_function);
        }
        /* custom unref function */
        else if (custom_unref != null) {
            v_sym.set_attribute_string ("CCode", "unref_function", custom_unref);
        }
        /* boxed types default to g_boxed_free */
        else if (g_record.glib_get_type != null) {
            v_sym.set_attribute_string ("CCode", "free_function", "g_boxed_free");
        }

        /* Generate members */
        g_record.accept_children (this);
        stack.pop ();
    }

    public override void visit_repository (Gir.Repository repository) {
        /* Generate namespace(s) */
        repository.accept_children (this);
    }

    public override void visit_signal (Gir.Signal g_signal) {
        if (! g_signal.introspectable) {
            return;
        }

        /* name */
        var name = g_signal.name.replace ("-", "_");

        /* return type */
        var v_return_type = build_return_type (g_signal.return_value);

        /* create the signal */
        var v_sig = new Vala.Signal (name, v_return_type, g_signal.source);
        v_sig.access = PUBLIC;
        stack.peek ().add_signal (v_sig);
        stack.push (v_sig);

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (g_signal);
        }

        /* attributes */
        add_info_attrs (g_signal);

        /* find emitter method */
        foreach (var g_method in get_gir_methods (g_signal.parent_node)) {
            if (equal_names (g_signal.name, g_method.name)) {
                v_sig.set_attribute ("HasEmitter", true);
            }
        }
        
        /* find virtual emitter method */
        foreach (var g_vm in get_gir_virtual_methods (g_signal.parent_node)) {
            if (equal_names (g_signal.name, g_vm.name)) {
                v_sig.is_virtual = true;
            }
        }

        /* Generate parameters */
        g_signal.accept_children (this);
        stack.pop ();
    }

    public override void visit_virtual_method (Gir.VirtualMethod g_virtual_method) {
        if (! g_virtual_method.introspectable
                || is_signal_emitter_method (g_virtual_method)
                || is_property_accessor (g_virtual_method)) {
            return;
        }

        /* return type */
        var v_return_type = build_return_type (g_virtual_method.return_value);

        /* the method itself */
        var v_method = new Method (g_virtual_method.name, v_return_type, g_virtual_method.source);
        v_method.access = PUBLIC;
        stack.peek ().add_method (v_method);
        stack.push (v_method);

        if (g_virtual_method.parent_node is Gir.Interface) {
            v_method.is_abstract = true;
        } else {
            v_method.is_virtual = true;
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (g_virtual_method);
        }

        /* attributes and deprecation */
        add_info_attrs (g_virtual_method);
        add_callable_attrs (g_virtual_method);

        /* "NoWrapper" attribute when no invoker method with the same name */
        var invoker_method = get_invoker_method (g_virtual_method);
        var invoker_name = invoker_method?.name;
        if (invoker_method == null || invoker_name != g_virtual_method.name) {
            v_method.set_attribute ("NoWrapper", true);
        }

        /* "vfunc_name" attribute when invoker method has another name */
        if (invoker_method != null && invoker_name != g_virtual_method.name) {
            v_method.set_attribute_string ("CCode", "vfunc_name", invoker_name);
        }

        /* throws */
        if (g_virtual_method.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        /* Generate parameters */
        g_virtual_method.accept_children (this);
        stack.pop ();
    }

    /********************/
    /* Helper functions */
    /********************/

    /* Compare method and signal names (treating "-" and "_" as equal) */
    private static bool equal_names (string? a, string? b) {
        return a != null && b != null && a.replace ("-", "_") == b.replace ("-", "_");
    }

    /* Set the "has_type_id" or "type_id" CCode attribute */
    private void set_type_id (string? glib_get_type) {
        var v_sym = stack.peek ();

        var type_id = glib_get_type;
        if (type_id == null) {
            v_sym.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            if (! type_id.has_suffix (")")) {
                type_id += " ()";
            }
            
            v_sym.set_attribute_string ("CCode", "type_id", type_id);
        }
    }

    /* Find a method in this type with the requested name */
    private static Gir.Method? find_method_by_name (Gir.Identifier g_identifier, string? name) {
        if (name != null) {
            foreach (var m in get_gir_methods (g_identifier)) {
                if (m.name == name) {
                    return m;
                }
            }
        }

        return null;
    }

    /* Find a method in this type whose name ends with the requested suffix */
    private static string? find_method_with_suffix (Gir.Identifier g_identifier, string suffix) {
        foreach (var g_method in get_gir_methods (g_identifier)) {
            if (g_method.c_identifier != null && g_method.c_identifier.has_suffix (suffix)) {
                return g_method.c_identifier;
            }
        }

        return null;
    }

    /* Get the C prefix of this identifier */
    private static string? get_ns_prefix (Gir.Identifier g_identifier) {
        if (g_identifier.parent_node is Gir.Namespace) {
            var ns = (Gir.Namespace) g_identifier.parent_node;
            return ns.c_identifier_prefixes ?? ns.c_prefix ?? ns.name;
        }

        return null;
    }
    
    /* Generate the Vala DataType of this method's return type */
    private DataType build_return_type (Gir.ReturnValue g_return) {
        /* create the return type */
        var v_return_type = new DataTypeBuilder (g_return.anytype).build ();

        /* nullability */
        v_return_type.nullable = g_return.nullable || g_return.allow_none;

        /* Functions which return structs currently generate incorrect C code
         * because valac assumes the struct is actually an out argument.
         * The return value of functions returning structs must be marked as
         * nullable to prevent valac from generating an out argument in C.
         * To determine if the return value is a struct, the symbol first needs
         * to be resolved. */
        if (!v_return_type.nullable) {
            var name = DataTypeBuilder.vala_datatype_name (v_return_type);
            var symbol = lookup (name);
            if (symbol is Struct && !((Struct) symbol).is_simple_type ()) {
                v_return_type.nullable = true;
            }
        }

        /* ownership transfer */
        v_return_type.value_owned = g_return.transfer_ownership != NONE;
        foreach (var type_arg in v_return_type.get_type_arguments ()) {
            type_arg.value_owned = g_return.transfer_ownership != CONTAINER;
        }
        
        return v_return_type;
    }

    /* Set array attributes on a method that returns an array type */
    private void add_array_return_type_attributes (Gir.Callable g_call) {
        var v_method = stack.peek () as Callable;
        unowned var v_type = (ArrayType) v_method.return_type;
        var g_type = g_call.return_value.anytype as Gir.Array;
        add_array_attrs (g_call, v_type, g_type);
        v_type.element_type.value_owned = true;
    }

    /* Return `null` if the constructor is named "new", otherwise return the
     * constructor name without the "new_" prefix (if any) */
    private static string? get_constructor_name (Gir.Constructor g_constructor) {
        if (g_constructor.name == "new") {
            return null;
        } else if (g_constructor.name.has_prefix ("new_")) {
            return g_constructor.name.substring ("new_".length);
        } else {
            return g_constructor.name;
        }
    }

    private static bool is_constructor_for_abstract_class (Gir.Constructor g_constructor) {
        return g_constructor.parent_node is Gir.Class
                && ((Gir.Class) g_constructor.parent_node).abstract;
    }

    /* Find a virtual method with the same name as this method. */
    private static bool is_invoker_method (Gir.Callable g_call) {
        if (! (g_call is Gir.Method || g_call is Gir.Function)) {
            return false;
        }

        foreach (var vm in get_gir_virtual_methods (g_call.parent_node)) {
            if (equal_names (g_call.name, vm.name)) {
                return true;
            }
        }

        return false;
    }

    /* Find a method or function that invokes this virtual method. */
    private static Gir.Callable? get_invoker_method (Gir.Callable g_call) {
        unowned var g_virtual_method = g_call as Gir.VirtualMethod;
        if (g_virtual_method == null) {
            return null;
        }

        foreach (var m in get_gir_methods (g_virtual_method.parent_node)) {
            if (g_virtual_method.invoker == m.name || equal_names (g_virtual_method.name, m.name)) {
                return m;
            }
        }

        foreach (var f in get_gir_functions (g_virtual_method.parent_node)) {
            if (g_virtual_method.invoker == f.name || equal_names (g_virtual_method.name, f.name)) {
                return f;
            }
        }

        return null;
    }

    /* Check if this method is the glib:finish-func of an async method */
    private static bool is_async_finish_method (Gir.Method g_method) {
        foreach (var m in get_gir_methods (g_method.parent_node)) {
            if (m.glib_finish_func == g_method.name) {
                return true;
            }
        }

        return false;
    }

    /* Find the glib:finish-func of this async method */
    private static Gir.Method? get_async_finish_method (Gir.Method g_method) {
        var name = g_method.glib_finish_func;
        foreach (var m in get_gir_methods (g_method.parent_node)) {
            if (m.name == name || m.c_identifier == name) {
                return m;
            }
        }

        Report.error (g_method.source, "Cannot find finish-func \"%s\"", name);
        return null;
    }

    /* Find a signal with the same name and type signature as this method or
     * virtual method. */
    private static bool is_signal_emitter_method (Gir.Callable g_call) {
        if (! (g_call is Gir.Method || g_call is Gir.VirtualMethod)) {
            return false;
        }

        foreach (var g_signal in get_gir_signals (g_call.parent_node)) {
            if (equal_names (g_call.name, g_signal.name)) {
                return true;
            }
        }

        return false;
    }

    /* Find a property with the same name as this method. If found, the property
     * takes precedence. */
    private static bool is_property_accessor (Gir.Callable g_call) {
        foreach (var p in get_gir_properties (g_call.parent_node)) {
            if (equal_names (p.name, g_call.name)) {
                return true;
            }
        }

        return false;
    }

    /* Generate the C function name from the GIR name and all prefixes, for
     * example "gtk_window_new" */
    private static string generate_symbol_cname (Gir.Callable call) {
        var sb = new StringBuilder (call.name);
        unowned var node = call.parent_node;
        while (node != null) {
            /* use the symbol-prefix if it is defined */
            string? prefix = null;
            if (node is Gir.Interface) {
                prefix = ((Gir.Interface) node).c_symbol_prefix;
            } else if (node is Gir.Class) {
                prefix = ((Gir.Class) node).c_symbol_prefix;
            } else if (node is Gir.Boxed) {
                prefix = ((Gir.Boxed) node).c_symbol_prefix;
            } else if (node is Gir.Record) {
                prefix = ((Gir.Record) node).c_symbol_prefix;
            } else if (node is Gir.Union) {
                prefix = ((Gir.Union) node).c_symbol_prefix;
            } else if (node is Gir.Repository) {
                prefix = ((Gir.Repository) node).c_symbol_prefixes;
            } else if (node is Gir.Namespace) {
                prefix = ((Gir.Namespace) node).c_symbol_prefixes;
            }

            /* for types without a symbol-prefix defined, use the name */
            if (prefix == null && node is Gir.Identifier) {
                prefix = Symbol.camel_case_to_lower_case (((Gir.Identifier) node).name);
            }

            if (prefix != null) {
                sb.prepend (prefix + "_");
            }

            node = node.parent_node;
        }

        return sb.str;
    }

    /* Generate C name of an identifier: for example "GtkWindow" */
    private static string? generate_identifier_cname (Gir.Identifier g_identifier) {
        var ns_prefix = get_ns_prefix (g_identifier);
        return ns_prefix == null ? null : ns_prefix + g_identifier.name;
    }

    /* Generate C name of the TypeClass/TypeInterface of a class/interface,
     * for example "GtkWindowClass" */
    private static string? generate_type_cname (Gir.Identifier g_identifier) {
        if (g_identifier is Gir.Class) {
            return g_identifier.name + "Class";
        } else if (g_identifier is Gir.Interface) {
            return g_identifier.name + "Iface";
        } else {
            return null;
        }
    }

    /* Determine the longest prefix that all enum members have in common */
    private static void calculate_common_prefix (ref string? prefix, string cname) {
        if (prefix == null) {
            prefix = cname;
            while (prefix.length > 0 && (! prefix.has_suffix ("_"))) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        } else {
            while (! cname.has_prefix (prefix)) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        }

        while (prefix.length > 0 && (! prefix.has_suffix ("_"))) {
            prefix = prefix.substring (0, prefix.length - 1);
        }
    }

    /* Set version, deprecated and deprecated_since attributes */
    private void add_info_attrs (Gir.InfoAttrs g_info_attrs) {
        var v_sym = stack.peek ();

        /* version */
        v_sym.version.since = g_info_attrs.version;

        /* deprecated and deprecated_since */
        if (g_info_attrs.deprecated) {
            /* omit deprecation attributes when the parent already has them */
            var parent = g_info_attrs.parent_node as Gir.InfoAttrs;
            if (parent == null || !parent.deprecated) {
                v_sym.version.deprecated = true;
                v_sym.version.deprecated_since = g_info_attrs.deprecated_version;
            }
        }
    }

    /* Set replacement and finish-func attributes */
    private void add_callable_attrs (Gir.CallableAttrs g_callable_attrs) {
        var v_sym = stack.peek ();

        /* replacement */
        if (g_callable_attrs.moved_to != null) {
            v_sym.version.replacement = g_callable_attrs.moved_to;
        }

        /* finish-func */
        if (g_callable_attrs.glib_finish_func != null && g_callable_attrs.name != null) {
            var name = g_callable_attrs.name;
            if (name.has_suffix ("_async")) {
                name = name.substring (0, name.length - 6);
            }

            var expected = name + "_finish";
            if (g_callable_attrs.glib_finish_func != expected) {
                v_sym.set_attribute_string ("CCode", "finish_name", g_callable_attrs.glib_finish_func);
            }
		}
    }

    /* Set attributes to specify the array length */
    private void add_array_attrs (Gir.Callable? g_call, ArrayType v_type, Gir.Array g_arr) {
        var v_sym = stack.peek ();

        /* don't emit array attributes for a GLib.GenericArray */
        if (g_arr.name == "GLib.PtrArray") {
            return;
        }

        /* fixed length */
        if (g_arr.fixed_size != -1) {
            v_type.fixed_length = true;
            v_type.length = new IntegerLiteral (g_arr.fixed_size.to_string ());
            v_sym.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another parameter */
        else if (g_arr.length != -1 && g_call != null) {
            var pos = get_param_pos (g_call, g_arr.length);
            var lp = g_call.parameters.parameters[g_arr.length];
            var g_type = lp.anytype;

            v_sym.set_attribute_double ("CCode", "array_length_pos", pos);

            if (v_sym is Vala.Parameter) {
                v_sym.set_attribute_string ("CCode", "array_length_cname", lp.name);
            }

            /* int is the default and can be omitted */
            if (g_type.name != "gint") {
                v_sym.set_attribute_string ("CCode", "array_length_type", g_type.name);
            }
        }

        /* no length specified */
        else {
            v_sym.set_attribute_bool ("CCode", "array_length", false);
            /* If zero-terminated is missing, there's no length, there's no
             * fixed size, and the name attribute is unset, then zero-terminated
             * is true. */
            if (g_arr.zero_terminated || g_arr.name == null) {
                v_sym.set_attribute_bool ("CCode", "array_null_terminated", true);
            }
        }
    }

    /* Get the position of this parameter in Vala. Hidden parameters are
     * fractions between the indexes of the visible parameters. */
    private static double get_param_pos (Gir.Callable g_call, int idx) {
        double pos = 0.0;
        for (int i = 0; i <= idx; i++) {
            if (is_hidden_param (g_call, i)) {
                pos += 0.1;
            } else {
                pos = floor (pos) + 1.0;
            }
        }

        return pos;
    }

    /* A parameter is hidden from Vala API when it's an array length parameter,
     * an AsyncReadyCallback parameter, user-data (for a closure), or a
     * destroy-notify callback. */
    private static bool is_hidden_param (Gir.Callable g_call, int idx) {
        foreach (var p in g_call.parameters.parameters) {
            /* user-data for a closure, or destroy-notify callback */
            if (p.closure == idx || p.destroy == idx) {
                return true;
            }

            /* array length */
            var array = p.anytype as Gir.Array;
            if (array?.length == idx) {
                return true;
            }
        }

        /* length of returned array */
        var array = g_call.return_value.anytype as Gir.Array;
        if (array?.length == idx) {
            return true;
        }

        /* GAsycnReadyCallback */
        var g_method = g_call as Gir.Method;
        if (g_method?.glib_finish_func != null) {
            var p = g_method.parameters.parameters[idx];
            var p_type = p.anytype as Gir.TypeRef;
            if (p_type?.c_type == "GAsyncReadyCallback") {
                return true;
            }
        }

        return false;
    }

    /* Find a symbol in the Vala AST */
    private Symbol? lookup (string? name) {
        if (name != null) {
            for (Scope s = stack.peek ().scope; s != null; s = s.parent_scope) {
                var sym = s.lookup (name);
                if (sym != null) {
                    return sym;
                }
            }
        }

        return null;
    }

    /* Get all fields that are declared in this node. When the node doesn't
     * have any fields, an empty list will be returned. */
    private static Vala.List<Gir.Field> get_gir_fields (Gir.Node node) {
        if (node is Gir.AnonymousRecord) {
            return ((Gir.AnonymousRecord) node).fields;
        } else if (node is Gir.Interface) {
            return ((Gir.Interface) node).fields;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).fields;
        } else if (node is Gir.Record) {
            return ((Gir.Record) node).fields;
        } else if (node is Gir.Union) {
            return ((Gir.Union) node).fields;
        } else {
            return new ArrayList<Gir.Field> ();
        }
    }

    /* Get all functions that are declared in this node. When the node doesn't
     * have any functions, an empty list will be returned. */
    private static Vala.List<Gir.Function> get_gir_functions (Gir.Node node) {
        if (node is Gir.Namespace) {
            return ((Gir.Namespace) node).functions;
        } else if (node is Gir.Interface) {
            return ((Gir.Interface) node).functions;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).functions;
        } else if (node is Gir.Boxed) {
            return ((Gir.Boxed) node).functions;
        } else if (node is Gir.Record) {
            return ((Gir.Record) node).functions;
        } else if (node is Gir.Union) {
            return ((Gir.Union) node).functions;
        } else if (node is Gir.Bitfield) {
            return ((Gir.Bitfield) node).functions;
        } else if (node is Gir.Enumeration) {
            return ((Gir.Enumeration) node).functions;
        } else {
            return new ArrayList<Gir.Function> ();
        }
    }

    /* Get all methods that are declared in this node. When the node doesn't
     * have any methods, an empty list will be returned. */
    private static Vala.List<Gir.Method> get_gir_methods (Gir.Node node) {
        if (node is Gir.Interface) {
            return ((Gir.Interface) node).methods;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).methods;
        } else if (node is Gir.Record) {
            return ((Gir.Record) node).methods;
        } else if (node is Gir.Union) {
            return ((Gir.Union) node).methods;
        } else {
            return new ArrayList<Gir.Method> ();
        }
    }

    /* Get all virtual methods that are declared in this node. When the node
     * doesn't have any virtual methods, an empty list will be returned. */
    private static Vala.List<Gir.VirtualMethod> get_gir_virtual_methods (Gir.Node node) {
        if (node is Gir.Interface) {
            return ((Gir.Interface) node).virtual_methods;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).virtual_methods;
        } else {
            return new ArrayList<Gir.VirtualMethod> ();
        }
    }

    /* Get all signals that are declared in this node. When the node doesn't
     * have any signals, an empty list will be returned. */
    private static Vala.List<Gir.Signal> get_gir_signals (Gir.Node node) {
        if (node is Gir.Interface) {
            return ((Gir.Interface) node).signals;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).signals;
        } else {
            return new ArrayList<Gir.Signal> ();
        }
    }
    
    /* Get all properties that are declared in this node. When the node doesn't
     * have any properties, an empty list will be returned. */
    private static Vala.List<Gir.Property> get_gir_properties (Gir.Node node) {
        if (node is Gir.Interface) {
            return ((Gir.Interface) node).properties;
        } else if (node is Gir.Class) {
            return ((Gir.Class) node).properties;
        } else {
            return new ArrayList<Gir.Property> ();
        }
    }

    /* Avoids a dependency on GLib.Math */
    private static double floor (double a) {
        double b = (double) (long) a;
        return a < 0.0 ? b - 1.0 : b;
    }
}