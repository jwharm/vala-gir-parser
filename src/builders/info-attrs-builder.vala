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

public class Builders.InfoAttrsBuilder {

    private Gir.Node g_info_attrs;

    public InfoAttrsBuilder (Gir.Node g_info_attrs) {
        this.g_info_attrs = g_info_attrs;
    }

    public void add_info_attrs (Vala.Symbol v_sym) {
        /* version */
        v_sym.version.since = g_info_attrs.get_string ("version");

        /* deprecated and deprecated_since */
        if (g_info_attrs.get_bool ("deprecated", false)) {
            /* omit deprecation attributes when the parent already has them */
            if (g_info_attrs.parent_node.get_bool ("deprecated", false)) {
                return;
            }

            v_sym.version.deprecated = true;
            v_sym.version.deprecated_since = g_info_attrs.get_string ("deprecated-version");
        }

        if ("hides" in g_info_attrs.attrs) {
            v_sym.hides = g_info_attrs.get_bool ("hides");
        }

        if ("printf-format" in g_info_attrs.attrs) {
            v_sym.set_attribute ("PrintfFormat", g_info_attrs.get_bool ("printf-format"));
        }
    }
}
