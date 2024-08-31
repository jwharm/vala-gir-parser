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

public class Builders.EnumBuilder {

    private Gir.EnumBase enm;

    public EnumBuilder (Gir.EnumBase enm) {
        this.enm = enm;
    }

    public Vala.Enum build () {
        /* the enum */
        Vala.Enum venum = new Vala.Enum (enm.name, enm.source_reference);
        venum.access = SymbolAccessibility.PUBLIC;

        /* c_name */
        venum.set_attribute_string ("CCode", "cname", enm.c_type);

        /* version */
        venum.set_attribute_string ("Version", "since", enm.version);

        /* get_type method */
        var type_id = enm.glib_get_type;
        if (type_id == null) {
            venum.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            venum.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add functions */
        foreach (var f in enm.functions) {
            var builder = new MethodBuilder (f);
            if (! builder.skip ()) {
                venum.add_method (builder.build_function ());
            } 
        }

        /* members */
        string? common_prefix = null;
        foreach (var member in enm.members) {
            string name = member.c_identifier.ascii_up().replace ("-", "_");
            var value = new Vala.EnumValue (name, null, member.source_reference, null);
            venum.add_value (value);
            calculate_common_prefix (ref common_prefix, name);
        }

        /* cprefix */
        venum.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* flags */
        venum.set_attribute ("Flags", enm is Gir.Bitfield);

        return venum;
    }

    private void calculate_common_prefix (ref string? prefix, string cname) {
        if (prefix == null) {
            prefix = cname;
            while (prefix.length > 0 && !prefix.has_suffix ("_")) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        } else {
            while (!cname.has_prefix (prefix)) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        }

        while (prefix.length > 0 &&
            (! prefix.has_suffix ("_") ||
                (cname.get_char (prefix.length).isdigit () && (cname.length - prefix.length) <= 1))) {
            // enum values may not consist solely of digits
            prefix = prefix.substring (0, prefix.length - 1);
        }
    }
}
