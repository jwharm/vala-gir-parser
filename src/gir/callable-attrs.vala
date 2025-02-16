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

public interface Gir.CallableAttrs : Node, InfoAttrs {
    public abstract string name              { owned get; set; }
    public abstract string? c_identifier     { owned get; set; }
    public abstract string? shadowed_by      { owned get; set; }
    public abstract string? shadows          { owned get; set; }
    public abstract bool @throws             { get; set; }
    public abstract string? moved_to         { owned get; set; }
    public abstract string? glib_async_func  { owned get; set; }
    public abstract string? glib_finish_func { owned get; set; }
}
