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

/**
 * The Gir.Node class represents an element from a GIR XML file. It contains:
 *- A parent Node
 *- A `Map<string, Expression>` of attributes (`name`, `c:type`, etc)
 *- A `List<Node>` of child nodes
 *- The text contents of the XML element (for example in a `Gir.Doc` node)
 *- A Vala `SourceReference` with the location in the GIR XML file (for error
 *  reporting)
 *
 * The attribute values are mostly StringLiterals, but they also be another
 * type of expression when set from a metadata rule, like default values. They
 * can be read from the `attrs` field directly, but it is safer to use the
 * various `get_...()` and `set_...()` methods.
 *
 * There are also utility functions to read and update attributes and child
 * nodes, to quickly create a new node with attributes, or transform a GIR tree
 * to string or XML format.
 */
public class Gir.Node {
    public weak Node? parent_node = null;
    public string tag;
    public string? content;
    public Map<string, Expression> attrs;
    public Vala.List<Node> children;
    public SourceReference? source;

    public Node (string tag,
                 string? content,
                 Map<string, string> attrs,
                 Vala.List<Node> children,
                 SourceReference? source) {
        this.tag = tag;
        this.content = content;
        this.attrs = new HashMap<string, Expression> (str_hash, str_equal);
        this.set_children (children);
        this.source = source;

        foreach (var key in attrs.get_keys ()) {
            this.attrs[key] = new StringLiteral (attrs[key]);
        }
    }

    /**
     * Create a new Gir Node, passing attribute keys and values as arguments.
     * The varargs list must be `null` terminated.
     */
    public static Gir.Node create (string tag, SourceReference? source, ...) {
        /* fill attributes map */
        var attrs = new HashMap<string, string> (str_hash, str_equal);
        var l = va_list();
        while (true) {
            string? key = l.arg();
            if (key == null) {
                break; /* end of the list */
            }
            attrs[key] = l.arg();
        }

        /* create empty child nodes list */
        var children = new ArrayList<Node> ();

        /* create and return node */
        return new Gir.Node (tag, null, attrs, children, source);
    }

    /**
     * Add the new child node, and set its parent_node to this node.
     */
    public void add (Node node) {
        node.parent_node = this;
        children.add (node);
    }

    /**
     * Remove all child nodes with one of the specified types.
     */
    public void remove (...) {
        var l = va_list();
        while (true) {
            string? tag = l.arg ();
            if (tag == null) {
                break;
            }

            for (int i = 0; i < children.size; i++) {
                if (children[i].tag == tag) {
                    children.remove_at (i);
                }
            }
        }
    }

    public void set_children(Vala.List<Node> children) {
        this.children = children;
        foreach (var child in children) {
            child.parent_node = this;
        }
    }

    /**
     * Return true if this node has a child with the one of the specified types.
     */
    public bool has_any (...) {
        var l = va_list();
        while (true) {
            string? tag = l.arg ();
            if (tag == null) {
                return false;
            }

            foreach (var child in children) {
                if (child.tag == tag) {
                    return true;
                }
            }
        }
    }

    /**
     * Get a filtered view of all child nodes with the specified type.
     */
    public Vala.List<Node> all_of (string tag) {
        return new FilteredNodeList (children, tag);
    }

    /**
     * Get the child node with one of the specified types, or `null` if not
     * found.
     */
    public Node? any_of (...) {
        var l = va_list();
        while (true) {
            string? tag = l.arg ();
            if (tag == null) {
                return null;
            }

            foreach (var child in children) {
                if (child.tag == tag) {
                    return child;
                }
            }
        }
    }

    /**
     * Return true if the attribute map contains this key.
     */
     public bool has_attr (string key) {
        return key in attrs;
    }

    /**
     * Get the Vala expression value of this key.
     */
     public Expression? get_expression (string key) {
        return attrs[key];
    }

    /**
     * Set the Vala expression value of this key.
     */
     public void set_expression (string key, Expression? expression) {
        if (expression == null) {
            attrs.remove (key);
        } else {
            attrs[key] = expression;
        }
    }

    /**
     * Get the string value of this key.
     */
    public string? get_string (string key) {
        return (attrs[key] as StringLiteral)?.value;
    }

    /**
     * Set the string value of this key.
     */
    public void set_string (string key, string? val) {
        if (val == null) {
            attrs.remove (key);
        } else {
            set_expression (key, new StringLiteral (val));
        }
    }

    /**
     * Get the boolean value of this key ("1" is true, "0" is false).
     */
    public bool get_bool (string key, bool if_not_set = false) {
        string? value = get_string (key);
        if (value != null) {
            return "1" == value;
        } else {
            return if_not_set;
        }
    }

    /**
     * Set the boolean value of this key.
     */ 
    public void set_bool (string key, bool val) {
        set_string (key, val ? "1" : "0");
    }

    /**
     * Get the int value of this key.
     */
    public int get_int (string key, int if_not_set = -1) {
        string? value = get_string (key);
        if (value != null) {
            return int.parse (value);
        } else {
            return if_not_set;
        }
    }

    /**
     * Set the int value of this key.
     */
    public void set_int (string key, int val) {
        set_string (key, val.to_string());
    }

    /**
     * Return a string representation of this node and its children.
     */
    public string to_string (int indent = 0) {
        StringBuilder builder = new StringBuilder ();
        builder.append (string.nfill (indent, ' '))
               .append (tag);

        foreach (var key in attrs.get_keys ()) {
            string value = get_string (key) ?? "";
            builder.append (@" $key=\"$value\"");
        }

        foreach (var child in children) {
            builder.append ("\n")
                   .append (child.to_string (indent + 2));
        }

        return builder.str;
    }

    /**
     * Return an xml representation of this node and its children.
     */
    public string to_xml (int indent = 0) {
        StringBuilder builder = new StringBuilder ();

        /* opening tag */
        builder.append (string.nfill (indent, ' '))
               .append ("<")
               .append (tag);

        /* attributes */
        if (attrs.size <= 2) {
            foreach (var key in attrs.get_keys ()) {
                string value = get_string (key) ?? "";
                builder.append (@" $key=\"$value\"");
            }
        } else {
            int attr_indent = indent + 1 + tag.length;
            int i = 0;
            foreach (var key in attrs.get_keys ()) {
                if (i++ > 0) {
                    builder.append("\n")
                           .append (string.nfill (attr_indent, ' '));
                }
                
                string value = get_string (key) ?? "";
                builder.append (@" $key=\"$value\"");
            }
        }

        /* empty element */
        if (children.is_empty && content == "") {
            builder.append ("/>");
            return builder.str;
        }

        builder.append (">");

        /* child elements */
        foreach (var child in children) {
            builder.append ("\n")
                   .append (child.to_xml (indent + 2));
        }

        /* text content */
        if (content != null && content != "") {
            string escaped = content.replace ("&", "&amp;")
                                    .replace ("\"", "&quot;")
                                    .replace ("<", "&lt;")
                                    .replace (">", "&gt;")
                                    .replace ("%", "&percnt;");
            builder.append (escaped);
        } else {
            builder.append ("\n")
                   .append (string.nfill (indent, ' '));
        }

        /* closing tag */
        builder.append ("</")
               .append (tag)
               .append (">");
        
        return builder.str;
    }
}
