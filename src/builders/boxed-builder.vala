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

public class Builders.BoxedBuilder : IdentifierBuilder {

    private Gir.Node g_rec;

    public BoxedBuilder (Gir.Node g_rec) {
        base (g_rec);
        this.g_rec = g_rec;
    }

    public Class build () {
        /* create a Vala compact class for boxed types */
        Class v_class = new Class (g_rec.get_string ("name"), g_rec.source);
        v_class.access = PUBLIC;

        /* compact */
        v_class.set_attribute ("Compact", g_rec.get_bool ("vala:compact", true));
        
        /* base type */
        if (g_rec.has_attr ("parent")) {
            var base_type = DataTypeBuilder.from_name (g_rec.get_string ("parent"), g_rec.source);
            v_class.add_base_type (base_type);
        }

        /* cname */
        var c_type = g_rec.get_string ("c:type");
        if (c_type != generate_cname ()) {
            v_class.set_attribute_string ("CCode", "cname", c_type);
        }

        /* attributes */
        new InfoAttrsBuilder(g_rec).add_info_attrs (v_class);

        /* CCode attributes */
        set_ccode_attrs (v_class);

        /* add constructors */
        foreach (var g_ctor in g_rec.all_of ("constructor")) {
            var builder = new MethodBuilder (g_ctor);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_constructor ());
            }
        }

        /* add functions */
        foreach (var g_function in g_rec.all_of ("function")) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_rec.all_of ("method")) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_method ());
            } 
        }

        /* add fields */
        foreach (var g_field in g_rec.all_of ("field")) {
            var field_builder = new FieldBuilder (g_field);
            if (! field_builder.skip ()) {
                v_class.add_field (field_builder.build ());
            }
        }

        return v_class;
    }
}
