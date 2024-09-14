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

public class Builders.PropertyBuilder : InfoAttrsBuilder {

    private Gir.Property g_prop;

    public PropertyBuilder (Gir.Property g_prop) {
        this.g_prop = g_prop;
    }

    public Gir.InfoAttrs info_attrs () {
        return this.g_prop;
    }

    public Vala.Property build () {
        /* data type */
        var v_type = new DataTypeBuilder (g_prop.anytype).build ();
        v_type.value_owned = g_prop.transfer_ownership != NONE;

        /* name */
        var name = g_prop.name.replace ("-", "_");

        /* create the property */
        var v_prop = new Vala.Property (name, v_type, null, null, g_prop.source_reference);
        v_prop.access = SymbolAccessibility.PUBLIC;
        v_prop.is_abstract = g_prop.parent_node is Gir.Interface;

        /* get-accessor */
        if (g_prop.readable) {
            var getter_type = v_type.copy ();
            var getter = find_method (g_prop.getter);
            if (getter != null) {
                var transfer_ownership = getter.return_value.transfer_ownership;
                getter_type.value_owned = transfer_ownership != NONE;

                /* if the getter is virtual, then the property is virtual */
                if (new MethodBuilder (getter).is_invoker_method ()) {
                    v_prop.is_virtual = true;
                }

                /* getter method should start with "get_" */
                if (! getter.name.has_prefix ("get_")) {
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
        if (g_prop.writable || g_prop.construct_only) {
            var setter_type = v_type.copy ();
            var setter = find_method (g_prop.setter);
            if (setter != null) {
                var parameter = setter.parameters.parameters[0];
                var transfer_ownership = parameter.transfer_ownership;
                setter_type.value_owned = transfer_ownership != NONE;

                /* setter method should start with "set_" */
                if (! setter.name.has_prefix ("set_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else if (! g_prop.construct_only) {
                v_prop.set_attribute ("NoAccessorMethod", true);
            }

            if (v_prop.get_attribute ("NoAccessorMethod") != null) {
                setter_type.value_owned = false;
            }

            v_prop.set_accessor = new PropertyAccessor (
                false, /* not readable */
                g_prop.writable && !g_prop.construct_only,
                g_prop.construct_only || g_prop.construct,
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
        if (g_prop.anytype is Gir.Array) {
            unowned var v_arr_type = (Vala.ArrayType) v_type;
            var g_arr_type = (Gir.Array) g_prop.anytype;
            var builder = new ParametersBuilder (null, null);
            builder.add_array_attrs (v_prop, v_arr_type, g_arr_type);
            v_arr_type.element_type.value_owned = true;
        }

        /* version */
        add_version_attrs (v_prop);

        /* there is no information about the internal ownership, so assume
         * `owned` as default */
        v_prop.property_type.value_owned = true;

        return v_prop;
    }

    private Gir.Method? find_method (string? name) {
        if (name != null) {
            Gee.List<Gir.Method> methods =
                    g_prop.parent_node.all_of (typeof (Gir.Method));
            foreach (var m in methods) {
                if (m.name == name) {
                    return m;
                }
            }
        }
        return null;
    }
}
