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

    public Vala.Class build () {
        /* create a Vala compact class for boxed types */
        Vala.Class v_class = new Vala.Class (g_rec.get_string ("name"), g_rec.source);
        v_class.access = PUBLIC;

        /* compact */
        v_class.set_attribute ("Compact", g_rec.get_bool ("compact", true));
        
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

        /* csuffix */
        var expected_prefix = Symbol.camel_case_to_lower_case (g_rec.get_string ("name"));
        var symbol_prefix = g_rec.get_string ("c:symbol-prefix");
        if (symbol_prefix != expected_prefix) {
            v_class.set_attribute_string ("CCode", "lower_case_csuffix", symbol_prefix);
        }

        /* version */
        new InfoAttrsBuilder(g_rec).add_info_attrs (v_class);

        /* get_type method */
        var type_id = g_rec.get_string ("glib:get-type") + " ()";
        v_class.set_attribute_string ("CCode", "type_id", type_id);

        /* if copy_function and/or free_function are set */
        if (g_rec.has_attr ("glib:copy-function") || g_rec.has_attr ("glib:free-function")) {
            var copy_func = g_rec.get_string ("glib:copy-function") ?? "g_boxed_copy";
            var free_func = g_rec.get_string ("glib:free-function") ?? "g_boxed_free";
            v_class.set_attribute_string ("CCode", "copy_function", copy_func);
            v_class.set_attribute_string ("CCode", "free_function", free_func);
        }
        /* else, try to find a ref_function and unref_function */
        else {
            var ref_func = find_method_with_suffix ("_ref");
            var unref_func = find_method_with_suffix ("_unref");
            if (ref_func != null && unref_func != null) {
                v_class.set_attribute_string ("CCode", "ref_function", ref_func);
                v_class.set_attribute_string ("CCode", "unref_function", unref_func);
            }
            /* else, default to g_boxed_copy and g_boxed_free */
            else {
                v_class.set_attribute_string ("CCode", "copy_function", "g_boxed_copy");
                v_class.set_attribute_string ("CCode", "free_function", "g_boxed_free");
            }
        }

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

    private string? find_method_with_suffix (string suffix) {
        foreach (var g_method in g_rec.all_of ("method")) {
            if (g_method.has_attr ("c:identifier")
                    && g_method.get_string ("c:identifier").has_suffix (suffix)) {
                return g_method.get_string ("c:identifier");
            }
        }
        return null;
    }
}
