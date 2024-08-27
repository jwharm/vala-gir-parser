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

public class Builders.InterfaceBuilder {

    private Gir.Interface ifc;

    public InterfaceBuilder (Gir.Interface cls) {
        this.ifc = cls;
    }

    public Vala.Interface build () {
        /* the interface */
        Vala.Interface vifc = new Vala.Interface (ifc.name, ifc.source_reference);
        vifc.access = SymbolAccessibility.PUBLIC;

        /* prerequisite interfaces */
        foreach (var imp in ifc.implements) {
            var imp_type = DataTypeBuilder.from_name (imp.name, imp.source_reference);
            vifc.add_prerequisite (imp_type);
        }

        /* when no prerequisites were specified, GLib.Object is the default */
        if (ifc.implements.is_empty) {
        vifc.add_prerequisite (DataTypeBuilder.from_name ("GLib.Object"));
        }

        /* c_name */
        vifc.set_attribute_string ("CCode", "cname", ifc.c_type);

        /* version */
        vifc.set_attribute_string ("Version", "since", ifc.version);

        /* type_cname */
        vifc.set_attribute_string ("CCode", "type_cname", ifc.glib_type_struct);

        /* get_type method */
        var type_id = ifc.glib_get_type;
        if (type_id == null) {
            vifc.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            vifc.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add methods */
        foreach (var m in ifc.methods) {
            var vmethod = new MethodBuilder (m).build ();
            vifc.add_method (vmethod);
        }

        /* add fields */
        foreach (var f in ifc.fields) {
            var vfield = new FieldBuilder (f).build ();
            vifc.add_field (vfield);
        }

        return vifc;
    }
}
