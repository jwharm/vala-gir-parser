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

public class Builders.InterfaceBuilder : IdentifierBuilder {

    private Gir.Node g_iface;

    public InterfaceBuilder (Gir.Node g_iface) {
        base (g_iface);
        this.g_iface = g_iface;
    }

    public Interface build () {
        /* the interface */
        Interface v_iface = new Interface (g_iface.get_string ("name"), g_iface.source);
        v_iface.access = PUBLIC;

        /* prerequisite interfaces */
        foreach (var g_prereq in g_iface.all_of ("prerequisite")) {
            var prereq_type = DataTypeBuilder.from_name (g_prereq.get_string ("name"), g_prereq.source);
            v_iface.add_prerequisite (prereq_type);
        }

        /* when no prerequisites were specified, GLib.Object is the default */
        if (! g_iface.has_any ("prerequisite")) {
            v_iface.add_prerequisite (DataTypeBuilder.from_name ("GLib.Object"));
        }

        /* cname */
        var c_type = g_iface.get_string ("c:type");
        if (c_type != generate_cname ()) {
            v_iface.set_attribute_string ("CCode", "cname", c_type);
        }

        /* attributes */
        new InfoAttrsBuilder (g_iface).add_info_attrs (v_iface);

        /* type_cname */
        var type_struct = g_iface.get_string ("glib:type-struct");
        if (type_struct != generate_type_cname ()) {
            var type_cname = get_ns_prefix () + type_struct;
            v_iface.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* CCode attributes */
        set_ccode_attrs (v_iface);

        /* add functions */
        foreach (var g_function in g_iface.all_of ("function")) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_iface.all_of ("method")) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_method ());
            } 
        }

        /* add virtual methods */
        foreach (var g_vm in g_iface.all_of ("virtual-method")) {
            var builder = new MethodBuilder (g_vm);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_virtual_method ());
            } 
        }

        /* add fields */
        foreach (var g_field in g_iface.all_of ("field")) {
            var vfield = new FieldBuilder (g_field).build ();
            v_iface.add_field (vfield);
        }

        /* add properties */
        foreach (var g_prop in g_iface.all_of ("property")) {
            var builder = new PropertyBuilder (g_prop);
            if (! builder.skip ()) {
                v_iface.add_property (builder.build ());
            }
        }

        /* add signals */
        foreach (var g_signal in g_iface.all_of ("glib:signal")) {
            var builder = new MethodBuilder (g_signal);
            v_iface.add_signal (builder.build_signal ());
        }

        return v_iface;
    }
}
