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

public class Transformations.OutArgToReturnValue : Transformation {

    public void apply (Gir.Node node) {
        if (node is Callable) {
            if (! (node is Constructor)) {
                unowned var callable = (Callable) node;
                if (can_transform (callable)) {
                    move_out_parameter (callable);
                }
            }
        } else {
            foreach (var child_node in node.children) {
                apply (child_node);
            }
        }
    }

    /* determine whether there is one out parameter that could be the
     * return value */
    private bool can_transform (Callable callable) {
        var builder = new Builders.MethodBuilder (callable);
        var returns_void = callable.return_value.anytype is TypeRef
                && ((TypeRef) callable.return_value.anytype).name == "none";

        if (! (returns_void && builder.has_parameters ())) {
            return false;
        }

        var parameters = callable.parameters.parameters;
        var last_param = parameters[parameters.size - 1];

        /* count the number of out-parameters */
        var num_out_parameters = 0;
        foreach (var p in parameters) {
            if (p.direction == OUT) {
                num_out_parameters++;
            }
        }

        return num_out_parameters == 1
            && last_param.direction == OUT
            && (! last_param.nullable);
    }

    /* change the out parameter to the return value */
    private void move_out_parameter (Callable callable) {
        var last_param = callable.parameters.parameters.last ();
        
        /* set return type to the type of the out-parameter */
        callable.return_value.anytype = last_param.anytype;

        /* remove the out-parameter */
        callable.parameters.parameters.remove (last_param);
    }
}
 