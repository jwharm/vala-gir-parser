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

public class Builders.ClassBuilder {

    private Gir.Class cls;

    public ClassBuilder (Gir.Class cls) {
        this.cls = cls;
    }

    public Vala.Class build () {
        /* the class */
        Vala.Class vclass = new Vala.Class (cls.name, cls.source_reference);
        vclass.access = SymbolAccessibility.PUBLIC;
        vclass.is_abstract = cls.abstract;
        vclass.is_sealed = cls.final;

        /* parent class */
        if (cls.parent != null) {
            var parent_type = DataTypeBuilder.from_name (cls.parent, cls.source_reference);
            vclass.add_base_type (parent_type);
        }

        /* implemented interfaces */
        foreach (var imp in cls.implements) {
            var imp_type = DataTypeBuilder.from_name (imp.name, imp.source_reference);
            vclass.add_base_type (imp_type);
        }

        /* c name */
        vclass.set_attribute_string ("CCode", "cname", cls.c_type);

        /* version */
        vclass.set_attribute_string ("Version", "since", cls.version);

        /* get_type method */
        var type_id = cls.glib_get_type;
        if (type_id == null) {
            vclass.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            vclass.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add methods */
        foreach (var m in cls.methods) {
            var vmethod = new MethodBuilder (m).build ();
            vclass.add_method (vmethod);
        }

        /* add fields */
        foreach (var f in cls.fields) {
            var vfield = new FieldBuilder (f).build ();
            vclass.add_field (vfield);
        }

        /* always provide constructor in generated bindings
         * to indicate that implicit Object () chainup is allowed */
        if (cls.constructors.is_empty) {
            var cm = new CreationMethod (null, null, cls.source_reference);
            cm.has_construct_function = false;
            cm.access = SymbolAccessibility.PROTECTED;
            vclass.add_method (cm);
        }

        return vclass;
    }
}
