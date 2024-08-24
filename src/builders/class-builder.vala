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

public class Builders.ClassBuilder {

    private Gir.Class cls;

    public ClassBuilder (Gir.Class cls) {
        this.cls = cls;
    }

    public Vala.Class build () {
        /* the class */
        Vala.Class vclass = new Vala.Class (cls.name, cls.source_reference);
        vclass.access = SymbolAccessibility.PUBLIC;

        /* c name */
        vclass.set_attribute_string ("CCode", "cname", cls.c_type);

        /* add methods */
        foreach (var m in cls.methods) {
            var vmethod = new MethodBuilder (m).build ();
            vclass.add_method (vmethod);
        }

        return vclass;
    }
}
