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
        var return_type = new TypedValueBuilder (return_value).build ();

        /* the method itself */
        var vmethod = new Method (method.name, return_type, method.source_reference);
        vmethod.access = SymbolAccessibility.PUBLIC;

        /* parameters */
        if (method.parameters != null) {
            foreach (Gir.Parameter p in method.parameters.parameters) {
                var p_type = new TypedValueBuilder (p).build ();
                var param = new Vala.Parameter (p.name, p_type, p.source_reference);
                vmethod.add_parameter (param);
            }
        }

        return vmethod;
    }
}
