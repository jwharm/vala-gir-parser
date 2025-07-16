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

/**
 * The `Named` interface is implemented by all Gir Nodes that have a
 * `string name` property. Note that in some Node classes, specifically
 * TypeRef, Array, Parameter, Union and Namespace, the name is optional (i.e.
 * a `string? name` property) and for that reason do not implement `Named`.
 */
public interface Gir.Named : Node {
    public abstract string name { owned get; set; }
}
