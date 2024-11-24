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

public class Builders.AliasBuilder {

    private Gir.Node g_ns;
    private Namespace v_ns;
    private Gir.Node g_alias;

    public AliasBuilder (Gir.Node g_ns, Namespace v_ns, Gir.Node g_alias) {
        this.g_ns = g_ns;
        this.v_ns = v_ns;
        this.g_alias = g_alias;
    }

    public void build () {
        var type_name = g_alias.any_of ("type")?.get_string ("name");
        if (type_name == null) {
            Report.warning (g_alias.source, "Unsupported alias %s",
                    g_alias.get_string ("name"));
            return;
        }

        var target = lookup (type_name);
        var builder = new DataTypeBuilder (g_alias.any_of ("type"));
        var base_type = builder.build ();
        var simple_type = builder.is_simple_type ();

        /* this is unfortunate because <alias> tag has no type information, thus
         * we have to guess it from the base type */
        
        if ((base_type as PointerType)?.base_type is VoidType) {
            /* gpointer, if it's a struct make it a simpletype */
            simple_type = true;
        }

        if (target is Struct && ((Struct) target).is_simple_type ()) {
            simple_type = true;
        }

        if (target == null || target is Struct) {
            var g_rec = Gir.Node.create ("record", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    "glib:get-type", target?.get_attribute_string ("CCode", "type_id"),
                    null);
            var v_struct = new StructBuilder (g_rec).build ();
            v_struct.base_type = base_type;
            v_struct.set_simple_type (simple_type);
            v_ns.add_struct (v_struct);
        }
        
        else if (target is Class) {
            var g_class = Gir.Node.create ("class", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    "parent", type_name,
                    "glib:get-type", target.get_attribute_string ("CCode", "type_id"),
                    null);
            v_ns.add_class (new ClassBuilder (g_class).build ());
        }
        
        else if (target is Interface) {
            /* this is not a correct alias, but what can we do otherwise? */
            var g_ifc = Gir.Node.create ("interface", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    null);
            g_ifc.add (Gir.Node.create ("prerequisite", g_alias.source,
                    "name", type_name,
                    null));
            v_ns.add_interface (new InterfaceBuilder (g_ifc).build ());
        }
        
        else if (target is Delegate) {
            /* duplicate the aliased delegate */
            var orig = (Delegate) target;

            var v_dlg = new Delegate (g_alias.get_string ("name"),
                                      orig.return_type.copy (),
                                      g_alias.source);
            v_dlg.access = orig.access;

            foreach (var param in orig.get_parameters ()) {
                v_dlg.add_parameter (param.copy ());
            }

            var error_types = new ArrayList<DataType> ();
            orig.get_error_types (error_types, g_alias.source);
            foreach (var error_type in error_types) {
                v_dlg.add_error_type (error_type.copy ());
            }

            foreach (var attribute in orig.attributes) {
                v_dlg.add_attribute (attribute);
            }

            v_ns.add_delegate (v_dlg);
        }
        
        else {
            Report.warning (g_alias.source,
                            "alias `%s' for `%s' is not supported",
                            g_alias.get_string ("name"),
                            target.get_full_name ());
        }
    }

    /* Find a symbol in the Vala AST */
    private Symbol? lookup (string name) {
        for (Scope s = v_ns.scope; s != null; s = s.parent_scope) {
            var sym = s.lookup (name);
            if (sym != null) {
                return sym;
            }
        }

        return null;
    }
}