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

using Gir;

public class Transformations.RemoveFirstVararg : Object, Transformation {

    /* determine whether this parameter list has a "first vararg" parameter */
    public bool can_transform (Gir.Node node) {
        if (! (node is Parameters)) {
            return false;
        }

        var params = ((Parameters) node).parameters;
        return params.size > 1
                && params[params.size - 1].varargs != null
                && params[params.size - 2].name.has_prefix ("first_");
    }

    /* remove the "first vararg" parameter */
    public void apply (ref Gir.Node node) {
        var params = ((Parameters) node).parameters;
        params.remove_at (params.size - 2);
    }
}
