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

public class Transformations.RefInstanceParam : Object, Transformation {

    /* Determine whether the instance parameter is an INOUT parameter.
     * Such a method should be static (i.e. a function). */
    public bool can_transform (Gir.Node node) {
        if (! (node is Method)) {
            return false;
        }

        unowned var method = (Method) node;
        return method.parameters.instance_parameter.direction == INOUT;
    }

    /* change an instance method into a function */
    public void apply (ref Gir.Node node) {
        unowned Method method = (Method) node;
        method.parameters.parameters.insert (0,
            method.parameters.instance_parameter.cast_to<Gir.Parameter> ());
        node = method.cast_to<Function> ();
    }
}
