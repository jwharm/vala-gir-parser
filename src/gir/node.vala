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
        } else if (type == typeof (Boxed)) {
            return "glib:boxed";
        } else if (type == typeof (Signal)) {
            return "glib:signal";
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
}
