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

public class Builders.TypedValueBuilder {

    private Gir.Node node;

    public TypedValueBuilder (Gir.Node node) {
        this.node = node;
    }

    public Vala.DataType build () {
        Gir.AnyType? any_type = node.any_of (typeof (Gir.AnyType));
        if (any_type == null) {
            Report.error (node.source_reference, "array or type expected: " + node.to_string (0));
            return new VoidType (node.source_reference);
        }

        if (any_type is Gir.TypeRef) {
            return new TypeBuilder ((Gir.TypeRef) any_type).build ();
        } else if (any_type is Gir.Array) {
            DataType elem_type = new TypedValueBuilder (any_type).build ();
            return new ArrayType (elem_type, 0, any_type.source_reference);
        }

        return new VoidType (node.source_reference);
    }
}
 