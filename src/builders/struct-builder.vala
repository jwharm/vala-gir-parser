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

public class Builders.StructBuilder : IdentifierBuilder {

    private Gir.Record g_rec;

    public StructBuilder (Symbol v_parent_sym, Gir.Record g_rec) {
        base (v_parent_sym, g_rec);
        this.g_rec = g_rec;
    }

    public Symbol build () {
        /* the struct */
        Struct v_struct = new Struct (g_rec.name, g_rec.source);
        v_struct.access = PUBLIC;
        v_parent_sym.add_struct (v_struct);

        /* c_name */
        var c_type = g_rec.c_type;
        if (c_type != generate_cname ()) {
            v_struct.set_attribute_string ("CCode", "cname", c_type);
        }

        /* attributes */
        new InfoAttrsBuilder (g_rec).add_info_attrs (v_struct);

        /* get_type method */
        set_ccode_attrs (v_struct);

        /* add constructors */
        foreach (var g_ctor in g_rec.constructors) {
            var builder = new MethodBuilder (v_struct, g_ctor);
            if (! builder.skip ()) {
                builder.build_constructor ();
            } 
        }

        /* add functions */
        foreach (var g_function in g_rec.functions) {
            var builder = new MethodBuilder (v_struct, g_function);
            if (! builder.skip ()) {
                builder.build_function ();
            } 
        }

        /* add methods */
        foreach (var g_method in g_rec.methods) {
            var builder = new MethodBuilder (v_struct, g_method);
            if (! builder.skip ()) {
                builder.build_method ();
            } 
        }

        /* add fields */
        int i = 0;
        foreach (var g_field in g_rec.fields) {
            /* exclude first (parent) field */
            if (i++ == 0 && g_rec.glib_is_gtype_struct_for != null) {
                continue;
            }

            var field_builder = new FieldBuilder (v_struct, g_field);
            if (! field_builder.skip ()) {
                field_builder.build ();
            }
        }

        return v_struct;
    }

    public override bool skip () {
        return (base.skip ()) || g_rec.glib_is_gtype_struct_for != null;
    }
}
