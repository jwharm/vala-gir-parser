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

public class Builders.ParametersBuilder {

    private Gir.Node? g_call;
    private Vala.Callable? v_call;

    public ParametersBuilder (Gir.Node? g_call, Vala.Callable? v_call) {
        this.g_call = g_call;
        this.v_call = v_call;
    }

    public void build_parameters () {
        var g_param_node = g_call.any_of ("parameters");
        if (g_param_node == null) {
            return;
        }

        var g_instance_param = g_param_node.any_of ("instance-parameter");
        var g_params = g_param_node.all_of ("parameter");

        /* set "DestroysInstance" attribute when ownership of `this` is
         * transferred to the method: This means the method will consume the
         * instance. */
        if (g_instance_param?.get_string ("transfer-ownership") == "full") {
            v_call.set_attribute ("DestroysInstance", true);
        }

        for (int i = 0; i < g_params.size; i++) {
            Gir.Node g_par = g_params[i];
            Vala.Parameter v_par;

            /* varargs */
            if (g_par.any_of ("varargs") != null) {
                v_par = new Vala.Parameter.with_ellipsis (g_par.source);
                v_call.add_parameter (v_par);
                return;
            }

            /* instance_pos attribute: Specifies the position of the user_data
             * argument where Vala can pass the `this` parameter to treat the 
             * callback like an instance method. */
            if (g_call.tag == "callback" && g_par.has_attr ("closure")) {
                var pos = get_param_pos (i);
                v_call.set_attribute_double ("CCode", "instance_pos", pos);
            }

            /* skip hidden parameters */
            if (is_hidden_param (i)) {
                continue;
            }

            /* determine the datatype */
            var v_type = new DataTypeBuilder (g_par.any_of ("array", "type")).build ();
            v_type.nullable = g_par.get_bool ("nullable")
                    || (g_par.get_bool ("allow-none") && g_par.get_string ("direction") != "out");

            /* create the parameter */
            v_par = new Vala.Parameter (g_par.get_string ("name"), v_type, g_par.source);

            /* array parameter */
            if (v_type is Vala.ArrayType) {
                unowned var v_arr_type = (Vala.ArrayType) v_type;
                add_array_attrs (v_par, v_arr_type, g_par.any_of ("array"));
                v_arr_type.element_type.value_owned = true;
            }

            var direction = g_par.get_string ("direction");
            var transfer_ownership = g_par.get_string ("transfer-ownership");

            /* out or ref parameter */
            if (direction == "out") {
                v_par.direction = ParameterDirection.OUT;
            } else if (direction == "inout") {
                v_par.direction = ParameterDirection.REF;
            }

            /* ownership transfer */
            if (transfer_ownership != "none" || g_par.has_attr ("destroy")) {
                v_type.value_owned = true;
            }

            /* ownership transfer of generic type arguments */
            foreach (var type_arg in v_type.get_type_arguments ()) {
                type_arg.value_owned = transfer_ownership != "container";
            }

            /* null-initializer for GCancellable parameters */
            if (v_type.to_string () == "GLib.Cancellable?") {
                v_par.initializer = new Vala.NullLiteral ();
            }

            v_call.add_parameter (v_par);
        }
    }

    public void add_array_attrs (Vala.Symbol v_sym,
                                 Vala.ArrayType v_type,
                                 Gir.Node g_arr) {
        /* don't emit array attributes for a GLib.GenericArray */
        if (g_arr.get_string ("name") == "GLib.PtrArray") {
            return;
        }

        /* fixed length */
        if (g_arr.has_attr ("fixed-size")) {
            v_type.fixed_length = true;
            v_type.length = new IntegerLiteral (g_arr.get_string ("fixed-size"));
            v_sym.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another parameter */
        else if (g_arr.has_attr ("length") && g_call != null) {
            var length = g_arr.get_int ("length");
            var pos = get_param_pos (length);
            var lp = g_call.any_of ("parameters").all_of ("parameter")[length];
            var g_type = lp.any_of ("type");

            v_sym.set_attribute_double ("CCode", "array_length_pos", pos);

            if (v_sym is Vala.Parameter) {
                v_sym.set_attribute_string ("CCode", "array_length_cname", lp.get_string ("name"));
            }

            /* int is the default and can be omitted */
            var g_type_name = g_type.get_string ("name");
            if (g_type_name != "gint") {
                v_sym.set_attribute_string ("CCode", "array_length_type", g_type_name);
            }
        }

        /* no length specified */
        else {
            v_sym.set_attribute_bool ("CCode", "array_length", false);
            /* If zero-terminated is missing, there's no length, there's no
             * fixed size, and the name attribute is unset, then zero-terminated
             * is true. */
            if (g_arr.get_bool ("zero-terminated") || !g_arr.has_attr ("name")) {
                v_sym.set_attribute_bool ("CCode", "array_null_terminated", true);
            }
        }
    }

    /* Get the position of this parameter in Vala. Hidden parameters are
     * fractions between the indexes of the visible parameters. */
    private double get_param_pos (int idx) {
        double pos = 0.0;
        for (int i = 0; i <= idx; i++) {
            if (is_hidden_param (i)) {
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
    private bool is_hidden_param (int idx) {
        foreach (var p in g_call.any_of ("parameters").all_of ("parameter")) {
            var closure = p.get_int ("closure");
            var destroy = p.get_int ("destroy");
            if (closure == idx || destroy == idx) {
                return true;
            }

            var array = p.any_of ("array");
            if (array != null) {
                if (array.get_int ("length") == idx) {
                    return true;
                }
            }
        }

        var return_value = g_call.any_of ("return-value");
        if (return_value.has_any ("array")) {
            if (return_value.any_of ("array").get_int ("length") == idx) {
                return true;
            }
        }

        if (g_call.tag == "method") {
            if (g_call.has_attr ("glib:finish-func")) {
                var p = g_call.any_of ("parameters").all_of ("parameter")[idx];
                if (p.has_any ("type")) {
                    var p_type = p.any_of ("type");
                    if (p_type.get_string ("c:type") == "GAsyncReadyCallback") {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    /* Avoids a dependency on GLib.Math */
    private static double floor (double a) {
        double b = (double) (long) a;
        return a < 0.0 ? b - 1.0 : b;
    }
}
