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

    private Gir.Interface g_iface;

    public InterfaceBuilder (Gir.Interface g_iface) {
        this.g_iface = g_iface;
    }

    public Vala.Interface build () {
        /* the interface */
        Vala.Interface v_iface = new Vala.Interface (g_iface.name, g_iface.source);
        v_iface.access = PUBLIC;

        /* prerequisite interfaces */
        foreach (var g_imp in g_iface.prerequisites) {
            var imp_type = DataTypeBuilder.from_name (g_imp.name, g_imp.source);
            v_iface.add_prerequisite (imp_type);
        }

        /* when no prerequisites were specified, GLib.Object is the default */
        if (g_iface.prerequisites.is_empty) {
            v_iface.add_prerequisite (DataTypeBuilder.from_name ("GLib.Object"));
        }

        /* c_name */
        if (g_iface.c_type != generate_cname (g_iface)) {
            v_iface.set_attribute_string ("CCode", "cname", g_iface.c_type);
        }

        /* version */
        new InfoAttrsBuilder (g_iface).add_version_attrs (v_iface);

        /* type_cname */
        if (g_iface.glib_type_struct != generate_type_cname (g_iface)) {
            var type_cname = get_ns_prefix (g_iface) + g_iface.glib_type_struct;
            v_iface.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* get_type method */
        var type_id = g_iface.glib_get_type;
        if (type_id == null) {
            v_iface.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            v_iface.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add functions */
        foreach (var g_function in g_iface.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_iface.methods) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_method ());
            } 
        }

        /* add virtual methods */
        foreach (var g_vm in g_iface.virtual_methods) {
            var builder = new MethodBuilder (g_vm);
            if (! builder.skip ()) {
                v_iface.add_method (builder.build_virtual_method ());
            } 
        }

        /* add fields */
        foreach (var g_field in g_iface.fields) {
            var vfield = new FieldBuilder (g_field).build ();
            v_iface.add_field (vfield);
        }

        /* add properties */
        foreach (var g_prop in g_iface.properties) {
            var builder = new PropertyBuilder (g_prop);
            v_iface.add_property (builder.build ());
        }

        /* add signals */
        foreach (var g_signal in g_iface.signals) {
            var builder = new MethodBuilder (g_signal);
            v_iface.add_signal (builder.build_signal ());
        }

        return v_iface;
    }
}
