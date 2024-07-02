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

public static int main (string[] args) {
	/* Check if a filename was specified */
	if (args.length != 2) {
		print ("Usage: gir-parser filename.gir\n");
		return 1;
	}

	/* Check if the file exists */
	if (! File.new_for_path (args[1]).query_exists ()) {
		print ("File does not exist\n");
		return 1;
	}

	var parser = new Gir.Parser();
	var repository = parser.parse (args[1]) as Gir.Repository;

	if (repository == null) {
		print ("Invalid gir file\n");
		return 1;
	}

	/* Print some fun facts */
	print (@"Parsed repository '$(repository.namespace.name)'\n");

	var method = repository.namespace.classes[0].methods[0].to_string ();
	print (@"The first method of first class is:\n$method\n");

	return 0;
}

