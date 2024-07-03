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
		printerr ("Usage: gir-parser filename.gir\n");
		return 1;
	}

	/* Check if the file exists */
	if (! File.new_for_path (args[1]).query_exists ()) {
		printerr ("File does not exist\n");
		return 1;
	}

	ensure_initialized ();

	var parser = new Gir.Parser ();
	var repository = parser.parse (args[1]);

	if (repository == null) {
		printerr ("Invalid gir file\n");
		return 1;
	}

	/* Print some fun facts */
	print (@"Parsed repository '$(repository.namespace.name)'\n");

	var method = repository.namespace.classes[0].methods[0].to_string ();
	print (@"The first method of first class is:\n$method\n");

	return 0;
}

private static void ensure_initialized () {
	typeof (Gir.Alias).ensure ();
	typeof (Gir.AnyType).ensure ();
	typeof (Gir.Array).ensure ();
	typeof (Gir.Attribute).ensure ();
	typeof (Gir.Bitfield).ensure ();
	typeof (Gir.Boxed).ensure ();
	typeof (Gir.CallableAttrs).ensure ();
	typeof (Gir.Callback).ensure ();
	typeof (Gir.CInclude).ensure ();
	typeof (Gir.Class).ensure ();
	typeof (Gir.Constant).ensure ();
	typeof (Gir.Constructor).ensure ();
	typeof (Gir.DocDeprecated).ensure ();
	typeof (Gir.Docsection).ensure ();
	typeof (Gir.DocStability).ensure ();
	typeof (Gir.Doc).ensure ();
	typeof (Gir.DocVersion).ensure ();
	typeof (Gir.Enumeration).ensure ();
	typeof (Gir.Field).ensure ();
	typeof (Gir.FunctionInline).ensure ();
	typeof (Gir.FunctionMacro).ensure ();
	typeof (Gir.Function).ensure ();
	typeof (Gir.Implements).ensure ();
	typeof (Gir.Include).ensure ();
	typeof (Gir.InfoAttrs).ensure ();
	typeof (Gir.InfoElements).ensure ();
	typeof (Gir.InstanceParameter).ensure ();
	typeof (Gir.Interface).ensure ();
	typeof (Gir.Member).ensure ();
	typeof (Gir.MethodInline).ensure ();
	typeof (Gir.Method).ensure ();
	typeof (Gir.Namespace).ensure ();
	typeof (Gir.Node).ensure ();
	typeof (Gir.Package).ensure ();
	typeof (Gir.Parameters).ensure ();
	typeof (Gir.Parameter).ensure ();
	typeof (Gir.Prerequisite).ensure ();
	typeof (Gir.Property).ensure ();
	typeof (Gir.Record).ensure ();
	typeof (Gir.Repository).ensure ();
	typeof (Gir.ReturnValue).ensure ();
	typeof (Gir.Signal).ensure ();
	typeof (Gir.SourcePosition).ensure ();
	typeof (Gir.TypeRef).ensure ();
	typeof (Gir.Union).ensure ();
	typeof (Gir.Varargs).ensure ();
	typeof (Gir.VirtualMethod).ensure ();
}

