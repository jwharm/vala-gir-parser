/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
 * 
 * Parts of this file were copied and adapted from Vala 0.56:
 * Copyright (C) 2008  Jürg Billeter
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

using GLib;

/**
 * Represents a position in a source file.
 */
public struct Gir.Xml.SourceLocation {
	public char* pos;
	public int line;
	public int column;

	public SourceLocation (char* _pos, int _line, int _column) {
		pos = _pos;
		line = _line;
		column = _column;
	}

	/**
	 * Returns a string representation of this source location.
	 *
	 * @return human-readable string
	 */
	public string to_string () {
		return ("%d.%d".printf (line, column));
	}
}