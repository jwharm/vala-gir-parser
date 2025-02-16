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

public class Gir.Array : Node, AnyType {
    public override string name                    { owned get; set; }
    public bool zero_terminated                    { get; set; }
    public int fixed_size                          { get; set; }
    public bool introspectable                     { get; set; }
    public int length                              { get; set; }
    public string c_type                           { owned get; set; }
    public override Vala.List<AnyType> inner_types { owned get; set; }

    public Array (string name, bool zero_terminated, int fixed_size,
                  bool introspectable, int length, string c_type,
                  Vala.List<AnyType> inner_types) {
        this.name = name;
        this.zero_terminated = zero_terminated;
        this.fixed_size = fixed_size;
        this.introspectable = introspectable;
        this.length = length;
        this.c_type = c_type;
        this.inner_types = inner_types;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_array (this);
    }

    public override void accept_children (GirVisitor visitor) {
        foreach (var anytype in inner_types) {
            anytype.accept (visitor);
        }
    }
}
