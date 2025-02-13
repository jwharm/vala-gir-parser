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

    private Symbol v_parent_sym;
    private Gir.Property g_prop;

    public PropertyBuilder (Symbol v_parent_sym, Gir.Property g_prop) {
        this.v_parent_sym = v_parent_sym;
        this.g_prop = g_prop;
    }

    public Symbol build () {
        /* data type */
        var v_type = new DataTypeBuilder (g_prop.anytype).build ();
        v_type.value_owned = g_prop.transfer_ownership != NONE;

        /* name */
        var name = g_prop.name.replace ("-", "_");

        /* create the property */
        var v_prop = new Property (name, v_type, null, null, g_prop.source);
        v_prop.access = PUBLIC;
        v_prop.is_abstract = g_prop.parent_node is Gir.Interface;
        v_parent_sym.add_property (v_prop);

        /* get-accessor */
        if (g_prop.readable) {
            var getter_type = v_type.copy ();
            var getter = find_method (g_prop.getter);
            if (getter != null) {
                var return_value = getter.return_value;
                getter_type.value_owned = return_value.transfer_ownership != NONE;

                /* if the getter is virtual, then the property is virtual */
                if (new MethodBuilder (v_parent_sym, getter).is_invoker_method ()) {
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
                setter_type.value_owned = parameter.transfer_ownership != NONE;

                /* setter method should start with "set_" */
                if (! setter.name.has_prefix ("set_")) {
                    v_prop.set_attribute ("NoAccessorMethod", true);
                }
            } else if (! g_prop.construct_only) {
                v_prop.set_attribute ("NoAccessorMethod", true);
            }

            //  if (g_prop.has_attr ("vala:no-accessor-method")) {
            //      v_prop.set_attribute ("NoAccessorMethod", true);
            //  }

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
        if (v_type is ArrayType) {
            unowned var v_arr_type = (ArrayType) v_type;
            var g_arr_type = g_prop.anytype as Gir.Array;
            var builder = new ParametersBuilder (null, null);
            builder.add_array_attrs (v_prop, v_arr_type, g_arr_type);
            v_arr_type.element_type.value_owned = true;
        }

        /* attributes */
        new InfoAttrsBuilder (g_prop).add_info_attrs (v_prop);

        /* there is no information about the internal ownership, so assume
         * `owned` as default */
        v_prop.property_type.value_owned = true;

        return v_prop;
    }

    /* return true when this property must be omitted from the vapi */
    public bool skip () {
        return ! g_prop.introspectable;
    }

    private Gir.Method? find_method (string? name) {
        if (name != null) {
            foreach (var m in g_prop.parent_node.all_of<Gir.Method> ()) {
                if (m.name == name) {
                    return m;
                }
            }
        }
        return null;
    }
}
