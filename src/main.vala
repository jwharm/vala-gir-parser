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

public static int main (string[] args) {
	/* Check if a library and filename was specified */
	if (args.length != 3) {
		printerr ("Usage: gir-parser library_name filename.gir\n");
		return 1;
	}

	/* Check if the gir file exists */
	if (! File.new_for_path (args[2]).query_exists ()) {
		printerr ("File does not exist\n");
		return 1;
	}

	/* Parse the gir file and create vapi AST */
	var context = new CodeContext ();
	var source_file = new SourceFile (context, SourceFileType.NONE, args[2]);
	source_file.from_commandline = true;
	context.add_source_file (source_file);
	CodeContext.push (context);
	new GirParser2 ().parse (context);

	/* Write the library.vapi file */
	var vapi_filename = "%s.vapi".printf (args[1]);
	new CodeWriter (CodeWriterType.VAPIGEN).write_file (context, vapi_filename);
	CodeContext.pop ();

	return 0;
}

