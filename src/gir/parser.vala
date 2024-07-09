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

public class Gir.Parser {
	static construct {
		ensure_initialized ();
	}

	/**
	 * Parse the provided Gir file into a tree of Gir Nodes.
	 *
	 * @param  filename must be a valid filename of an existing file
	 * @return the Repository, or null in case the gir file is invalid
	 */
	public Repository? parse (string filename) {
		var reader = new MarkupReader (filename);
		SourceLocation begin, end;
		
		/* Find the first START_ELEMENT token in the XML file */
		while (true) {
			var token_type = reader.read_token (out begin, out end);
			if (token_type == START_ELEMENT) {
				return parse_element (reader) as Repository;
			} else if (token_type == EOF) {
				critical ("No repository found in %s\n", filename);
				return null;
			}
		}
	}

	/* Parse one XML element (recursively), and return a new Gir Node */
	private Node parse_element (MarkupReader reader) {
		var element = reader.name;
		var children = new Gee.ArrayList<Node> ();
		var attrs = reader.get_attributes ();
		var content = new StringBuilder ();
		SourceLocation begin, end;

		/* Keep parsing XML until an END_ELEMENT or EOF token is reached */
		while (true) {
			var token = reader.read_token (out begin, out end);
			if (token == MarkupTokenType.START_ELEMENT) {
				/* Recursively create a child node and add it to the list */
				Node node = parse_element (reader);
				children.add (node);
			} else if (token == MarkupTokenType.TEXT) {
				content.append (reader.content);
			} else {
				break;
			}
		}
		
		/* Determine the Node subclass */
		Type gtype = Type.from_name (Node.element_to_type_name (element));
		if (gtype == 0) {
			warning ("Unsupported element: %s\n", element);
			/* Fallback to generic Node type */
			gtype = typeof (Node);
		}

		/* Create and return a new Gir Node */
		return Object.new (gtype,
						   attrs: attrs,
						   children: children,
						   content: content.str.strip ()) as Node;
	}

	/**
	 * Make sure that all Node subclasses are registered on startup.
	 */
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
}

