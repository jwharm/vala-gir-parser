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

public class Gir.Boxed : InfoAttrs, InfoElements, Identifier, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public string? c_symbol_prefix { owned get; set; }
    public string? glib_type_name { owned get; set; }
    public string? glib_get_type { owned get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public Gee.List<Function> functions { owned get; set; }
    public Gee.List<FunctionInline> function_inlines { owned get; set; }

    public Boxed (
            InfoAttrsValues info_attrs_values,
            string name,
            string? c_symbol_prefix,
            string? glib_type_name,
            string? glib_get_type,
            InfoElementsValues info_elements_values,
            Gee.List<Function> functions,
            Gee.List<FunctionInline> function_inlines,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.c_symbol_prefix = c_symbol_prefix;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.info_elements_values = info_elements_values;
        this.functions = functions;
        this.function_inlines = function_inlines;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_boxed (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }
    }
}

