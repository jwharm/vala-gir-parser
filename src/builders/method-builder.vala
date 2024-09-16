/* vala-gir-parser
 * Copyright (C) 2024 Jan-Willem Harmannij
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

public class Builders.MethodBuilder : InfoAttrsBuilder {

    private Gir.Callable g_call;

    public MethodBuilder (Gir.Callable g_call) {
        this.g_call = g_call;

        /* functions returning void and with one out parameter: change the
         * out parameter into a return value. */
        if (! (g_call is Gir.Constructor)) {
            set_out_parameter_as_return_value ();
        }
    }

    public Gir.InfoAttrs info_attrs () {
        return this.g_call;
    }

    public Vala.CreationMethod build_constructor () {
        unowned var g_ctor = (Gir.Constructor) g_call;

        /* name */
        var name = get_constructor_name ();

        /* create the constructor */
        var v_cm = new CreationMethod (null, name, g_ctor.source_reference);
        v_cm.access = PUBLIC;
        v_cm.has_construct_function = false;

        /* c name */
        if (g_ctor.name != "new" && (! g_ctor.name.has_prefix ("new_"))) {
            v_cm.set_attribute_string ("CCode", "cname", g_ctor.c_identifier);
        }

        /* version and deprecation */
        add_version_attrs (v_cm);
        if (g_ctor.moved_to != null) {
            v_cm.version.replacement = g_ctor.moved_to;
        }

        /* return type annotation */
        if (g_ctor.parent_node is Gir.Class) {
            var parent_c_type = ((Gir.Class) g_ctor.parent_node).c_type;
            var return_c_type = ((Gir.TypeRef) g_ctor.return_value.anytype).c_type;
            if (return_c_type != null &&
                    (parent_c_type == null || return_c_type != parent_c_type + "*")) {
                v_cm.set_attribute_string ("CCode", "type", return_c_type);
            }
        }

        /* parameters */
        new ParametersBuilder (g_ctor, v_cm).build_parameters ();

        /* throws */
        if (g_ctor.throws) {
            v_cm.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_cm;
    }

    public Vala.Method build_function () {
        unowned var g_function = (Gir.Function) g_call;
        
        /* return type */
        var v_return_type = build_return_type (g_function.return_value);

        /* create a static method */
        var v_method = new Method (g_function.name, v_return_type, g_function.source_reference);
        v_method.access = PUBLIC;
        v_method.binding = STATIC;

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* c name */
        if (g_function.c_identifier != generate_cname (g_function)) {
            v_method.set_attribute_string ("CCode", "cname", g_function.c_identifier);
        }

        /* version and deprecation */
        add_version_attrs (v_method);
        if (g_function.moved_to != null) {
            v_method.version.replacement = g_function.moved_to;
        }

        /* try to convert struct functions into instance methods */
        if (g_function.parent_node is Gir.Record && has_parameters ()) {

            /* check if the first parameter is an "instance parameter", i.e. it
             * has the type of the enclosing struct */
            var g_rec = (Gir.Record) g_function.parent_node;
            var g_this = g_function.parameters.parameters[0];
            var g_type_name = (g_this.anytype as Gir.TypeRef)?.name;
            var dir_is_ok = g_this.direction == IN || g_this.caller_allocates;
            var type_is_ok = g_type_name == g_rec.name;

            /* if found, remove the first parameter and change the static method
             * into an instance method */
            if (dir_is_ok && type_is_ok) {
                g_function.parameters.parameters.remove_at (0);
                v_method.binding = INSTANCE;
            }
        }

        /* parameters */
        new ParametersBuilder (g_function, v_method).build_parameters ();

        /* throws */
        if (g_function.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Vala.Method build_method () {
        unowned var g_method = (Gir.Method) g_call;

        /* return type */
        var v_return_type = build_return_type (g_method.return_value);

        /* the method itself */
        var v_method = new Method (g_method.name, v_return_type, g_method.source_reference);
        v_method.access = PUBLIC;

        /* c name */
        if (g_method.c_identifier != generate_cname (g_method)) {
            v_method.set_attribute_string ("CCode", "cname", g_method.c_identifier);
        }

        /* version and deprecation */
        add_version_attrs (v_method);
        if (g_method.moved_to != null) {
            v_method.version.replacement = g_method.moved_to;
        }

        /* method with INOUT (ref) instance parameter should be static */
        var g_this = g_method.parameters.instance_parameter;
        if (g_this.direction == INOUT) {
            /* convert the instance parameter into a regular parameter */
            var g_param = (Gir.Parameter) Object.new (typeof (Gir.Parameter),
                attrs: g_this.attrs,
                children: g_this.children,
                source_reference: g_this.source_reference
            );
            g_method.parameters.parameters.insert (0, g_param);
            
            /* change into a static method */
            v_method.binding = STATIC;
        }

        /* parameters */
        new ParametersBuilder (g_method, v_method).build_parameters ();

        /* throws */
        if (g_method.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        /* async */
        if (g_method.glib_finish_func != null) {
            /* mark as async method */
            v_method.coroutine = true;

            /* copy the return-type from the finish-func */
            Gir.Method g_finish_func = get_async_finish_method ();
            v_method.return_type = build_return_type (g_finish_func.return_value);

            /* when the finish-func throws */
            if ((! g_method.throws) && g_finish_func.throws) {
                v_method.add_error_type (new Vala.ErrorType (null, null));
            }
        }

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        return v_method;
    }

    public Vala.Method build_virtual_method () {
        unowned var g_vm = (Gir.VirtualMethod) g_call;

        /* return type */
        var v_return_type = build_return_type (g_vm.return_value);

        /* the method itself */
        var v_method = new Method (g_vm.name, v_return_type, g_vm.source_reference);
        v_method.access = PUBLIC;
        if (g_vm.parent_node is Gir.Interface) {
            v_method.is_abstract = true;
        } else {
            v_method.is_virtual = true;
        }

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* version and deprecation */
        add_version_attrs (v_method);
        if (g_vm.moved_to != null) {
            v_method.version.replacement = g_vm.moved_to;
        }

        /* "NoWrapper" attribute when no invoker method has been found */
        if (! has_invoker_method ()) {
            v_method.set_attribute ("NoWrapper", true);
        }

        /* parameters */
        new ParametersBuilder (g_vm, v_method).build_parameters ();

        /* throws */
        if (g_vm.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Vala.Delegate build_delegate () {
        unowned var g_callback = (Gir.Callback) g_call;
        
        /* return type */
        var v_return_type = build_return_type (g_callback.return_value);

        /* create the delegate */
        var v_del = new Delegate (g_callback.name, v_return_type, g_callback.source_reference);
        v_del.access = PUBLIC;

        /* c_name */
        if (g_callback.parent_node is Gir.Namespace) {
            var cname = new IdentifierBuilder ().generate_cname (g_callback);
            if (g_callback.c_type != cname) {
                v_del.set_attribute_string ("CCode", "cname", g_callback.c_type);
            }
        }

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_del);
        }

        /* version */
        add_version_attrs (v_del);

        /* parameters */
        new ParametersBuilder (g_callback, v_del).build_parameters ();

        /* throws */
        if (g_callback.throws) {
            v_del.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_del;
    }

    public Vala.Signal build_signal () {
        unowned var g_sig = (Gir.Signal) g_call;
        
        /* name */
        var name = g_sig.name.replace ("-", "_");

        /* return type */
        var v_return_type = build_return_type (g_sig.return_value);

        /* create the signal */
        var v_sig = new Vala.Signal (name, v_return_type, g_sig.source_reference);
        v_sig.access = PUBLIC;

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_sig);
        }

        /* version */
        add_version_attrs (v_sig);

        /* parameters */
        new ParametersBuilder (g_sig, v_sig).build_parameters ();

        /* find emitter method */
        foreach (var g_method in g_sig.parent_node.all_of<Gir.Method> ()) {
            if (equal_method_names (g_sig, g_method)) {
                v_sig.set_attribute ("HasEmitter", true);
            }
        }
        
        /* find virtual emitter method */
        foreach (var g_vm in g_sig.parent_node.all_of<Gir.VirtualMethod> ()) {
            if (equal_method_names (g_sig, g_vm)) {
                v_sig.is_virtual = true;
            }
        }

        return v_sig;
    }

    /* void functions with one trailing out parameter: change the out parameter
     * into a return value */
    private void set_out_parameter_as_return_value () {
        if (! (returns_void () && has_parameters ())) {
            return;
        }

        var parameters = g_call.parameters.parameters;
        var last_param = parameters[parameters.size - 1];

        /* count the number of out-parameters */
        var num_out_parameters = 0;
        foreach (var p in parameters) {
            if (p.direction == OUT) {
                num_out_parameters++;
            }
        }

        if (num_out_parameters == 1
                && last_param.direction == OUT
                && (! last_param.nullable)) {
            /* set return type to the type of the out-parameter */
            g_call.return_value.anytype = last_param.anytype;

            /* remove the out-parameter */
            parameters.remove (last_param);
        }
    }

    private Vala.DataType build_return_type (Gir.ReturnValue g_return) {
        /* create the return type */
        var v_return_type = new DataTypeBuilder (g_return.anytype).build ();

        /* nullability */
        v_return_type.nullable = g_return.nullable || g_return.allow_none;

        /* ownership transfer */
        v_return_type.value_owned = g_return.transfer_ownership != NONE;

        /* ownership transfer of generic type arguments */
        foreach (var type_arg in v_return_type.get_type_arguments ()) {
            type_arg.value_owned = g_return.transfer_ownership != CONTAINER;
        }
        
        return v_return_type;
    }

    private void add_array_return_type_attributes (Vala.Callable v_method) {
        unowned var v_type = (Vala.ArrayType) v_method.return_type;
        var g_type = (Gir.Array) g_call.return_value.anytype;
        var builder = new ParametersBuilder (g_call, v_method);
        builder.add_array_attrs (v_method, v_type, g_type);
        v_type.element_type.value_owned = true;
    }

    private string? get_constructor_name () {
        if (g_call is Gir.Constructor) {
            if (g_call.name == "new") {
                return null;
            } else if (g_call.name.has_prefix ("new_")) {
                return g_call.name.substring ("new_".length);
            }
        }

        return g_call.name;
    }

    /* return true when this method must be omitted from the vapi */
    public bool skip () {
        return (! g_call.introspectable)
                || is_invoker_method ()
                || is_signal_emitter_method ()
                || is_async_finish_method ()
                || is_property_accessor ();
    }

    /* Find a virtual method invoked by this method. */
    public bool is_invoker_method () {
        if (! (g_call is Gir.Method || g_call is Gir.Function)) {
            return false;
        }

        var name = g_call.attrs["name"];

        foreach (var vm in g_call.parent_node.all_of<Gir.VirtualMethod> ()) {
            if (vm.invoker == name) {
                return true;
            }

            if (equal_method_names (g_call, vm)) {
                return true;
            }
        }

        return false;
    }

    /* Find a method that invokes this virtual method. */
    public bool has_invoker_method () {
        if (! (g_call is Gir.VirtualMethod)) {
            return false;
        }

        unowned var vm = (Gir.VirtualMethod) g_call;
        foreach (var m in g_call.parent_node.all_of<Gir.Method> ()) {
            if (vm.invoker == m.name) {
                return true;
            }

            if (equal_method_names (m, vm)) {
                return true;
            }
        }

        return false;
    }

    public bool is_async_finish_method () {
        if (! (g_call is Gir.Method)) {
            return false;
        }

        foreach (var m in g_call.parent_node.all_of<Gir.Method> ()) {
            if (m.glib_finish_func == g_call.name) {
                return true;
            }
        }

        return false;
    }

    public Gir.Method? get_async_finish_method () {
        var name = ((Gir.Method) g_call).glib_finish_func;
        foreach (var m in g_call.parent_node.all_of<Gir.Method> ()) {
            if (m.name == name) {
                return m;
            }
        }

        Report.error (g_call.source_reference, "Cannot find finish-func \"%s\"", name);
        return null;
    }

    /* Find a signal with the same name and type signature as this method or
     * virtual method. */
     public bool is_signal_emitter_method () {
        if (! (g_call is Gir.Method || g_call is Gir.VirtualMethod)) {
            return false;
        }

        foreach (var s in g_call.parent_node.all_of<Gir.Signal> ()) {
            if (equal_method_names (g_call, s)) {
                return true;
            }
        }

        return false;
    }

    /* Find a property with the same name as this method. If found, the property
     * takes precedence. */
     public bool is_property_accessor () {
        var name = (g_call is Gir.Constructor)
                ? get_constructor_name () : g_call.name;

        foreach (var p in g_call.parent_node.all_of<Gir.Property> ()) {
            if (name?.replace ("-", "_") == p.name.replace ("-", "_")) {
                return true;
            }
        }

        return false;
    }

    private bool equal_method_names (Gir.Callable a, Gir.Callable b) {
        return a.name.replace ("-", "_") == b.name.replace ("-", "_");
    }

    /* check if this callable returns void */
    public bool returns_void () {
        return g_call.return_value.anytype is Gir.TypeRef
                && ((Gir.TypeRef) g_call.return_value.anytype).name == "none";
    }

    /* check if this callable has no parameters (ignoring instance parameter) */
    public bool has_parameters () {
        return g_call.parameters != null
                && (! g_call.parameters.parameters.is_empty);
    }

    /* generate the C function name from the GIR name and all prefixes */
    private string generate_cname (Gir.Callable call) {
        var sb = new StringBuilder (call.name);
        unowned var node = call.parent_node;
        while (node != null) {
            /* use the symbol-prefix if it is defined */
            var prefix = node.attrs["c:symbol-prefix"] ?? node.attrs["c:symbol-prefixes"];

            /* for types without a symbol-prefix defined, use the name */
            if (prefix == null && node.attrs["name"] != null) {
                prefix = Vala.Symbol.camel_case_to_lower_case (node.attrs["name"]);
            }

            if (prefix != null) {
                sb.prepend (prefix + "_");
            }

            node = node.parent_node;
        }

        return sb.str;
    }
}
