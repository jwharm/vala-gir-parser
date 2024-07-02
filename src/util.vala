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
using Gee;

/* Convert a Vala.Map (returned by Vala.MarkupReader) into a regular Gee.Map */
internal static Gee.Map<string, string> to_gee (Vala.Map<string, string> map) {
	var gee_map = new Gee.HashMap<string, string> ();
	var iter = map.map_iterator ();
	while (iter.next ()) {
		gee_map[iter.get_key ()] = iter.get_value ();
	}
	return gee_map;
}

