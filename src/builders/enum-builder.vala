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

public class Builders.EnumBuilder : IdentifierBuilder {

    protected Gir.EnumBase g_enum;

    public EnumBuilder (Gir.EnumBase g_enum) {
        base (g_enum);
        this.g_enum = g_enum;
    }

    public Vala.Enum build_enum () {
        /* the enum */
        Vala.Enum v_enum = new Vala.Enum (g_enum.name, g_enum.source);
        v_enum.access = PUBLIC;

        /* c_name */
        if (g_enum.c_type != generate_cname ()) {
            v_enum.set_attribute_string ("CCode", "cname", g_enum.c_type);
        }

        /* version */
        new InfoAttrsBuilder (g_enum).add_info_attrs (v_enum);

        /* get_type method */
        var type_id = g_enum.glib_get_type;
        if (type_id == null) {
            v_enum.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            v_enum.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* functions */
        foreach (var g_function in g_enum.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_enum.add_method (builder.build_function ());
            } 
        }

        /* methods */
        foreach (var g_method in g_enum.all_of<Gir.Method> ()) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_enum.add_method (builder.build_method ());
            }
        }

        /* cprefix */
        string? common_prefix = null;
        foreach (var g_member in g_enum.members) {
            var name = g_member.c_identifier.ascii_up().replace ("-", "_");
            calculate_common_prefix (ref common_prefix, name);
        }
        v_enum.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* members */
        foreach (var g_member in g_enum.members) {
            var name = g_member.c_identifier
                    .substring (common_prefix.length)
                    .ascii_up()
                    .replace ("-", "_");
            unowned var source = g_member.source;
            var v_value = new Vala.EnumValue (name, null, source, null);
            v_enum.add_value (v_value);
        }

        /* flags */
        v_enum.set_attribute ("Flags", g_enum is Gir.Bitfield);

        return v_enum;
    }

    public Vala.ErrorDomain build_error_domain () {
        /* create the error domain */
        Vala.ErrorDomain v_err = new Vala.ErrorDomain (g_enum.name, g_enum.source);
        v_err.access = PUBLIC;

        /* c_name */
        if (g_enum.c_type != generate_cname ()) {
            v_err.set_attribute_string ("CCode", "cname", g_enum.c_type);
        }

        /* version */
        new InfoAttrsBuilder (g_enum).add_info_attrs (v_err);

        /* get_type method */
        var type_id = g_enum.glib_get_type;
        if (type_id == null) {
            v_err.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            v_err.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* functions */
        foreach (var g_function in g_enum.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_err.add_method (builder.build_function ());
            } 
        }

        /* methods */
        foreach (var g_method in g_enum.all_of<Gir.Method> ()) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_err.add_method (builder.build_method ());
            }
        }

        /* cprefix */
        string? common_prefix = null;
        foreach (var g_member in g_enum.members) {
            var name = g_member.c_identifier.ascii_up().replace ("-", "_");
            calculate_common_prefix (ref common_prefix, name);
        }
        v_err.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* members */
        foreach (var g_member in g_enum.members) {
            var name = g_member.c_identifier
                    .substring (common_prefix.length)
                    .ascii_up()
                    .replace ("-", "_");
            unowned var source = g_member.source;
            var value = new IntegerLiteral(g_member.value);
            v_err.add_code (new ErrorCode.with_value (name, value, source));
        }

        return v_err;
    }

    /* determine the longest prefix that all members have in common */
    private void calculate_common_prefix (ref string? prefix, string cname) {
        if (prefix == null) {
            prefix = cname;
            while (prefix.length > 0 && (! prefix.has_suffix ("_"))) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        } else {
            while (! cname.has_prefix (prefix)) {
                prefix = prefix.substring (0, prefix.length - 1);
            }
        }

        while (prefix.length > 0 &&
            (! prefix.has_suffix ("_") ||
                /* enum values may not consist solely of digits */
                cname.get_char (prefix.length).isdigit ())) {
            prefix = prefix.substring (0, prefix.length - 1);
        }
    }
}
