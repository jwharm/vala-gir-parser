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

/**
 * Base class for all Gir Nodes. A Gir Node has attributes, text content, child
 * nodes, and a parent node. The parent node of the root node is ``null``.
 */
public class Gir.Node : Object {
    public weak Node? parent_node         { get; private set; default = null; }
    public string? content                { get; internal set construct; }
    public Vala.Map<string, string> attrs { get; construct; }
    public Vala.List<Node> children       { get; construct; }
    public Vala.SourceReference? source   { get; construct; }

    construct {
        foreach (Node n in children) {
            n.parent_node = this;
        }
    }

    /**
     * Create a new Gir Node, passing attribute keys and values as arguments.
     * The varargs list must be `null` terminated.
     */
    public static T create<T> (Vala.SourceReference? source, ...) {
        assert (typeof (T).is_a (typeof (Gir.Node)));

        /* fill attributes map */
        var attrs = new Vala.HashMap<string, string> (str_hash, str_equal);
        var l = va_list();
        while (true) {
            string? key = l.arg();
            if (key == null) {
                break; /* end of the list */
            }
            attrs[key] = l.arg();
        }

        /* create and return node */
        return (T) Object.new (typeof (T),
                               children: new Vala.ArrayList<Node> (),
                               content: null,
                               attrs: attrs,
                               source: source);
    }

    /**
     * Add the new child node, and set its parent_node to this node.
     */
    public void add (Node node) {
        node.parent_node = this;
        children.add (node);
    }

    /**
     * Remove all child nodes with the specified type.
     */
    public void remove<T> () {
        var type = typeof (T);
        for (int i = 0; i < children.size; i++) {
            if (children[i].get_type ().is_a (type)) {
                children.remove_at (i);
            }
        }
    }

    /**
     * Get a filtered view of all child nodes with the specified type.
     */
    public Vala.List<T> all_of<T> () {
        return new FilteredNodeList<T> (children);
    }

    /**
     * Get the first child node with the specified type, or `null` if not found.
     */
    public T? any_of<T> () {
        var type = typeof (T);
        foreach (var child in children) {
            if (child.get_type ().is_a (type)) {
                return child;
            }
        }

        return null;
    }

    /**
     * Replace the first node with the new node's type with the new node. If
     * no existing node with the same type is found, add the new node.
     */ 
    public void remove_and_set (Node node) {
        var type = node.get_type ();
        for (int i = 0; i < children.size; i++) {
            if (children[i].get_type () == type) {
                children[i] = node;
                return;
            }
        }
        add (node);
    }

    /**
     * Get the boolean value of this key ("1" is true, "0" is false)
     */
    public bool attr_get_bool (string key, bool if_not_set = false) {
        return (key in attrs) ? ("1" == attrs[key]) : if_not_set;
    }

    /**
     * Set the boolean value of this key
     */ 
    public void attr_set_bool (string key, bool val) {
        attrs[key] = (val ? "1" : "0");
    }

    /**
     * Get the int value of this key.
     */
    public int attr_get_int (string key, int if_not_set = -1) {
        return (key in attrs) ? (int.parse (attrs[key])) : if_not_set;
    }
    
    /**
     * Set the int value of this key
     */
    public void attr_set_int (string key, int val) {
        attrs[key] = val.to_string();
    }

    /**
     * Return a string representation of this node and its children.
     */
    public string to_string () {
        return to_string_indented (0);
    }

    /**
     * Visits this Gir node with the specified GirVisitor.
     *
     * @param visitor the visitor to be called while traversing
     */
    public virtual void accept (GirVisitor visitor) {
    }

    /**
     * Visits all children of this Gir node with the specified GirVisitor.
     *
     * @param visitor the visitor to be called while traversing
     */
     public virtual void accept_children (GirVisitor visitor) {
        foreach (var child in children) {
            child.accept (visitor);
        }
    }

    private string to_string_indented (int indent) {
        StringBuilder builder = new StringBuilder ();
        builder.append (string.nfill (indent, ' '))
               .append (get_type ().name ().substring ("Gir".length));

        foreach (var key in attrs.get_keys ()) {
            builder.append (@" $key=\"$(attrs.get (key))\"");
        }

        foreach (var child in children) {
            builder.append ("\n")
                   .append (child.to_string_indented (indent + 2));
        }

        return builder.str;
    }
    
    /**
     * Return an xml representation of this node and its children.
     */
    public string to_xml () {
        return to_xml_indented (0);
    }

    private string to_xml_indented (int indent) {
        StringBuilder builder = new StringBuilder ();
        
        /* opening tag */
        string element_name = type_to_element_name (get_type ());
        builder.append (string.nfill (indent, ' '))
               .append ("<")
               .append (element_name);

        /* attributes */
        if (attrs.size <= 2) {
            foreach (var key in attrs.get_keys ()) {
                builder.append (@" $key=\"$(attrs.get (key))\"");
            }
        } else {
            int attr_indent = indent + 1 + element_name.length;
            int i = 0;
            foreach (var key in attrs.get_keys ()) {
                if (i++ > 0) {
                    builder.append("\n")
                           .append (string.nfill (attr_indent, ' '));
                }
                
                builder.append (@" $key=\"$(attrs.get (key))\"");
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
                   .append (child.to_xml_indented (indent + 2));
        }
        
        /* text content */
        if (content != "") {
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
               .append (element_name)
               .append (">");
        
        return builder.str;
    }
    
    /**
     * Convert "type-name" or "glib:type-name" to "GirTypeName". "type" is a
     * special case (GirTypeRef), all others are converted from kebab case to
     * camel case.
     */
    public static string element_to_type_name (string element) {
        if (element == "type") {
            return "GirTypeRef";
        }

        var builder = new StringBuilder ("Gir");
        foreach (string part in element.replace("glib:", "")
                                       .replace (":", "-")
                                       .split ("-")) {
            builder.append (part.substring (0, 1).up () + part.substring (1));
        }

        return builder.str;
    }
    
    /**
     * Convert "GirTypeName" back to "type-name" format (reverse of the above 
     * `element_to_type_name` function).
     */
    public static string type_to_element_name (Type type) {
        if (type == typeof (TypeRef)) {
            return "type";
        } else if (type == typeof (CInclude)) {
            return "c:include";
        } else if (type == typeof (Boxed)) {
            return "glib:boxed";
        } else if (type == typeof (Signal)) {
            return "glib:signal";
        }
        
        string name = type.name ();
        var builder = new StringBuilder ();
        for (int i = 3; i < name.length; i++) {
            if (i > 3 && name[i].isupper ()) {
                builder.append_c ('-');
            }
            builder.append_c (name[i].tolower ());
        }
        
        return builder.str;
    }
}
