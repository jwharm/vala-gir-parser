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

public class Transformations.FunctionToMethod : Object, Transformation {

    /* determine whether this function should be an instance method */
    public bool can_transform (Gir.Node node) {
        if (! (node is Function)) {
            return false;
        }

        var function = (Function) node;
        var builder = new Builders.MethodBuilder (function);
        if (function.parent_node is Gir.Identifier
                && builder.has_parameters ()) {

            /* check if the first parameter is an "instance parameter", i.e. it
             * has the type of the enclosing type */
            unowned var parent = (Gir.Identifier) function.parent_node;
            var g_this = function.parameters.parameters[0];
            if ((g_this.anytype as Gir.TypeRef)?.name != parent.name) {
                return false;
            }

            /* if it's an out parameter, it must be caller-allocated */
            return g_this.direction == IN
                || g_this.direction == UNDEFINED // defaults to IN
                || g_this.caller_allocates;
        }

        return false;
    }

    /* change a function into an instance method */
    public void apply (ref Gir.Node node) {
        unowned var function = (Function) node;
        var first_param = function.parameters.parameters.remove_at (0);
        var inst_param = first_param.cast_to<InstanceParameter> ();
        var method = function.cast_to<Method> ();
        method.parameters.instance_parameter = inst_param;
        node = method;

        if (method.parent_node is EnumBase) {
            /* vapigen seems to never generates a cname for these, probably
            * because gir <enumeration> elements don't have a "c:symbol-prefix"
            * attribute. Explicitly remove the cname for now... */
            method.c_identifier = null;
        }
    }
}
