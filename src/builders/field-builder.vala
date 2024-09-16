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

public class Builders.FieldBuilder {

    private Gir.Field g_field;

    public FieldBuilder (Gir.Field g_field) {
        this.g_field = g_field;
    }

    public bool skip () {
        return g_field.private
                || g_field.name == "priv"
                || g_field.anytype == null
                || has_naming_conflict ();
    }

    public Vala.Field build () {
        /* type */
        var v_type = new DataTypeBuilder (g_field.anytype).build ();

        /* create the field */
        var v_field = new Field (g_field.name, v_type, null, g_field.source);
        v_field.access = PUBLIC;

        /* version */
        new InfoAttrsBuilder (g_field).add_version_attrs (v_field);

        /* array attributes */
        if (v_type is Vala.ArrayType) {
            unowned var v_arr_type = (Vala.ArrayType) v_type;
            add_array_attrs (v_field, v_arr_type, (Gir.Array) g_field.anytype);
        }

        return v_field;
    }

    public void add_array_attrs (Vala.Symbol v_arr_field,
                                 Vala.ArrayType v_arr_type,
                                 Gir.Array g_arr) {
        /* fixed length */
        if (g_arr.fixed_size != -1) {
            v_arr_type.fixed_length = true;
            v_arr_type.length = new IntegerLiteral (g_arr.fixed_size.to_string ());
            v_arr_field.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another field */
        else if (g_arr.length != -1) {
            var fields = g_field.parent_node.all_of<Gir.Field> ();
            var g_length_field = fields[g_arr.length];
            var g_type = (Gir.TypeRef) g_length_field.anytype;

            v_arr_field.set_attribute_string ("CCode", "array_length_cname", g_length_field.name);

            /* int is the default and can be omitted */
            if (g_type.name != "gint") {
                v_arr_field.set_attribute_string ("CCode", "array_length_type", g_type.name);
            }
        }

        /* no length specified */
        else {
            v_arr_field.set_attribute_bool ("CCode", "array_length", false);
            /* If zero-terminated is missing, there's no length, there's no
             * fixed size, and the name attribute is unset, then zero-terminated
             * is true. */
            if (g_arr.zero_terminated || g_arr.name == null) {
                v_arr_field.set_attribute_bool ("CCode", "array_null_terminated", true);
            }
        }
    }

    /* whatelse has precedence over the field */
    private bool has_naming_conflict () {
        foreach (var child in g_field.parent_node.children) {
            if (child.attrs["name"]?.replace ("-", "_") == g_field.name) {
                return true;
            }
        }

        return false;
    }
}
