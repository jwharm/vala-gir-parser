/* vala-gir-parser
 * Copyright (C) 2025 Jan-Willem Harmannij
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

public class Gir.Enumeration : InfoAttrs, InfoElements, Identifier, EnumBase, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public string c_type { owned get; set; }
    public string? glib_type_name { owned get; set; }
    public string? glib_get_type { owned get; set; }
    public string? glib_error_domain { owned get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public Gee.List<Member> members { owned get; set; }
    public Gee.List<Function> functions { owned get; set; }
    public Gee.List<FunctionInline> function_inlines { owned get; set; }

    public Enumeration (
            InfoAttrsValues info_attrs_values,
            string name,
            string c_type,
            string? glib_type_name,
            string? glib_get_type,
            string? glib_error_domain,
            InfoElementsValues info_elements_values,
            Gee.List<Member> members,
            Gee.List<Function> functions,
            Gee.List<FunctionInline> function_inlines,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.c_type = c_type;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.glib_error_domain = glib_error_domain;
        this.info_elements_values = info_elements_values;
        this.members = members;
        this.functions = functions;
        this.function_inlines = function_inlines;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_enumeration (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);

        foreach (var member in members) {
            member.accept (visitor);
        }

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }
    }
}

