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

public class Builders.ClassBuilder : IdentifierBuilder {

    private Gir.Node g_class;

    public ClassBuilder (Symbol v_parent_sym, Gir.Node g_class) {
        base (v_parent_sym, g_class);
        this.g_class = g_class;
    }

    public Symbol build () {
        /* the class */
        Class v_class = new Class (g_class.get_string ("name"), g_class.source);
        v_class.access = PUBLIC;
        v_class.is_abstract = g_class.get_bool ("abstract");
        v_class.is_sealed = g_class.get_bool ("final");
        v_parent_sym.add_class (v_class);

        /* parent class */
        if (g_class.has_attr ("parent")) {
            var base_type = DataTypeBuilder.from_name (g_class.get_string ("parent"), g_class.source);
            v_class.add_base_type (base_type);
        }

        /* implemented interfaces */
        foreach (var g_imp in g_class.all_of ("implements")) {
            var imp_type = DataTypeBuilder.from_name (g_imp.get_string ("name"), g_imp.source);
            v_class.add_base_type (imp_type);
        }

        /* compact */
        if (g_class.has_attr ("vala:compact")) {
            v_class.set_attribute ("Compact", g_class.get_bool ("vala:compact"));
        }

        /* cname */
        var c_type = g_class.get_string ("c:type");
        if (c_type != generate_cname ()) {
            v_class.set_attribute_string ("CCode", "cname", c_type);
        }

        /* attributes */
        new InfoAttrsBuilder (g_class).add_info_attrs (v_class);

        /* type_cname */
        var type_struct = g_class.get_string ("glib:type-struct");
        if (type_struct != null &&
                type_struct != generate_type_cname ()) {
            var type_cname = get_ns_prefix () + type_struct;
            v_class.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* CCode attributes */
        set_ccode_attrs (v_class);

        /* add constructors */
        if (! g_class.get_bool ("abstract")) {
            foreach (var g_ctor in g_class.all_of ("constructor")) {
                var builder = new MethodBuilder (v_class, g_ctor);
                if (! builder.skip ()) {
                    builder.build_constructor ();
                }
            }
        }

        /* add functions */
        foreach (var g_function in g_class.all_of ("function")) {
            var builder = new MethodBuilder (v_class, g_function);
            if (! builder.skip ()) {
                builder.build_function ();
            }
        }

        /* add methods */
        foreach (var g_method in g_class.all_of ("method")) {
            var builder = new MethodBuilder (v_class, g_method);
            if (! builder.skip ()) {
                builder.build_method ();
            }
        }

        /* add virtual methods */
        foreach (var g_vm in g_class.all_of ("virtual-method")) {
            var builder = new MethodBuilder (v_class, g_vm);
            if (! builder.skip ()) {
                builder.build_virtual_method ();
            }
        }

        /* add fields, but skip the parent instance pointer */
        bool first_field = true;
        foreach (var g_field in g_class.all_of ("field")) {
            /* first field is guaranteed to be the parent instance */
            if (first_field) {
                first_field = false;
                if (g_class.has_attr ("parent")) {
                    continue;
                }
            }

            var builder = new FieldBuilder (v_class, g_field);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* add properties */
        foreach (var g_param in g_class.all_of ("property")) {
            var builder = new PropertyBuilder (v_class, g_param);
            if (! builder.skip ()) {
                builder.build ();
            }
        }

        /* add signals */
        foreach (var g_signal in g_class.all_of ("glib:signal")) {
            var builder = new MethodBuilder (v_class, g_signal);
            if (! builder.skip ()) {
                builder.build_signal ();
            }
        }

        /* always provide constructor in generated bindings
         * to indicate that implicit Object () chainup is allowed */
        if (no_introspectable_constructors ()) {
            var v_cm = new CreationMethod (null, null, g_class.source);
            v_cm.has_construct_function = false;
            v_cm.access = PROTECTED;
            v_class.add_method (v_cm);
        }

        return v_class;
    }

    /* check if one or more constructors will be generated for this class */
    private bool no_introspectable_constructors () {
        foreach (var ctor in g_class.all_of ("constructor")) {
            if (ctor.get_bool ("introspectable", true)) {
                return false;
            }
        }

        return true;
    }
}
