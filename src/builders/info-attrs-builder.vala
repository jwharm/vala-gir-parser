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

public interface Builders.InfoAttrsBuilder {

    public abstract Gir.InfoAttrs info_attrs ();

    public void add_version_attrs (Vala.Symbol v_sym) {
        var g_info_attrs = info_attrs ();

        /* version */
        v_sym.version.since = g_info_attrs.version;

        /* deprecated and deprecated_since */
        if (g_info_attrs.deprecated) {
            /* omit deprecation attributes when the parent already has them */
            unowned var parent = g_info_attrs.parent_node as Gir.InfoAttrs;
            if (parent != null && parent.deprecated) {
                return;
            }

            v_sym.version.deprecated = g_info_attrs.deprecated;
            v_sym.version.deprecated_since = g_info_attrs.deprecated_version;
        }
    }
}