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

    private Gir.Namespace g_ns;
    private Gee.List<Gir.CInclude> c_includes;

    public NamespaceBuilder (Gir.Namespace ns, Gee.List<Gir.CInclude> c_includes) {
        this.g_ns = ns;
        this.c_includes = c_includes;
    }

    public Vala.Namespace build () {
        /* create the namespace */
        Vala.Namespace v_ns = new Vala.Namespace (g_ns.name, g_ns.source_reference);

        /* attributes */
        v_ns.set_attribute_string ("CCode", "cheader_filename", get_cheader_filename ());
        v_ns.set_attribute_string ("CCode", "gir_namespace", g_ns.name);
        v_ns.set_attribute_string ("CCode", "gir_version", g_ns.version);
        v_ns.set_attribute_string ("CCode", "cprefix", g_ns.c_identifier_prefixes);
        v_ns.set_attribute_string ("CCode", "lower_case_cprefix", g_ns.c_symbol_prefixes + "_");

        /* bitfields */
        foreach (Gir.Bitfield g_bf in g_ns.bitfields) {
            if (g_bf.introspectable) {
                EnumBuilder builder = new EnumBuilder (g_bf);
                v_ns.add_enum (builder.build_enum ());
            }
        }

        /* callbacks */
        foreach (Gir.Callback g_cb in g_ns.callbacks) {
            if (g_cb.introspectable) {
                var builder = new MethodBuilder (g_cb);
                v_ns.add_delegate (builder.build_delegate ());
            }
        }

        /* classes */
        foreach (Gir.Class g_class in g_ns.classes) {
            if (g_class.introspectable) {
                ClassBuilder builder = new ClassBuilder (g_class);
                v_ns.add_class (builder.build ());
            }
        }

        /* enumerations (and error domains) */
        foreach (Gir.Enumeration g_enum in g_ns.enumerations) {
            if (g_enum.introspectable) {
                var builder = new EnumBuilder (g_enum);
                if (g_enum.glib_error_domain != null) {
                    v_ns.add_error_domain (builder.build_error_domain ());
                } else {
                    v_ns.add_enum (builder.build_enum ());
                }
            }
        }

        /* functions */
        foreach (var g_function in g_ns.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_ns.add_method (builder.build_function ());
            } 
        }

        /* interfaces */
        foreach (Gir.Interface g_iface in g_ns.interfaces) {
            if (g_iface.introspectable) {
                InterfaceBuilder builder = new InterfaceBuilder (g_iface);
                v_ns.add_interface (builder.build ());
            }
        }

        /* records */
        foreach (Gir.Record g_rec in g_ns.records) {
            var builder = new StructBuilder (g_rec);
            if (! builder.skip ()) {
                if (g_rec.glib_get_type == null) {
                    v_ns.add_struct (builder.build ());
                } else {
                    var boxed_builder = new BoxedBuilder (g_rec);
                    v_ns.add_class (boxed_builder.build ());
                }
            }
        }

        /* constants */
        foreach (Gir.Constant g_constant in g_ns.constants) {
            var builder = new ConstantBuilder (g_constant);
            v_ns.add_constant (builder.build ());
        }

        return v_ns;
    }

    private string get_cheader_filename () {
        string[] names = new string[c_includes.size];
        for (int i = 0; i < c_includes.size; i++) {
            names[i] = c_includes[i].name;
        }

        return string.joinv (",", names);
    }
}
