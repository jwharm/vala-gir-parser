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

using Gee;

/**
 * Base class for all Gir Nodes. A Gir Node has attributes, text content, child
 * nodes, and a parent node. The parent node of the root node is ``null``.
 */
public class Gir.Node : Object {
	public Node? parent_node { get; private set; default = null; }
	public string? content { get; internal set; }
	public Gee.Map<string, string> attrs { get; internal set; }
	public Gee.List<Node> children { get; internal set; }

	construct {
		if (children != null) {
			foreach (Node n in children) {
				n.parent_node = this;
			}
		}
	}

	/**
	 * Return a tree representation of this node and its children.
	 */
	public string to_string (int indent = 0) {
		StringBuilder builder = new StringBuilder ();
		builder.append (string.nfill (indent, ' '))
			   .append (get_type ().name ().substring ("Gir".length));

		foreach (var entry in attrs) {
			builder.append (@" $(entry.key)=\"$(entry.value)\"");
		}

		foreach (var child in children) {
			builder.append ("\n")
				   .append (child.to_string (indent + 2));
		}

		return builder.str;
	}

	/**
	 * Iterate through the child nodes of the requested gtype.
	 */
	internal Gee.List<Node> all_of (Type gtype) {
		var iter = children.filter ((e) => e.get_type ().is_a (gtype));
 		var list = new Gee.ArrayList<Node> ();
		list.add_all_iterator (iter);
		return list;
	}

	/**
	 * Get a child node with the requested gtype, or ``null`` if not found.
	 */
	internal Node? any_of (Type gtype) {
		return children.first_match ((e) => e.get_type ().is_a (gtype));
	}

	/**
	 * Get the boolean value of this key ("1" is true, "0" is false)
	 */
	internal bool attr_bool (string key, bool if_not_set = false) {
		if (attrs.has_key (key)) {
			return "1" == attrs[key];
		} else {
			return if_not_set;
		}
	}

	/**
	 * Get the int value of this key.
	 */
	internal int attr_int (string key, int if_not_set = -1) {
		if (attrs.has_key (key)) {
			return int.parse (attrs[key]);
		} else {
			return if_not_set;
		}
	}
}

