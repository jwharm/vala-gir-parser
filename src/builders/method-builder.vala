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

public class Builders.MethodBuilder {

    private Gir.Node g_call;

    public MethodBuilder (Gir.Node g_call) {
        this.g_call = g_call;
    }

    public Vala.CreationMethod build_constructor () {
        /* name */
        var name = get_constructor_name ();

        /* create the constructor */
        var v_cm = new CreationMethod (null, name, g_call.source);
        v_cm.access = PUBLIC;
        v_cm.has_construct_function = false;

        /* c name */
        var g_call_name = g_call.get_string ("name");
        if (g_call_name != "new" && (! g_call_name.has_prefix ("new_"))) {
            v_cm.set_attribute_string ("CCode", "cname", g_call.get_string ("c:identifier"));
        }

        /* version and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_cm);
        if (g_call.has_attr ("moved-to")) {
            v_cm.version.replacement = g_call.get_string ("moved-to");
        }

        /* return type annotation */
        if (g_call.parent_node.tag == "class") {
            var parent_c_type = g_call.parent_node.get_string ("c:type");
            var return_c_type = g_call.any_of ("return-value")
                                      .any_of ("type")?
                                      .get_string ("c:type");
            if (return_c_type != null &&
                    (parent_c_type == null || return_c_type != parent_c_type + "*")) {
                v_cm.set_attribute_string ("CCode", "type", return_c_type);
            }
        }

        /* parameters */
        new ParametersBuilder (g_call, v_cm).build_parameters ();

        /* throws */
        if (g_call.get_bool ("throws", false)) {
            v_cm.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_cm;
    }

    public Vala.Method build_function () {
        /* return type */
        var v_return_type = build_return_type (g_call.any_of ("return-value"));

        /* create a static method */
        var v_method = new Method (g_call.get_string ("name"), v_return_type, g_call.source);
        v_method.access = PUBLIC;
        v_method.binding = STATIC;

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* c name */
        var c_identifier = g_call.get_string ("c:identifier");
        if (c_identifier != generate_cname (g_call)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* version and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);
        if (g_call.has_attr ("moved-to")) {
            v_method.version.replacement = g_call.get_string ("moved-to");
        }

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.get_bool ("throws")) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Vala.Method build_method () {
        /* return type */
        var v_return_type = build_return_type (g_call.any_of ("return-value"));

        /* the method itself */
        var v_method = new Method (g_call.get_string ("name"), v_return_type, g_call.source);
        v_method.access = PUBLIC;

        /* c name */
        var c_identifier = g_call.get_string ("c:identifier");
        if (c_identifier != generate_cname (g_call)) {
            v_method.set_attribute_string ("CCode", "cname", c_identifier);
        }

        /* version and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);
        if (g_call.has_attr ("moved-to")) {
            v_method.version.replacement = g_call.get_string ("moved-to");
        }

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.get_bool ("throws")) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        /* async */
        if (g_call.has_attr ("glib:finish-func")) {
            /* mark as async method */
            v_method.coroutine = true;

            /* copy the return-type from the finish-func */
            Gir.Node g_finish_func = get_async_finish_method ();
            v_method.return_type = build_return_type (g_finish_func.any_of ("return-value"));

            /* when the finish-func throws */
            if ((! g_call.get_bool ("throws")) && g_finish_func.get_bool ("throws")) {
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
        /* return type */
        var v_return_type = build_return_type (g_call.any_of ("return-value"));

        /* the method itself */
        var v_method = new Method (g_call.get_string ("name"), v_return_type, g_call.source);
        v_method.access = PUBLIC;
        if (g_call.parent_node.tag == "interface") {
            v_method.is_abstract = true;
        } else {
            v_method.is_virtual = true;
        }

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_method);
        }

        /* version and deprecation */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_method);
        if (g_call.has_attr ("moved-to")) {
            v_method.version.replacement = g_call.get_string ("moved-to");
        }

        /* "NoWrapper" attribute when no invoker method with the same name */
        var invoker_method = get_invoker_method ();
        var invoker_name = invoker_method?.get_string ("name");
        if (invoker_method == null || invoker_name != g_call.get_string ("name")) {
            v_method.set_attribute ("NoWrapper", true);
        }

        /* override "NoWrapper" attribute from metadata */
        if (g_call.has_attr ("no-wrapper")) {
            var no_wrapper = g_call.get_bool ("no-wrapper");
            v_method.set_attribute ("NoWrapper", no_wrapper);
        }

        /* "vfunc_name" attribute when invoker method has another name */
        if (invoker_method != null && invoker_name != g_call.get_string ("name")) {
            v_method.set_attribute_string ("CCode", "vfunc_name", invoker_name);
        }

        /* parameters */
        new ParametersBuilder (g_call, v_method).build_parameters ();

        /* throws */
        if (g_call.get_bool ("throws")) {
            v_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_method;
    }

    public Vala.Delegate build_delegate () {
        /* return type */
        var v_return_type = build_return_type (g_call.any_of ("return-value"));

        /* create the delegate */
        var v_del = new Delegate (g_call.get_string ("name"), v_return_type, g_call.source);
        v_del.access = PUBLIC;

        /* c_name */
        if (g_call.parent_node.tag == "namespace") {
            var cname = new IdentifierBuilder (g_call).generate_cname ();
            if (g_call.get_string ("c:type") != cname) {
                v_del.set_attribute_string ("CCode", "cname", g_call.get_string ("c:type"));
            }
        }

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_del);
        }

        /* version */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_del);

        /* parameters */
        new ParametersBuilder (g_call, v_del).build_parameters ();

        /* throws */
        if (g_call.get_bool ("throws")) {
            v_del.add_error_type (new Vala.ErrorType (null, null));
        }

        return v_del;
    }

    public Vala.Signal build_signal () {
        /* name */
        var name = g_call.get_string ("name").replace ("-", "_");

        /* return type */
        var v_return_type = build_return_type (g_call.any_of ("return-value"));

        /* create the signal */
        var v_sig = new Vala.Signal (name, v_return_type, g_call.source);
        v_sig.access = PUBLIC;

        /* array return type attributes */
        if (v_return_type is Vala.ArrayType) {
            add_array_return_type_attributes (v_sig);
        }

        /* version */
        new InfoAttrsBuilder (g_call).add_info_attrs (v_sig);

        /* parameters */
        new ParametersBuilder (g_call, v_sig).build_parameters ();

        /* find emitter method */
        foreach (var g_method in g_call.parent_node.all_of ("method")) {
            if (equal_method_names (g_call, g_method)) {
                v_sig.set_attribute ("HasEmitter", true);
            }
        }
        
        /* find virtual emitter method */
        foreach (var g_vm in g_call.parent_node.all_of ("virtual-method")) {
            if (equal_method_names (g_call, g_vm)) {
                v_sig.is_virtual = true;
            }
        }

        return v_sig;
    }

    private Vala.DataType build_return_type (Gir.Node g_return) {
        /* create the return type */
        var v_return_type = new DataTypeBuilder (g_return.any_of ("type", "array")).build ();

        /* nullability */
        v_return_type.nullable = g_return.get_bool ("nullable") || g_return.get_bool ("allow-none");

        /* ownership transfer */
        var transfer_ownership = g_return.get_string ("transfer-ownership");
        v_return_type.value_owned = transfer_ownership != "none";

        /* ownership transfer of generic type arguments */
        foreach (var type_arg in v_return_type.get_type_arguments ()) {
            type_arg.value_owned = transfer_ownership != "container";
        }
        
        return v_return_type;
    }

    private void add_array_return_type_attributes (Vala.Callable v_method) {
        unowned var v_type = (Vala.ArrayType) v_method.return_type;
        var g_type = g_call.any_of ("return-value").any_of ("array");
        var builder = new ParametersBuilder (g_call, v_method);
        builder.add_array_attrs (v_method, v_type, g_type);
        v_type.element_type.value_owned = true;
    }

    private string? get_constructor_name () {
        var name = g_call.get_string ("name");
        if (g_call.tag == "constructor") {
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
        return (! g_call.get_bool ("introspectable", true))
                || is_invoker_method ()
                || is_signal_emitter_method ()
                || is_async_finish_method ()
                || is_property_accessor ();
    }

    /* Find a virtual method with the same name as this method. */
    public bool is_invoker_method () {
        if (! (g_call.tag == "method" || g_call.tag == "function")) {
            return false;
        }

        foreach (var vm in g_call.parent_node.all_of ("virtual-method")) {
            if (equal_method_names (g_call, vm)) {
                return true;
            }
        }

        return false;
    }

    /* Find a method or function that invokes this virtual method. */
    public Gir.Node? get_invoker_method () {
        if (! (g_call.tag == "virtual-method")) {
            return null;
        }

        foreach (var m in g_call.parent_node.children) {
            if (! (m.tag == "method" || m.tag == "function")) {
                continue;
            }

            if (g_call.get_string ("invoker") == m.get_string ("name")) {
                return m;
            }

            if (equal_method_names (m, g_call)) {
                return m;
            }
        }

        return null;
    }

    public bool is_async_finish_method () {
        if (! (g_call.tag == "method")) {
            return false;
        }

        foreach (var m in g_call.parent_node.all_of ("method")) {
            if (m.get_string ("glib:finish-func") == g_call.get_string ("name")) {
                return true;
            }
        }

        return false;
    }

    public Gir.Node? get_async_finish_method () {
        var name = g_call.get_string ("glib:finish-func");
        foreach (var m in g_call.parent_node.all_of ("method")) {
            if (m.get_string ("name") == name) {
                return m;
            }
        }

        Report.error (g_call.source, "Cannot find finish-func \"%s\"", name);
        return null;
    }

    /* Find a signal with the same name and type signature as this method or
     * virtual method. */
     public bool is_signal_emitter_method () {
        if (! (g_call.tag == "method" || g_call.tag == "virtual-method")) {
            return false;
        }

        foreach (var s in g_call.parent_node.all_of ("glib:signal")) {
            if (equal_method_names (g_call, s)) {
                return true;
            }
        }

        return false;
    }

    /* Find a property with the same name as this method. If found, the property
     * takes precedence. */
     public bool is_property_accessor () {
        var name = (g_call.tag == "constructor")
                        ? get_constructor_name ()
                        : g_call.get_string ("name");
        name = name?.replace ("-", "_");

        foreach (var p in g_call.parent_node.all_of ("property")) {
            if (name == p.get_string ("name").replace ("-", "_")) {
                return true;
            }
        }

        return false;
    }

    private bool equal_method_names (Gir.Node a, Gir.Node b) {
        var a_name = a.get_string ("name").replace ("-", "_");
        var b_name = b.get_string ("name").replace ("-", "_");
        return a_name == b_name;
    }

    /* check if this callable has no parameters (ignoring instance parameter) */
    public bool has_parameters () {
        return g_call.has_any ("parameters")
                && (! g_call.any_of ("parameters").has_any ("parameter"));
    }

    /* generate the C function name from the GIR name and all prefixes */
    private string generate_cname (Gir.Node call) {
        var sb = new StringBuilder (call.get_string ("name"));
        unowned var node = call.parent_node;
        while (node != null) {
            /* use the symbol-prefix if it is defined */
            var prefix = node.get_string ("c:symbol-prefix")
                      ?? node.get_string ("c:symbol-prefixes");

            /* for types without a symbol-prefix defined, use the name */
            if (prefix == null && node.has_attr ("name")) {
                prefix = Vala.Symbol.camel_case_to_lower_case (node.get_string ("name"));
            }

            if (prefix != null) {
                sb.prepend (prefix + "_");
            }

            node = node.parent_node;
        }

        return sb.str;
    }
}
