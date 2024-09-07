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

public class Builders.BoxedBuilder {

    private Gir.Record rec;

    public BoxedBuilder (Gir.Record rec) {
        this.rec = rec;
    }

    public Vala.Class build () {
        /* the class */
        Vala.Class vclass = new Vala.Class (rec.name, rec.source_reference);
        vclass.access = SymbolAccessibility.PUBLIC;
        vclass.set_attribute ("Compact", true);

        /* c_name */
        vclass.set_attribute_string ("CCode", "cname", rec.c_type);

        /* version */
        vclass.set_attribute_string ("Version", "since", rec.version);

        /* get_type method */
        var type_id = rec.glib_get_type + " ()";
        vclass.set_attribute_string ("CCode", "type_id", type_id);

        /* copy_function */
        var copy = rec.copy_function ?? "g_boxed_copy";
        vclass.set_attribute_string ("CCode", "copy_function", copy);

        /* free_function */
        var free = rec.free_function ?? "g_boxed_free";
        vclass.set_attribute_string ("CCode", "free_function", free);

        /* add constructors */
        foreach (var c in rec.constructors) {
            var builder = new MethodBuilder (c);
            if (! builder.skip ()) {
                vclass.add_method (builder.build_constructor ());
            }
        }

        /* add functions */
        foreach (var f in rec.functions) {
            var builder = new MethodBuilder (f);
            if (! builder.skip ()) {
                vclass.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var m in rec.methods) {
            var builder = new MethodBuilder (m);
            if (! builder.skip ()) {
                vclass.add_method (builder.build_method ());
            } 
        }

        /* add fields */
        foreach (var f in rec.fields) {
            var field_builder = new FieldBuilder (f);
            if (! field_builder.skip ()) {
                vclass.add_field (field_builder.build ());
            }
        }

        return vclass;
    }
}
