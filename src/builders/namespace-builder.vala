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

    private Gir.Namespace ns;
    private Gee.List<Gir.CInclude> c_includes;

    public NamespaceBuilder (Gir.Namespace ns, Gee.List<Gir.CInclude> c_includes) {
        this.ns = ns;
        this.c_includes = c_includes;
    }

    public Vala.Namespace build () {
        /* create the namespace */
        Vala.Namespace vns = new Vala.Namespace (ns.name, ns.source_reference);

        /* attributes */
        vns.set_attribute_string ("CCode", "cheader_filename", get_cheader_filename ());
        vns.set_attribute_string ("CCode", "gir_namespace", ns.name);
        vns.set_attribute_string ("CCode", "gir_version", ns.version);
        vns.set_attribute_string ("CCode", "cprefix", ns.c_identifier_prefixes);
        vns.set_attribute_string ("CCode", "lower_case_cprefix", ns.c_symbol_prefixes + "_");

        /* bitfields */
        foreach (Gir.Bitfield btf in ns.bitfields) {
            if (btf.introspectable) {
                EnumBuilder builder = new EnumBuilder (btf);
                vns.add_enum (builder.build ());
            }
        }

        /* callbacks */
        foreach (Gir.Callback cb in ns.callbacks) {
            if (cb.introspectable) {
                var builder = new DelegateBuilder (cb);
                vns.add_delegate (builder.build_callback ());
            }
        }

        /* classes */
        foreach (Gir.Class cls in ns.classes) {
            if (cls.introspectable) {
                ClassBuilder builder = new ClassBuilder (cls);
                vns.add_class (builder.build ());
            }
        }

        /* enumerations */
        foreach (Gir.Enumeration enm in ns.enumerations) {
            if (enm.introspectable) {
                EnumBuilder builder = new EnumBuilder (enm);
                vns.add_enum (builder.build ());
            }
        }

        /* functions */
        foreach (var f in ns.functions) {
            var builder = new MethodBuilder (f);
            if (! builder.skip ()) {
                vns.add_method (builder.build_function ());
            } 
        }

        /* interfaces */
        foreach (Gir.Interface ifc in ns.interfaces) {
            if (ifc.introspectable) {
                InterfaceBuilder builder = new InterfaceBuilder (ifc);
                vns.add_interface (builder.build ());
            }
        }

        /* records */
        foreach (Gir.Record rec in ns.records) {
            if (rec.introspectable) {
                if (rec.glib_get_type == null) {
                    var builder = new StructBuilder (rec);
                    vns.add_struct (builder.build ());
                } else {
                    var builder = new BoxedBuilder (rec);
                    vns.add_class (builder.build ());
                }
            }
        }

        return vns;
    }

    private string get_cheader_filename () {
        string[] names = new string[c_includes.size];
        for (int i = 0; i < c_includes.size; i++) {
            names[i] = c_includes[i].name;
        }

        return string.joinv (",", names);
    }
}
