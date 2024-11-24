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

public class Builders.ConstantBuilder {

    private Gir.Node g_constant;

    public ConstantBuilder (Gir.Node g_constant) {
        this.g_constant = g_constant;
    }

    public Constant build () {
        /* type */
        var type = new DataTypeBuilder (g_constant.any_of ("type", "array")).build ();

        /* create the const field */
        var v_const = new Constant (g_constant.get_string ("name"), type, null, g_constant.source);
        v_const.access = PUBLIC;

        /* cname */
        v_const.set_attribute_string ("CCode", "cname", g_constant.get_string ("c:type"));

        /* attributes */
        new InfoAttrsBuilder (g_constant).add_info_attrs (v_const);

        return v_const;
    }
}
