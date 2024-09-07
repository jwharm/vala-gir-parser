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

    private Gir.Callable gcall;
    private Vala.Callable vcall;

    public ParametersBuilder (Gir.Callable gcall, Vala.Callable vcall) {
        this.gcall = gcall;
        this.vcall = vcall;
    }

    public void build_parameters () {
        if (gcall.parameters == null) {
            return;
        }

        for (int i = 0; i < gcall.parameters.parameters.size; i++) {
            Gir.Parameter p = gcall.parameters.parameters[i];
            Vala.Parameter vpar;

            /* varargs */
            if (p.varargs != null) {
                vpar = new Vala.Parameter.with_ellipsis (p.source_reference);
                vcall.add_parameter (vpar);
                return;
            }

            /* skip hidden parameters */
            if (is_hidden_param (i)) {
                continue;
            }

            /* determine the datatype */
            var p_type = new DataTypeBuilder (p.anytype).build ();
            p_type.nullable = p.nullable;

            /* create the parameter */
            vpar = new Vala.Parameter (p.name, p_type, p.source_reference);

            /* array parameter */
            if (p.anytype is Gir.Array) {
                add_array_attrs (ref vpar, p);
                var array_type = (Vala.ArrayType) p_type;
                array_type.element_type.value_owned = true; /* FIXME */
            }

            /* out or ref parameter */
            if (p.direction == OUT) {
                vpar.direction = ParameterDirection.OUT;
            } else if (p.direction == INOUT) {
                vpar.direction = ParameterDirection.REF;
            }

            vcall.add_parameter (vpar);
        }
    }

    private void add_array_attrs (ref Vala.Parameter vpar, Gir.Parameter p) {
        var arr = (Gir.Array) p.anytype;

        /* fixed length */
        if (arr.fixed_size != -1) {
            var array_type = (Vala.ArrayType) vpar.variable_type;
            array_type.fixed_length = true;
            array_type.length = new IntegerLiteral (arr.fixed_size.to_string ());
            vpar.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another parameter */
        if (arr.length != -1) {
            var lp = gcall.parameters.parameters[arr.length];
            var pos = get_param_pos (arr.length);
            var type = (Gir.TypeRef) lp.anytype;
            vpar.set_attribute_string ("CCode", "array_length_cname", lp.name);
            vpar.set_attribute_double ("CCode", "array_length_pos", pos);
            vpar.set_attribute_string ("CCode", "array_length_type", type.name);
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
     * user-data (for a closure), or a destroy-notify callback. */
    private bool is_hidden_param (int idx) {
        foreach (Gir.Parameter p in gcall.parameters.parameters) {
            if (p.closure == idx || p.destroy == idx) {
                return true;
            }

            if (p.anytype is Gir.Array) {
                if (((Gir.Array) p.anytype).length == idx) {
                    return true;
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
