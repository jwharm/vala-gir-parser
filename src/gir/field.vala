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

public class Gir.Field : InfoAttrs, DocElements, InfoElements, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public bool writable { get; set; }
    public bool readable { get; set; }
    public bool private { get; set; }
    public int bits { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Callback? callback { get; set; }
    public AnyType? anytype { get; set; }

    public Field (
            InfoAttrsParameters info_attrs,
            string name,
            bool writable,
            bool readable,
            bool private,
            int bits,
            InfoElementsParameters info_elements,
            Callback? callback,
            AnyType? anytype,
            Gir.Xml.Reference? source) {
        base(source);
        init_info_attrs (info_attrs);
        this.name = name;
        this.writable = writable;
        this.readable = readable;
        this.private = private;
        this.bits = bits;
        init_info_elements (info_elements);
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

