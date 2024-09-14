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

    private Gir.Callable? g_call;
    private Vala.Callable? v_call;

    public ParametersBuilder (Gir.Callable? g_call, Vala.Callable? v_call) {
        this.g_call = g_call;
        this.v_call = v_call;
    }

    public void build_parameters () {
        if (g_call.parameters == null) {
            return;
        }

        /* set "DestroysInstance" attribute when ownership of `this` is
         * transferred to the method: This means the method will consume the
         * instance. */
        if (g_call.parameters.instance_parameter?.transfer_ownership == FULL) {
            v_call.set_attribute ("DestroysInstance", true);
        }

        for (int i = 0; i < g_call.parameters.parameters.size; i++) {
            Gir.Parameter g_par = g_call.parameters.parameters[i];
            Vala.Parameter v_par;

            /* varargs */
            if (g_par.varargs != null) {
                v_par = new Vala.Parameter.with_ellipsis (g_par.source_reference);
                v_call.add_parameter (v_par);
                return;
            }

            /* instance_pos attribute: Specifies the position of the user_data
             * argument where Vala can pass the `this` parameter to treat the 
             * callback like an instance method. */
            if (g_call is Gir.Callback && g_par.closure != -1) {
                var pos = get_param_pos (i);
                v_call.set_attribute_double ("CCode", "instance_pos", pos);
            }

            /* skip hidden parameters */
            if (is_hidden_param (i)) {
                continue;
            }

            /* determine the datatype */
            var v_type = new DataTypeBuilder (g_par.anytype).build ();
            v_type.nullable = g_par.nullable || (g_par.allow_none && g_par.direction != OUT);

            /* create the parameter */
            v_par = new Vala.Parameter (g_par.name, v_type, g_par.source_reference);

            /* array parameter */
            if (g_par.anytype is Gir.Array) {
                unowned var v_arr_type = (Vala.ArrayType) v_type;
                add_array_attrs (v_par, v_arr_type, (Gir.Array) g_par.anytype);
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
                v_par.initializer = new Vala.NullLiteral ();
            }

            v_call.add_parameter (v_par);
        }
    }

    public void add_array_attrs (Vala.Symbol v_sym,
                                 Vala.ArrayType v_type,
                                 Gir.Array g_arr) {
        /* fixed length */
        if (g_arr.fixed_size != -1) {
            v_type.fixed_length = true;
            v_type.length = new IntegerLiteral (g_arr.fixed_size.to_string ());
            v_sym.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another parameter */
        else if (g_arr.length != -1 && g_call != null) {
            var pos = get_param_pos (g_arr.length);
            var lp = g_call.parameters.parameters[g_arr.length];
            var g_type = (Gir.TypeRef) lp.anytype;

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
        foreach (Gir.Parameter p in g_call.parameters.parameters) {
            if (p.closure == idx || p.destroy == idx) {
                return true;
            }

            if (p.anytype is Gir.Array) {
                if (((Gir.Array) p.anytype).length == idx) {
                    return true;
                }
            }
        }

        if (g_call.return_value.anytype is Gir.Array) {
            if (((Gir.Array) g_call.return_value.anytype).length == idx) {
                return true;
            }
        }

        if (g_call is Gir.Method) {
            if (((Gir.Method) g_call).glib_finish_func != null) {
                var p = g_call.parameters.parameters[idx];
                if (p.anytype is Gir.TypeRef) {
                    var p_type = (Gir.TypeRef) p.anytype;
                    if (p_type.c_type == "GAsyncReadyCallback") {
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
