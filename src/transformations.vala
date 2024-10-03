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

namespace Transformations {

    public interface Transformation : Object {
        public abstract bool can_transform (Gir.Node node);
        public abstract void apply (ref Gir.Node node);
    }
    
    public class FunctionToMethod : Object, Transformation {
    
        /* determine whether this function should be an instance method */
        public bool can_transform (Gir.Node node) {
            if (! (node is Function)) {
                return false;
            }
    
            var function = (Function) node;
            if (function.parent_node is Gir.Identifier
                    && function.parameters != null
                    && (! function.parameters.parameters.is_empty)) {
    
                /* check if the first parameter is an "instance parameter",
                 * i.e. it has the type of the enclosing type */
                unowned var parent = (Gir.Identifier) function.parent_node;
                var self = function.parameters.parameters[0];
                if ((self.anytype as Gir.TypeRef)?.name != parent.name) {
                    return false;
                }
    
                /* if it's an out parameter, it must be caller-allocated */
                return self.direction == IN
                    || self.direction == UNDEFINED // defaults to IN
                    || self.caller_allocates;
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
    
    public class OutArgToReturnValue : Object, Transformation {
    
        /* determine whether there is one out parameter that could be the
         * return value */
        public bool can_transform (Gir.Node node) {
            if (! (node is Callable)) {
                return false;
            }
    
            unowned var callable = (Callable) node;
            var returns_void = callable.return_value.anytype is TypeRef
                    && ((TypeRef) callable.return_value.anytype).name == "none";
            var has_parameters = callable.parameters != null
                    && (! callable.parameters.parameters.is_empty);
    
            if (! (returns_void && has_parameters)) {
                return false;
            }
    
            /* count the number of out-parameters */
            var num_out_parameters = 0;
            foreach (var p in callable.parameters.parameters) {
                if (p.direction == OUT) {
                    num_out_parameters++;
                }
            }
    
            var last_param = callable.parameters.parameters.last ();
            return num_out_parameters == 1
                && last_param.direction == OUT
                && (! last_param.nullable);
        }
    
        /* change the out parameter to the return value */
        public void apply (ref Gir.Node node) {
            unowned var callable = (Callable) node;
            var last_param = callable.parameters.parameters.last ();
            
            /* set return type to the type of the out-parameter */
            callable.return_value.anytype = last_param.anytype;
    
            /* remove the out-parameter */
            callable.parameters.parameters.remove (last_param);
        }
    }
    
    public class RefInstanceParam : Object, Transformation {
    
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
            unowned var method = (Method) node;
            method.parameters.parameters.insert (0,
                method.parameters.instance_parameter.cast_to<Gir.Parameter> ());
            method.parameters.remove<InstanceParameter> ();
            node = method.cast_to<Function> ();
        }
    }
    
    public class RemoveFirstVararg : Object, Transformation {
    
        /* determine if this parameter list has a "first vararg" parameter */
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
}
