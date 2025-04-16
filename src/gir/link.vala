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
 * Represents a "link" to another Gir Node.
 */
public class Gir.Link<T> {
    /** The literal text value from the Gir XML */
    public string? text { get; set; }

    /** The Gir Node that the link refers to (when resolved) */
    public T? node { get; set; default = null; }

    /** Whether the link has been resolved */
    public bool resolved { get; set; default = false; }

    public Link (string? text) {
        this.text = text;
    }
}
