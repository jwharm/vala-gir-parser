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

using Vala;

public class Builders.MethodBuilder {

    private Symbol v_parent_sym;
    private Gir.Callable g_call;

    public MethodBuilder (Symbol v_parent_sym, Gir.Callable g_call) {
        this.v_parent_sym = v_parent_sym;
        this.g_call = g_call;
    }

    public Symbol build_constructor () {
        unowned var g_constructor = (Gir.Constructor) g_call;

        /* name */
        var name = get_constructor_name ();

        /* create the constructor */
        var v_cm = new CreationMethod (null, name, g_call.source);
        v_cm.access = PUBLIC;
        v_cm.has_construct_function = false;
        v_parent_sym.add_method (v_cm);

        /* c name */
        var g_call_name = g_call.name;
        if (g_call_name != "new" && (! g_call_name.has_prefix ("new_"))) {
            v_cm.set_attribute_string ("CCode", "cname", g_constructor.c_identifier);
        }

        /* attributes and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_cm);

        /* return type annotation */
        if (g_call.parent_node is Gir.Class) {
            var parent_c_type = ((Gir.Class) g_call.parent_node).c_type;
            var return_type = g_call.return_value.anytype;
            var return_c_type = (return_type as Gir.TypeRef)?.c_type;
            if (return_c_type != null &&
                    (parent_c_type == null || return_c_type != parent_c_type + "*")) {
                v_cm.set_attribute_string ("CCode", "type", return_c_type);
            }
        }

        /* parameters */
        new ParametersBuilder (g_call, v_cm).build_parameters ();

        /* throws */
        if (g_call.throws) {
            v_cm.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_cm;
    }

    public Symbol build_function () {
        unowned var g_function = (Gir.Function) g_call;

        /* return type */
        var v_return_type = build_return_type (g_call.return_value);

        /* create a static method */
        var v_method = new Method (g_call.name, v_return_type, g_call.source);
        v_method.access = PUBLIC;
        v_method.binding = STATIC;
        v_parent_sym.add_method (v_method);

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* c name */
        var c_identifier = g_function.c_identifier;
        if (c_identifier != generate_cname (g_call)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* attributes and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Symbol build_method () {
        unowned var g_method = (Gir.Method) g_call;

        /* return type */
        var v_return_type = build_return_type (g_call.return_value);

        /* the method itself */
        var v_method = new Method (g_call.name, v_return_type, g_call.source);
        v_method.access = PUBLIC;
        v_parent_sym.add_method (v_method);

        /* c name */
        var c_identifier = g_method.c_identifier;
        if (c_identifier != generate_cname (g_call)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* attributes and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.throws) {
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
            if ((! g_call.throws) && g_finish_func.throws) {
                v_method.add_error_type (new Vala.ErrorType (null, null));
            }
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        return v_method;
    }

    public Symbol build_virtual_method () {
        unowned var g_virtual_method = (Gir.VirtualMethod) g_call;
        /* return type */
        var v_return_type = build_return_type (g_call.return_value);

        /* the method itself */
        var v_method = new Method (g_call.name, v_return_type, g_call.source);
        v_method.access = PUBLIC;
        v_parent_sym.add_method (v_method);

        if (g_call.parent_node is Gir.Interface) {
            v_method.is_abstract = true;
        } else {
            v_method.is_virtual = true;
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* attributes and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);

        /* "NoWrapper" attribute when no invoker method with the same name */
        var invoker_method = get_invoker_method ();
        var invoker_name = invoker_method?.name;
        if (invoker_method == null || invoker_name != g_call.name) {
            v_method.set_attribute ("NoWrapper", true);
        }

        /* override "NoWrapper" attribute from metadata */
        //  if (g_call.has_attr ("no-wrapper")) {
        //      var no_wrapper = g_call.get_bool ("no-wrapper");
        //      v_method.set_attribute ("NoWrapper", no_wrapper);
        //  }

        /* "vfunc_name" attribute when invoker method has another name */
        if (invoker_method != null && invoker_name != g_call.name) {
            v_method.set_attribute_string ("CCode", "vfunc_name", invoker_name);
        }

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.throws) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Symbol build_delegate () {
        unowned var g_callback = (Gir.Callback) g_call;

        /* return type */
        var v_return_type = build_return_type (g_call.return_value);

        /* create the delegate */
        var v_del = new Delegate (g_call.name, v_return_type, g_call.source);
        v_del.access = PUBLIC;
        v_parent_sym.add_delegate (v_del);

        /* c_name */
        if (g_call.parent_node is Gir.Namespace) {
            var cname = new IdentifierBuilder (v_parent_sym, g_callback).generate_cname ();
            if (g_callback.c_type != cname) {
                v_del.set_attribute_string ("CCode", "cname", g_callback.c_type);
            }
        }

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (v_del);
        }

        /* attributes */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_del);

        /* parameters */
        new ParametersBuilder (g_call, v_del).build_parameters ();

        /* throws */
        if (g_call.throws) {
            v_del.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_del;
    }

    public Symbol build_signal () {
        /* name */
        var name = g_call.name.replace ("-", "_");

        /* return type */
        var v_return_type = build_return_type (g_call.return_value);

        /* create the signal */
        var v_sig = new Vala.Signal (name, v_return_type, g_call.source);
        v_sig.access = PUBLIC;
        v_parent_sym.add_signal (v_sig);

        /* array return type attributes */
        if (v_return_type is ArrayType) {
            add_array_return_type_attributes (v_sig);
        }

        /* attributes */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_sig);

        /* parameters */
        new ParametersBuilder (g_call, v_sig).build_parameters ();

        /* find emitter method */
        foreach (var g_method in g_call.parent_node.all_of<Gir.Method> ()) {
            if (equal_method_names (g_call, g_method)) {
                v_sig.set_attribute ("HasEmitter", true);
            }
        }
        
        /* find virtual emitter method */
        foreach (var g_vm in g_call.parent_node.all_of<Gir.VirtualMethod> ()) {
            if (equal_method_names (g_call, g_vm)) {
                v_sig.is_virtual = true;
            }
        }

        return v_sig;
    }

    /* Generate the Vala DataType of this method's return type */
    private DataType build_return_type (Gir.ReturnValue g_return) {
        /* create the return type */
        var g_anytype = g_return.anytype;
        var v_return_type = new DataTypeBuilder (g_anytype).build ();

        /* nullability */
        v_return_type.nullable = false;
        if (g_return.attrs.contains ("nullable")) {
            v_return_type.nullable = g_return.nullable;
        } else if (g_return.attrs.contains ("allow-none")) {
            v_return_type.nullable = g_return.allow_none;
        }

        /* Functions which return structs currently generate incorrect C code
         * because valac assumes the struct is actually an out argument.
         * The return value of functions returning structs must be marked as
         * nullable to prevent valac from generating an out argument in C.
         * To determine if the return value is a struct, the symbol first needs
         * to be resolved. */
        else {
            var name = DataTypeBuilder.vala_datatype_name (v_return_type);
            var symbol = IdentifierBuilder.lookup (v_parent_sym.scope, name);
            if (symbol is Struct && !((Struct) symbol).is_simple_type ()) {
                v_return_type.nullable = true;
            }
        }

        /* ownership transfer */
        var transfer_ownership = g_return.transfer_ownership;
        v_return_type.value_owned = transfer_ownership != NONE;

        /* ownership transfer of generic type arguments */
        foreach (var type_arg in v_return_type.get_type_arguments ()) {
            type_arg.value_owned = transfer_ownership != CONTAINER;
        }
        
        return v_return_type;
    }

    /* Set array attributes on a method that returns an array type */
    private void add_array_return_type_attributes (Callable v_method) {
        unowned var v_type = (ArrayType) v_method.return_type;
        var g_type = g_call.return_value.anytype as Gir.Array;
        var builder = new ParametersBuilder (g_call, v_method);
        builder.add_array_attrs (v_method, v_type, g_type);
        v_type.element_type.value_owned = true;
    }

    /* Return `null` if the constructor is named "new", otherwise return the
     * constructor name without the "new_" prefix (if any) */
    private string? get_constructor_name () {
        var name = g_call.name;
        if (g_call is Gir.Constructor) {
            if (name == "new") {
                return null;
            } else if (name.has_prefix ("new_")) {
                return name.substring ("new_".length);
            }
        }

        return name;
    }

    /* return true when this method must be omitted from the vapi */
    public bool skip () {
        return (! g_call.introspectable)
                || is_invoker_method ()
                || is_signal_emitter_method ()
                || is_async_finish_method ()
                || is_property_accessor ();
    }

    /* Find a virtual method with the same name as this method. */
    public bool is_invoker_method () {
        if (! (g_call is Gir.Method || g_call is Gir.Function)) {
            return false;
        }

        foreach (var vm in g_call.parent_node.all_of<Gir.VirtualMethod> ()) {
            if (equal_method_names (g_call, vm)) {
                return true;
            }
        }

        return false;
    }

    /* Find a method or function that invokes this virtual method. */
    public Gir.Callable? get_invoker_method () {
        if (! (g_call is Gir.VirtualMethod)) {
            return null;
        }

        unowned var g_virtual_method = (Gir.VirtualMethod) g_call;

        foreach (var m in g_call.parent_node.children) {
            if (! (m is Gir.Method || m is Gir.Function)) {
                continue;
            }

            var g_callable = (Gir.Callable) m;

            if (g_virtual_method.invoker == g_callable.name) {
                return g_callable;
            }

            if (equal_method_names (g_callable, g_call)) {
                return g_callable;
            }
        }

        return null;
    }

    /* Check if this method is the glib:finish-func of an async method */
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

    /* Find the glib:finish-func of this async method */
    public Gir.Method? get_async_finish_method () {
        unowned var g_method = (Gir.Method) g_call;
        var name = g_method.glib_finish_func;
        foreach (var m in g_call.parent_node.all_of<Gir.Method> ()) {
            if (m.name == name || m.c_identifier == name) {
                return m;
            }
        }

        Report.error (g_call.source, "Cannot find finish-func \"%s\"", name);
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
                        ? get_constructor_name ()
                        : g_call.name;
        name = name?.replace ("-", "_");

        foreach (var p in g_call.parent_node.all_of<Gir.Property> ()) {
            if (name == p.name.replace ("-", "_")) {
                return true;
            }
        }

        return false;
    }

    /* Compare method and signal names (treating "-" and "_" as equal) */
    private bool equal_method_names (Gir.Callable a, Gir.Callable b) {
        var a_name = a.name.replace ("-", "_");
        var b_name = b.name.replace ("-", "_");
        return a_name == b_name;
    }

    /* Generate the C function name from the GIR name and all prefixes */
    private string generate_cname (Gir.Callable call) {
        var sb = new StringBuilder (call.name);
        unowned var node = call.parent_node;
        while (node != null) {
            /* use the symbol-prefix if it is defined */
            var prefix = node.attrs["c:symbol-prefix"]
                      ?? node.attrs["c:symbol-prefixes"];

            /* for types without a symbol-prefix defined, use the name */
            if (prefix == null && node.attrs.contains ("name")) {
                prefix = Symbol.camel_case_to_lower_case (node.attrs["name"]);
            }

            if (prefix != null) {
                sb.prepend (prefix + "_");
            }

            node = node.parent_node;
        }

        return sb.str;
    }
}
