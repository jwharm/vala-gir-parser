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

public class Builders.FieldBuilder {

    private Gir.Field field;

    public FieldBuilder (Gir.Field field) {
        this.field = field;
    }

    public Vala.Field build () {
        var f_type = new DataTypeBuilder (field.anytype).build ();
        var vfield = new Field (field.name, f_type, null, field.source_reference, null);
        vfield.access = SymbolAccessibility.PUBLIC;
        return vfield;
    }
}
