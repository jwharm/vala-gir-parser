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

    private Gir.Method method;

    public MethodBuilder (Gir.Method method) {
        this.method = method;
    }

    public Vala.Method build () {
        /* return type */
        var return_value = method.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* the method itself */
        var vmethod = new Method (method.name, return_type, method.source_reference);
        vmethod.access = SymbolAccessibility.PUBLIC;

        /* c name */
        vmethod.set_attribute_string ("CCode", "cname", method.c_identifier);

        /* parameters */
        if (method.parameters != null) {
            foreach (Gir.Parameter p in method.parameters.parameters) {
                Vala.Parameter vpar;
                if (p.varargs != null) {
                    vpar = new Vala.Parameter.with_ellipsis (p.source_reference);
                } else {
                    var p_type = new DataTypeBuilder (p.anytype).build ();
                    vpar = new Vala.Parameter (p.name, p_type, p.source_reference);
                }
                vmethod.add_parameter (vpar);
            }
        }

        /* throws */
        if (method.throws) {
            vmethod.add_error_type (new Vala.ErrorType (null, null));
        }

        return vmethod;
    }
}
