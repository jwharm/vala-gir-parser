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

    private Symbol v_parent_sym;
    private Gir.Field g_field;

    public FieldBuilder (Symbol v_parent_sym, Gir.Field g_field) {
        this.v_parent_sym = v_parent_sym;
        this.g_field = g_field;
    }

    public bool skip () {
        return g_field.private
                || g_field.name == "priv"
                || g_field.anytype == null
                || has_naming_conflict ();
    }

    public Symbol build () {
        /* type */
        var v_type = new DataTypeBuilder (g_field.anytype).build ();

        /* create the field */
        var v_field = new Field (g_field.name, v_type, null, g_field.source);
        v_field.access = PUBLIC;
        v_parent_sym.add_field (v_field);

        /* attributes */
        new InfoAttrsBuilder (g_field).add_info_attrs (v_field);

        /* array attributes */
        if (v_type is ArrayType) {
            unowned var v_arr_type = (ArrayType) v_type;
            add_array_attrs (v_field, v_arr_type, (Gir.Array) g_field.anytype);
        }

        /* CCode attributes */
        //  if (g_field.has_attr("vala:delegate-target")) {
        //      var dlg_target = g_field.get_bool ("vala:delegate-target");
        //      v_field.set_attribute_bool ("CCode", "delegate_target", dlg_target);
        //  }

        //  if (g_field.has_attr ("vala:delegate-target-cname")) {
        //      var cname = g_field.get_string ("vala:delegate-target-cname");
        //      v_field.set_attribute_string ("CCode", "delegate_target_cname", cname);
        //  }

        //  if (g_field.has_attr ("vala:destroy-notify-cname")) {
        //      var cname = g_field.get_string ("vala:destroy-notify-cname");
        //      v_field.set_attribute_string ("CCode", "destroy_notify_cname", cname);
        //  }
        
        return v_field;
    }

    public void add_array_attrs (Symbol v_arr_field,
                                 ArrayType v_arr_type,
                                 Gir.Array g_arr) {
        /* fixed length */
        if (g_arr.fixed_size != -1) {
            v_arr_type.fixed_length = true;
            v_arr_type.length = new IntegerLiteral (g_arr.attrs["fixed-size"]);
            v_arr_field.set_attribute_bool ("CCode", "array_length", false);
        }

        /* length in another field */
        else if (g_arr.length != -1) {
            var fields = g_field.parent_node.all_of<Gir.Field> ();
            var g_length_field = fields[g_arr.length];
            var g_type = g_length_field.anytype;
            var name = g_length_field.name;
            v_arr_field.set_attribute_string ("CCode", "array_length_cname", name);

            /* int is the default and can be omitted */
            var g_type_name = g_type.name;
            if (g_type_name != "gint") {
                v_arr_field.set_attribute_string ("CCode", "array_length_type", g_type_name);
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
        var name = g_field.name;
        foreach (var child in g_field.parent_node.children) {
            if (child == g_field) {
                continue;
            }
            
            if (child.attrs["name"]?.replace ("-", "_") == name) {
                return true;
            }
        }

        return false;
    }
}
