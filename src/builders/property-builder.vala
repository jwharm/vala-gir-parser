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

public class Builders.PropertyBuilder {

    private Gir.Node g_prop;

    public PropertyBuilder (Gir.Node g_prop) {
        this.g_prop = g_prop;
    }

    public Vala.Property build () {
        /* data type */
        var v_type = new DataTypeBuilder (g_prop.any_of ("type", "array")).build ();
        v_type.value_owned = g_prop.get_string ("transfer-ownership") != "none";

        /* name */
        var name = g_prop.get_string ("name").replace ("-", "_");

        /* create the property */
        var v_prop = new Vala.Property (name, v_type, null, null, g_prop.source);
        v_prop.access = PUBLIC;
        v_prop.is_abstract = g_prop.parent_node.tag == "interface";

        var prop_readable = g_prop.get_bool ("readable", true);
        var prop_writable = g_prop.get_bool ("writable", false);
        var prop_construct = g_prop.get_bool ("construct", false);
        var prop_construct_only = g_prop.get_bool ("construct-only", false);

        /* get-accessor */
        if (prop_readable) {
            var getter_type = v_type.copy ();
            var getter = find_method (g_prop.get_string ("getter"));
            if (getter != null) {
                var return_value = getter.any_of ("return-value");
                var transfer_ownership = return_value.get_string ("transfer-ownership");
                getter_type.value_owned = transfer_ownership != "none";

                /* if the getter is virtual, then the property is virtual */
                if (new MethodBuilder (getter).is_invoker_method ()) {
                    v_prop.is_virtual = true;
                }

                /* getter method should start with "get_" */
                if (! getter.get_string ("name").has_prefix ("get_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else {
                v_prop.set_attribute ("NoAccessorMethod", true);
                getter_type.value_owned = true;
            }

            v_prop.get_accessor = new PropertyAccessor (
                true,  /* readable */
                false, /* not writable */
                false, /* not construct */
                getter_type,
                null,
                null
            );
        }

        /* set-accessor */
        if (prop_writable || prop_construct_only) {
            var setter_type = v_type.copy ();
            var setter = find_method (g_prop.get_string ("setter"));
            if (setter != null) {
                var parameter = setter.any_of ("parameters").any_of ("parameter");
                var transfer_ownership = parameter.get_string ("transfer-ownership");
                setter_type.value_owned = transfer_ownership != "none";

                /* setter method should start with "set_" */
                if (! setter.get_string ("name").has_prefix ("set_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else if (! prop_construct_only) {
                v_prop.set_attribute ("NoAccessorMethod", true);
            }

            if (g_prop.has_attr ("no-accessor-method")) {
                v_prop.set_attribute ("NoAccessorMethod", true);
            }

            if (v_prop.get_attribute ("NoAccessorMethod") != null) {
                setter_type.value_owned = false;
            }

            v_prop.set_accessor = new PropertyAccessor (
                false, /* not readable */
                prop_writable && !prop_construct_only,
                prop_construct_only || prop_construct,
                setter_type,
                null,
                null
            );
        }

        /* When accessor method was not found, set getter and setter ownership
         * to gobject defaults */
        if (v_prop.get_attribute ("NoAccessorMethod") != null) {
            if (v_prop.get_accessor != null) {
                v_prop.get_accessor.value_type.value_owned = true;
            }
            if (v_prop.set_accessor != null) {
                v_prop.set_accessor.value_type.value_owned = false;
            }
        }

        /* array attributes */
        if (v_type is Vala.ArrayType) {
            unowned var v_arr_type = (Vala.ArrayType) v_type;
            var g_arr_type = g_prop.any_of ("array");
            var builder = new ParametersBuilder (null, null);
            builder.add_array_attrs (v_prop, v_arr_type, g_arr_type);
            v_arr_type.element_type.value_owned = true;
        }

        /* version */
        new InfoAttrsBuilder (g_prop).add_info_attrs (v_prop);

        /* there is no information about the internal ownership, so assume
         * `owned` as default */
        v_prop.property_type.value_owned = true;

        return v_prop;
    }

    private Gir.Node? find_method (string? name) {
        if (name != null) {
            foreach (var m in g_prop.parent_node.all_of ("method")) {
                if (m.get_string ("name") == name) {
                    return m;
                }
            }
        }
        return null;
    }
}
