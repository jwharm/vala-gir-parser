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

    private Gir.Node g_ns;

    public NamespaceBuilder (Gir.Node ns) {
        this.g_ns = ns;
    }

    public Vala.Namespace build () {
        /* create the namespace */
        Vala.Namespace v_ns = new Vala.Namespace (g_ns.get_string ("name"), g_ns.source);

        /* attributes */
        v_ns.set_attribute_string ("CCode", "cheader_filename", get_cheader_filename ());
        v_ns.set_attribute_string ("CCode", "gir_namespace", g_ns.get_string ("name"));
        v_ns.set_attribute_string ("CCode", "gir_version", g_ns.get_string ("version"));
        v_ns.set_attribute_string ("CCode", "cprefix", g_ns.get_string ("c:identifier-prefixes"));
        v_ns.set_attribute_string ("CCode", "lower_case_cprefix", g_ns.get_string ("c:symbol-prefixes") + "_");

        /* bitfields */
        foreach (var g_bf in g_ns.all_of ("bitfield")) {
            if (g_bf.get_bool ("introspectable", true)) {
                EnumBuilder builder = new EnumBuilder (g_bf);
                v_ns.add_enum (builder.build_enum ());
            }
        }

        /* callbacks */
        foreach (var g_cb in g_ns.all_of ("callback")) {
            if (g_cb.get_bool ("introspectable", true)) {
                var builder = new MethodBuilder (g_cb);
                v_ns.add_delegate (builder.build_delegate ());
            }
        }

        /* classes */
        foreach (var g_class in g_ns.all_of ("class")) {
            if (g_class.get_bool ("introspectable", true)) {
                ClassBuilder builder = new ClassBuilder (g_class);
                v_ns.add_class (builder.build ());
            }
        }

        /* enumerations (and error domains) */
        foreach (var g_enum in g_ns.all_of ("enumeration")) {
            if (g_enum.get_bool ("introspectable", true)) {
                var builder = new EnumBuilder (g_enum);
                if (g_enum.get_string ("glib:error-domain") != null) {
                    v_ns.add_error_domain (builder.build_error_domain ());
                } else {
                    v_ns.add_enum (builder.build_enum ());
                }
            }
        }

        /* functions */
        foreach (var g_function in g_ns.all_of ("function")) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_ns.add_method (builder.build_function ());
            } 
        }

        /* interfaces */
        foreach (var g_iface in g_ns.all_of ("interface")) {
            if (g_iface.get_bool ("introspectable", true)) {
                InterfaceBuilder builder = new InterfaceBuilder (g_iface);
                v_ns.add_interface (builder.build ());
            }
        }

        /* records */
        foreach (var g_rec in g_ns.all_of ("record")) {
            var builder = new StructBuilder (g_rec);
            if (! builder.skip ()) {
                if (g_rec.has_attr ("glib:get-type")) {
                    var boxed_builder = new BoxedBuilder (g_rec);
                    v_ns.add_class (boxed_builder.build ());
                } else {
                    v_ns.add_struct (builder.build ());
                }
            }
        }

        /* constants */
        foreach (var g_constant in g_ns.all_of ("constant")) {
            var builder = new ConstantBuilder (g_constant);
            v_ns.add_constant (builder.build ());
        }

        return v_ns;
    }

    private string get_cheader_filename () {
        var c_includes = g_ns.parent_node.all_of ("c:include");
        var names = new string[c_includes.size];
        for (int i = 0; i < c_includes.size; i++) {
            names[i] = c_includes[i].get_string ("name");
        }

        return string.joinv (",", names);
    }
}
