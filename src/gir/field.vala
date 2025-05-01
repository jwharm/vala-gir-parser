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

public class Gir.Field : InfoAttrs, InfoElements, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public bool writable { get; set; }
    public bool readable { get; set; }
    public bool private { get; set; }
    public int bits { get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public Callback? callback { get; set; }
    public AnyType? anytype { get; set; }

    public Field (
            InfoAttrsValues info_attrs_values,
            string name,
            bool writable,
            bool readable,
            bool private,
            int bits,
            InfoElementsValues info_elements_values,
            Callback? callback,
            AnyType? anytype,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.writable = writable;
        this.readable = readable;
        this.private = private;
        this.bits = bits;
        this.info_elements_values = info_elements_values;
        this.callback = callback;
        this.anytype = anytype;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_field (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
    }
}

