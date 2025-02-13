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

public class Builders.NamespaceBuilder {

    private Symbol v_parent_sym;
    private Gir.Namespace g_ns;

    public NamespaceBuilder (Symbol v_parent_sym, Gir.Namespace ns) {
        this.v_parent_sym = v_parent_sym;
        this.g_ns = ns;
    }

    public Namespace build () {
        Namespace v_ns = new Namespace (g_ns.name, g_ns.source);
        v_parent_sym.add_namespace (v_ns);

        /* attributes */
        if (g_ns.parent_node is Gir.Repository) {
            v_ns.set_attribute_string ("CCode", "cheader_filename", get_cheader_filename ());
            v_ns.set_attribute_string ("CCode", "gir_namespace", g_ns.name);
            v_ns.set_attribute_string ("CCode", "gir_version", g_ns.version);
            v_ns.set_attribute_string ("CCode", "cprefix", g_ns.c_identifier_prefixes);
            v_ns.set_attribute_string ("CCode", "lower_case_cprefix", g_ns.c_symbol_prefixes + "_");
        }

        /* bitfields */
        foreach (var g_bf in g_ns.bitfields) {
            EnumBuilder builder = new EnumBuilder (v_ns, g_bf);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* callbacks */
        foreach (var g_cb in g_ns.callbacks) {
            var builder = new MethodBuilder (v_ns, g_cb);
            if (! builder.skip ()) {
                builder.build_delegate ();
            }
        }

        /* classes */
        foreach (var g_class in g_ns.classes) {
            ClassBuilder builder = new ClassBuilder (v_ns, g_class);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* enumerations and error domains */
        foreach (var g_enum in g_ns.enumerations) {
            var builder = new EnumBuilder (v_ns, g_enum);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* interfaces */
        foreach (var g_iface in g_ns.interfaces) {
            InterfaceBuilder builder = new InterfaceBuilder (v_ns, g_iface);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* records */
        foreach (var g_rec in g_ns.records) {
            if (g_rec.glib_get_type != null) {
                var builder = new BoxedBuilder (v_ns, g_rec);
                if (! builder.skip ()) {
                    builder.build ();
                }
            } else {
                var builder = new StructBuilder (v_ns, g_rec);
                if (! builder.skip ()) {
                    builder.build ();
                }
            }
        }

        /* nested namespaces */
        //  foreach (var g_child_ns in g_ns.namespaces) {
        //      var builder = new NamespaceBuilder (v_ns, g_child_ns);
        //      builder.build ();
        //  }

        /* aliases */
        foreach (var g_alias in g_ns.aliases) {
            var builder = new AliasBuilder (v_ns, g_alias);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* functions */
        foreach (var g_function in g_ns.functions) {
            var builder = new MethodBuilder (v_ns, g_function);
            if (! builder.skip ()) {
                builder.build_function ();
            } 
        }

        /* constants */
        foreach (var g_constant in g_ns.constants) {
            var builder = new ConstantBuilder (v_ns, g_constant);
            builder.build ();
        }

        return v_ns;
    }

    private string get_cheader_filename () {
        var c_includes = ((Gir.Repository) g_ns.parent_node).c_includes;
        var names = new string[c_includes.size];
        for (int i = 0; i < c_includes.size; i++) {
            names[i] = c_includes[i].name;
        }

        return string.joinv (",", names);
    }
}
