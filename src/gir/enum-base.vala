/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
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

public interface Gir.EnumBase : Node, InfoAttrs, InfoElements, Identifier {
    public abstract string name                               { owned get; set; }
    public abstract string c_type                             { owned get; set; }
    public abstract string? glib_type_name                    { owned get; set; }
    public abstract string? glib_get_type                     { owned get; set; }
    public abstract Gee.List<Member> members                  { owned get; set; }
    public abstract Gee.List<Function> functions              { owned get; set; }
    public abstract Gee.List<FunctionInline> function_inlines { owned get; set; }
}
