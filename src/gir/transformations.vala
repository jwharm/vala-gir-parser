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

/**
 * Contains transformations that are applied to the gir tree before metadata
 * is applied and the Vala AST is generated.
 */
namespace Gir {

    public interface Transformation : Object {
        public abstract bool can_transform (Node node);
        public abstract void apply (ref Node node);
    }

    public class FunctionToMethod : Object, Transformation {

        /* determine whether this function should be an instance method */
        public bool can_transform (Node node) {
            if (node.tag != "function") {
                return false;
            }

            if (node.parent_node.tag != "namespace"
                    && node.has_any ("parameters")
                    && node.any_of ("parameters").has_any ("parameter")) {

                /* check if the first parameter is an "instance parameter", i.e.
                 * it has the type of the enclosing type */
                var parent_type = node.parent_node.get_string ("name");
                var self = node.any_of ("parameters").children[0];
                var self_type = self.any_of ("type")?.get_string ("name");
                if (self_type != null && self_type != parent_type) {
                    return false;
                }

                /* if it's an out parameter, it must be caller-allocated */
                return (self.get_string ("direction") ?? "in") == "in"
                     || self.get_bool ("caller-allocates");
            }

            return false;
        }

        /* change a function into an instance method */
        public void apply (ref Node node) {
            node.any_of ("parameters").children[0].tag = "instance-parameter";
            node.tag = "method";

            /* Fix attributes that refer to a parameter by index */
            var return_array = node.any_of ("return-value").any_of ("array");
            update_idx (return_array, "length", -1);
            foreach (var p in node.any_of ("parameters").all_of ("parameter")) {
                update_idx (p, "closure", -1);
                update_idx (p, "destroy", -1);
                update_idx (p.any_of ("array"), "length", -1);
            }

            /* vapigen seems to never generates a cname for enums, probably
             * because gir <enumeration> elements don't have a "c:symbol-prefix"
             * attribute. Explicitly remove the cname for now... */
            if (node.parent_node.tag == "enumeration"
                    || node.parent_node.tag == "bitfield") {
                node.attrs.remove ("c:identifier");
            }
        }
    }

    public class OutArgToReturnValue : Object, Transformation {

        /* determine if there is one out parameter that could be the return
         * value */
        public bool can_transform (Node node) {
            var return_value = node.any_of ("return-value");
            var parameters = node.any_of ("parameters");

            if (return_value == null || parameters == null) {
                return false;
            }

            var return_type = return_value.any_of ("type")?.get_string ("name");
            var has_parameters = parameters.has_any ("parameter");

            if (! (return_type == "none" && has_parameters)) {
                return false;
            }

            /* count the number of out-parameters */
            var num_out_parameters = 0;
            foreach (var p in node.any_of ("parameters").all_of ("parameter")) {
                if (p.get_string ("direction") == "out") {
                    num_out_parameters++;
                }
            }

            var last_param = node.any_of ("parameters").children.last ();
            return num_out_parameters == 1
                && last_param.get_string ("direction") == "out"
                && last_param.get_bool ("nullable") == false;
        }

        /* change the out parameter to the return value */
        public void apply (ref Node node) {
            var last_param = node.any_of ("parameters").children.last ();
            
            /* set return type to the type of the out-parameter */
            node.any_of ("return-value").children = last_param.children;

            /* remove the out-parameter */
            node.any_of ("parameters").children.remove (last_param);
        }
    }

    public class RefInstanceParam : Object, Transformation {

        /* Determine whether the instance parameter is an INOUT parameter. Such
         * a method should be static (i.e. a function). */
        public bool can_transform (Node node) {
            return node.tag == "method"
                && node.any_of ("parameters")
                       .any_of ("instance-parameter")
                       .get_string ("direction") == "inout";
        }

        /* change an instance method into a function */
        public void apply (ref Node node) {
            node.any_of ("parameters").children[0].tag = "parameter";
            node.tag = "function";

            /* Fix attributes that refer to a parameter by index */
            var return_array = node.any_of ("return-value").any_of ("array");
            update_idx (return_array, "length", 1);
            foreach (var p in node.any_of ("parameters").all_of ("parameter")) {
                update_idx (p, "closure", 1);
                update_idx (p, "destroy", 1);
                update_idx (p.any_of ("array"), "length", 1);
            }
        }
    }

    public class RemoveFirstVararg : Object, Transformation {

        /* determine if this parameter list has a "first vararg" parameter */
        public bool can_transform (Node node) {
            if (node.tag != "parameters") {
                return false;
            }

            var params = node.all_of ("parameter");
            return params.size > 1
                    && params[params.size - 1].has_any ("varargs")
                    && params[params.size - 2].get_string ("name")
                                              .has_prefix ("first_");
        }

        /* remove the "first vararg" parameter */
        public void apply (ref Node node) {
            var params = node.all_of ("parameter");
            params.remove_at (params.size - 2);
        }
    }

    /* Update an integer attribute value by the requested amount. For example,
     * to change the "length" attribute of an <array> element from "2" to "1",
     * call update_idx (array, "length", -1)
     *
     * When the node is NULL or doesn't have this attribute, nothing is updated.
     */
    static void update_idx (Node? node, string attr_key, int delta) {
        if (node != null && node.has_attr (attr_key)) {
            node.set_int (attr_key, node.get_int (attr_key) + delta);
        }
    }
}
