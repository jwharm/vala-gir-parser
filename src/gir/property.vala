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

public class Gir.Property : InfoAttrs, InfoElements, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public bool writable { get; set; }
    public bool readable { get; set; }
    public bool construct { get; set; }
    public bool construct_only { get; set; }
    public Link<Method> setter { owned get; set; }
    public Link<Method> getter { owned get; set; }
    public string? default_value { owned get; set; }
    public TransferOwnership transfer_ownership { get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public AnyType anytype { get; set; }

    public Property (
            InfoAttrsValues info_attrs_values,
            string name,
            bool writable,
            bool readable,
            bool construct,
            bool construct_only,
            string? setter,
            string? getter,
            string? default_value,
            TransferOwnership transfer_ownership,
            InfoElementsValues info_elements_values,
            AnyType anytype,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.writable = writable;
        this.readable = readable;
        this.construct = construct;
        this.construct_only = construct_only;
        this.setter = new Link<Method> (setter);
        this.getter = new Link<Method> (getter);
        this.default_value = default_value;
        this.transfer_ownership = transfer_ownership;
        this.info_elements_values = info_elements_values;
        this.anytype = anytype;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_property (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
        anytype.accept (visitor);
    }
}

