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

public class Builders.CallableBuilder {

    protected Gir.Callable callable;

    protected CallableBuilder (Gir.Callable callable) {
        this.callable = callable;
    }

    protected void add_parameters (Vala.Callable vcall) {
        if (callable.parameters == null) {
            return;
        }

        foreach (Gir.Parameter p in callable.parameters.parameters) {
            Vala.Parameter vpar;
            if (p.varargs != null) {
                vpar = new Vala.Parameter.with_ellipsis (p.source_reference);
            } else {
                var p_type = new DataTypeBuilder (p.anytype).build ();
                vpar = new Vala.Parameter (p.name, p_type, p.source_reference);
            }
            vcall.add_parameter (vpar);
        }
    }
}
