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

public class Builders.StructBuilder : IdentifierBuilder, InfoAttrsBuilder {

    private Gir.Record g_rec;

    public StructBuilder (Gir.Record g_rec) {
        this.g_rec = g_rec;
    }

    public Gir.InfoAttrs info_attrs () {
        return this.g_rec;
    }

    public Vala.Struct build () {
        /* the struct */
        Vala.Struct v_struct = new Vala.Struct (g_rec.name, g_rec.source);
        v_struct.access = PUBLIC;

        /* c_name */
        if (g_rec.c_type != generate_cname (g_rec)) {
            v_struct.set_attribute_string ("CCode", "cname", g_rec.c_type);
        }

        /* version */
        add_version_attrs (v_struct);

        /* get_type method */
        var type_id = g_rec.glib_get_type;
        if (type_id == null) {
            v_struct.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            v_struct.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add constructors */
        foreach (var g_ctor in g_rec.constructors) {
            var builder = new MethodBuilder (g_ctor);
            if (! builder.skip ()) {
                v_struct.add_method (builder.build_constructor ());
            } 
        }

        /* add functions */
        foreach (var g_function in g_rec.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_struct.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_rec.methods) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_struct.add_method (builder.build_method ());
            } 
        }

        /* add fields */
        bool first = true;
        foreach (var g_field in g_rec.fields) {
            /* exclude first (parent) field */
            if (first) {
                first = false;
                if (g_rec.glib_is_gtype_struct_for != null) {
                    continue;
                }
            }

            var field_builder = new FieldBuilder (g_field);
            if (! field_builder.skip ()) {
                v_struct.add_field (field_builder.build ());
            }
        }

        return v_struct;
    }

    public bool skip () {
        return (! g_rec.introspectable)
                || g_rec.glib_is_gtype_struct_for != null;
    }
}
