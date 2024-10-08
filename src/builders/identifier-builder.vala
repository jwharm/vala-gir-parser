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

public class Builders.IdentifierBuilder {

    private Gir.Node g_identifier;

    public IdentifierBuilder (Gir.Node identifier) {
        this.g_identifier = identifier;
    }

    public virtual bool skip () {
        return ! g_identifier.get_bool ("introspectable", true);
    }

    /* Get the C prefix of this identifier */
    public string? get_ns_prefix () {
        var ns = g_identifier.parent_node;

        /* Return null if this is not a registered type */
        if (ns == null) {
            return null;
        }

        return ns.get_string ("c:identifier-prefixes")
            ?? ns.get_string ("c:prefix")
            ?? ns.get_string ("name");
    }
    
    public void set_ccode_attrs (Vala.Symbol v_sym) {
        /* get_type method */
        var type_id = g_identifier.get_string ("glib:get-type");
        if (type_id == null) {
            v_sym.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            if (! type_id.has_suffix (")")) {
                type_id += " ()";
            }
            
            v_sym.set_attribute_string ("CCode", "type_id", type_id);
        }

        /* ref_function */
        if (g_identifier.has_attr ("glib:ref-func")) {
            var ref_func = g_identifier.get_string ("glib:ref-func");
            v_sym.set_attribute_string ("CCode", "ref_function", ref_func);
        }

        /* unref_function */
        if (g_identifier.has_attr ("glib:unref-func")) {
            var unref_func = g_identifier.get_string ("glib:unref-func");
            v_sym.set_attribute_string ("CCode", "unref_function", unref_func);
        }

        /* ref_sink_function */
        if (g_identifier.has_attr ("ref-sink-function")) {
            var ref_sink = g_identifier.get_string ("ref-sink-function");
            v_sym.set_attribute_string ("CCode", "ref_sink_function", ref_sink);
        }
    }

    /* Generate C name of an identifier: for example "GtkWindow" */
    public string? generate_cname () {
        var ns_prefix = get_ns_prefix ();
        if (ns_prefix == null) {
            return null;
        }

        return ns_prefix + g_identifier.get_string ("name");
    }

    /* Generate C name of the TypeClass/TypeInterface of a class/interface */
    public string? generate_type_cname () {
        if (g_identifier.tag == "class") {
            return g_identifier.get_string ("name") + "Class";
        } else if (g_identifier.tag == "interface") {
            return g_identifier.get_string ("name") + "Iface";
        } else {
            return null;
        }
    }
}
