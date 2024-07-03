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
	/**
	 * Parse the provided Gir file into a tree of Gir Nodes.
	 */
	public Node? parse (string filename) {
		var reader = new MarkupReader (filename);
		SourceLocation begin;
		SourceLocation end;
		
		while (true) {
			var token_type = reader.read_token (out begin, out end);
			if (token_type == START_ELEMENT) {
				return parse_element (reader);
			} else if (token_type == EOF) {
				critical ("No repository found");
				return null;
			}
		}
	}

	/* Parse one XML element (recursively), and return a new Gir Node */
	private Node parse_element (MarkupReader reader) {
		var element = reader.name;
		var children = new Gee.ArrayList<Node> ();
		var attrs =  to_gee (reader.get_attributes ());
		var content = new StringBuilder ();
		SourceLocation begin;
		SourceLocation end;

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

		/* Create and return a new Gir Node. */
		return Object.new (Type.from_name (element_to_type_name(element)),
						   attrs: attrs,
						   children: children,
						   content: content.str.strip ()) as Node;
	}

	/* Convert "type-name" to "TypeName" */
	private static string element_to_type_name (string element) {
		/* Special cases */
		if (element == "type") {
			return "GirTypeRef";
		}

		if (element == "glib:signal") {
			return "GirSignal";
		}

		var builder = new StringBuilder ("Gir");
		foreach (string part in element.replace (":", "-").split ("-")) {
			string capitalized = part.substring(0, 1).up () + part.substring(1);
			builder.append (capitalized);
		}

		return builder.str;
	}
}

