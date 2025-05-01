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

public class Gir.Constant : InfoAttrs, InfoElements, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public string value { owned get; set; }
    public string? c_type { owned get; set; }
    public string? c_identifier { owned get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public AnyType? anytype { get; set; }

    public Constant (
            InfoAttrsValues info_attrs_values,
            string name,
            string value,
            string? c_type,
            string? c_identifier,
            InfoElementsValues info_elements_values,
            AnyType? anytype,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.value = value;
        this.c_type = c_type;
        this.c_identifier = c_identifier;
        this.info_elements_values = info_elements_values;
        this.anytype = anytype;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_constant (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
        anytype?.accept (visitor);
    }
}

