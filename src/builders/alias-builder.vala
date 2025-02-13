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

public class Builders.AliasBuilder : IdentifierBuilder {

    private Gir.Node g_alias;

    public AliasBuilder (Symbol v_parent_sym, Gir.Node g_alias) {
        base (v_parent_sym, g_alias);
        this.g_alias = g_alias;
    }

    public Symbol build () {
        var type_name = g_alias.any_of ("type")?.get_string ("name");
        var target = lookup (v_parent_sym.scope, type_name);
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

        if (target is Class) {
            var g_class = Gir.Node.create ("class", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    "parent", type_name,
                    "glib:get-type", target.get_attribute_string ("CCode", "type_id"),
                    null);
            return new ClassBuilder (v_parent_sym, g_class).build ();
        }
        
        else if (target is Interface) {
            /* this is not a correct alias, but what can we do otherwise? */
            var g_ifc = Gir.Node.create ("interface", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    null);
            g_ifc.add (Gir.Node.create ("prerequisite", g_alias.source,
                    "name", type_name,
                    null));
            return new InterfaceBuilder (v_parent_sym, g_ifc).build ();
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

            v_parent_sym.add_delegate (v_dlg);
            return v_dlg;
        }

        else { /* target == null || target is Struct */
            var g_rec = Gir.Node.create ("record", g_alias.source,
                    "name", g_alias.get_string ("name"),
                    "glib:get-type", target?.get_attribute_string ("CCode", "type_id"),
                    null);
            var v_struct = (Struct) new StructBuilder (v_parent_sym, g_rec).build ();
            v_struct.base_type = base_type;
            v_struct.set_simple_type (simple_type);
            return v_struct;
        }
    }

    public override bool skip () {
        if (base.skip ()) {
            return true;
        }

        var type_name = g_alias.any_of ("type")?.get_string ("name");
        if (type_name == null) {
            Report.warning (g_alias.source, "Unsupported alias `%s'",
                    g_alias.get_string ("name"));
            return true;
        }

        var target = lookup (v_parent_sym.scope, type_name);
        if (! (target == null || target is Struct || target is Class
                    || target is Interface || target is Delegate)) {
            Report.warning (g_alias.source, "alias for `%s' is not supported",
                    target.get_full_name ());
            return true;
        }

        return false;
   }
}
