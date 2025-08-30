/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
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
 * Base class for all Gir Nodes. The parent node of the root node is `null`.
 */
public abstract class Gir.Node : Object {
    public weak Node? parent_node    { get; set; default = null; }
    public Gir.Xml.Reference? source { get; set; }

    protected Node (Gir.Xml.Reference? source) {
        this.source = source;
    }

    public virtual void accept (Visitor visitor) {
    }

    public virtual void accept_children (Visitor visitor) {
    }

    /**
     * Convert "GirTypeName" to "element-name" format.
     */
    public string tag_name () {
        Type type = get_type ();
        if (type == typeof (TypeRef)) {
            return "type";
        } else if (type == typeof (AnonymousRecord)) {
            return "record";
        } else if (type == typeof (CInclude)) {
            return "c:include";
        } else if (type == typeof (DocFormat)) {
            return "doc:format";
        }

        string name = type.name ();
        var sb = new StringBuilder ();
        for (int i = 3; i < name.length; i++) {
            if (i > 3 && name[i].isupper ()) {
                sb.append_c ('-');
            }
            sb.append_c (name[i].tolower ());
        }

        return sb.str;
    }

    /**
     * Return true when this node contains an `<attribute>` element with the
     * requested name, otherwise return false
     */
    public bool has_attribute (string name) {
        foreach (Attribute attr in get_attributes ()) {
            if (attr.name == name) {
                return true;
            }
        }

        return false;
    }

    /**
     * Return the value of the `<attribute>` element with the requested name.
     * Return `null` when the value is equal to `()`, or the attribute value is
     * `null`, or the requested attribute is not found.
     */
    public string? get_attribute (string name) {
        foreach (Attribute attr in get_attributes ()) {
            if (attr.name == name) {
                return attr.value == "()" ? null : attr.value;
            }
        }

        return null;
    }

    /* Get all `<attribute>` elements of this Gir node. When there are none, an
     * empty list is returned. */
    private Gee.List<Attribute> get_attributes () {
        if (this is InfoElements) {
            return ((InfoElements) this).attributes;
        } else if (this is Namespace) {
            return ((Namespace) this).attributes;
        } else if (this is Parameter) {
            return ((Parameter) this).attributes;
        } else if (this is ReturnValue) {
            return ((ReturnValue) this).attributes;
        } else {
            return new Gee.ArrayList<Attribute> ();
        }
    }
}
