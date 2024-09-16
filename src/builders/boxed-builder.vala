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

public class Builders.BoxedBuilder : IdentifierBuilder, InfoAttrsBuilder {

    private Gir.Record g_rec;

    public BoxedBuilder (Gir.Record g_rec) {
        this.g_rec = g_rec;
    }

    public Gir.InfoAttrs info_attrs () {
        return this.g_rec;
    }

    public Vala.Class build () {
        /* create a Vala compact class for boxed types */
        Vala.Class v_class = new Vala.Class (g_rec.name, g_rec.source_reference);
        v_class.access = PUBLIC;
        v_class.set_attribute ("Compact", true);

        /* cname */
        if (g_rec.c_type != generate_cname (g_rec)) {
            v_class.set_attribute_string ("CCode", "cname", g_rec.c_type);
        }

        /* csuffix */
        var expected_prefix = Symbol.camel_case_to_lower_case (g_rec.name);
        if (g_rec.c_symbol_prefix != expected_prefix) {
            v_class.set_attribute_string ("CCode", "lower_case_csuffix", g_rec.c_symbol_prefix);
        }

        /* version */
        add_version_attrs (v_class);

        /* get_type method */
        var type_id = g_rec.glib_get_type + " ()";
        v_class.set_attribute_string ("CCode", "type_id", type_id);

        /* if copy_function and/or free_function are set */
        if (g_rec.copy_function != null || g_rec.free_function != null) {
            var copy_func = g_rec.copy_function ?? "g_boxed_copy";
            var free_func = g_rec.free_function ?? "g_boxed_free";
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
        foreach (var g_ctor in g_rec.constructors) {
            var builder = new MethodBuilder (g_ctor);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_constructor ());
            }
        }

        /* add functions */
        foreach (var g_function in g_rec.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_rec.methods) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_method ());
            } 
        }

        /* add fields */
        foreach (var g_field in g_rec.fields) {
            var field_builder = new FieldBuilder (g_field);
            if (! field_builder.skip ()) {
                v_class.add_field (field_builder.build ());
            }
        }

        return v_class;
    }

    private string? find_method_with_suffix (string suffix) {
        foreach (var g_method in g_rec.methods) {
            if (g_method.c_identifier != null
                    && g_method.c_identifier.has_suffix (suffix)) {
                return g_method.c_identifier;
            }
        }
        return null;
    }
}
