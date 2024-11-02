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

    protected Gir.Node g_enum;

    public EnumBuilder (Gir.Node g_enum) {
        base (g_enum);
        this.g_enum = g_enum;
    }

    public Vala.Enum build_enum () {
        /* create the enum */
        Vala.Enum v_enum = new Vala.Enum (g_enum.get_string ("name"), g_enum.source);

        build_common (v_enum);

        /* flags */
        v_enum.set_attribute ("Flags", g_enum.tag == "bitfield");

        return v_enum;
    }

    public Vala.ErrorDomain build_error_domain () {
        /* create the error domain */
        Vala.ErrorDomain v_err = new Vala.ErrorDomain (g_enum.get_string ("name"), g_enum.source);
        
        build_common (v_err);
        
        return v_err;
    }

    private void build_common (Vala.Symbol v_sym) {
        v_sym.access = PUBLIC;

        /* cname */
        var c_type = g_enum.get_string ("c:type");
        if (c_type != generate_cname ()) {
            v_sym.set_attribute_string ("CCode", "cname", c_type);
        }

        /* attributes */
        new InfoAttrsBuilder (g_enum).add_info_attrs (v_sym);

        /* CCode attributes */
        set_ccode_attrs (v_sym);

        /* functions */
        foreach (var g_function in g_enum.all_of ("function")) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_sym.add_method (builder.build_function ());
            } 
        }

        /* methods */
        foreach (var g_method in g_enum.all_of ("method")) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_sym.add_method (builder.build_method ());
            }
        }

        /* cprefix */
        string? common_prefix = null;
        foreach (var g_member in g_enum.all_of ("member")) {
            var name = g_member.get_string ("c:identifier")
                               .ascii_up()
                               .replace ("-", "_");
            calculate_common_prefix (ref common_prefix, name);
        }
        v_sym.set_attribute_string ("CCode", "cprefix", common_prefix);

        /* members */
        foreach (var g_member in g_enum.all_of ("member")) {
            var name = g_member.get_string ("c:identifier")
                    .substring (common_prefix.length)
                    .ascii_up()
                    .replace ("-", "_");
            unowned var source = g_member.source;
            if (v_sym is Vala.Enum) {
                var v_value = new Vala.EnumValue (name, null, source, null);
                unowned var v_enum = (Vala.Enum) v_sym;
                v_enum.add_value (v_value);
            } else {
                var value = new IntegerLiteral(g_member.get_string ("value"));
                unowned var v_err = (Vala.ErrorDomain) v_sym;
                v_err.add_code (new ErrorCode.with_value (name, value, source));
            }
        }
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
