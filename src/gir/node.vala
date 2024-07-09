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
	public weak Node? parent_node { get; private set; default = null; }
	public string? content { get; internal set construct; }
	public Vala.Map<string, string> attrs { get; construct; }
	public Gee.List<Node> children { get; construct; }

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

		foreach (var key in attrs.get_keys ()) {
			builder.append (@" $key=\"$(attrs.get (key))\"");
		}

		foreach (var child in children) {
			builder.append ("\n")
				   .append (child.to_string (indent + 2));
		}

		return builder.str;
	}

	/**
	 * Get a filtered view of all child nodes with the specified gtype.
	 */
	internal Gee.List<T> all_of<T> (Type gtype) {
		return new FilteredNodeList<T> (children, gtype);
	}

	/**
	 * Get the child node with the specified gtype, or ``null`` if not found.
	 */
	internal T? any_of<T> (Type gtype) {
		return (T?) children.first_match ((e) => e.get_type ().is_a (gtype));
	}

	/**
	 * Add a node to the list of child nodes, removing any existing nodes with
	 * the same gtype.
	 */	
	internal void remove_and_set (Node node) {
		children.remove_all_iterator (
			children.filter (e => e.get_type () == node.get_type ())
		);
		children.add (node);
	}

	/**
	 * Get the boolean value of this key ("1" is true, "0" is false)
	 */
	internal bool attr_get_bool (string key, bool if_not_set = false) {
		if (key in attrs) {
			return "1" == attrs[key];
		} else {
			return if_not_set;
		}
	}

	/**
	 * Set the boolean value of this key
	 */	
	internal void attr_set_bool (string key, bool val) {
		attrs[key] = (val ? "1" : "0");
	}

	/**
	 * Get the int value of this key.
	 */
	internal int attr_get_int (string key, int if_not_set = -1) {
		if (key in attrs) {
			return int.parse (attrs[key]);
		} else {
			return if_not_set;
		}
	}
	
	/**
	 * Set the int value of this key
	 */
	internal void attr_set_int (string key, int val) {
		attrs[key] = val.to_string();
	}
}

