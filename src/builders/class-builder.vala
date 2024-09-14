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

public class Builders.ClassBuilder : IdentifierBuilder, InfoAttrsBuilder {

    private Gir.Class g_class;

    public ClassBuilder (Gir.Class g_class) {
        this.g_class = g_class;
    }

    public Gir.InfoAttrs info_attrs () {
        return this.g_class;
    }

    public Vala.Class build () {
        /* the class */
        Vala.Class v_class = new Vala.Class (g_class.name, g_class.source_reference);
        v_class.access = SymbolAccessibility.PUBLIC;
        v_class.is_abstract = g_class.abstract;
        v_class.is_sealed = g_class.final;

        /* parent class */
        if (g_class.parent != null) {
            var base_type = DataTypeBuilder.from_name (g_class.parent, g_class.source_reference);
            v_class.add_base_type (base_type);
        }

        /* implemented interfaces */
        foreach (var g_imp in g_class.implements) {
            var imp_type = DataTypeBuilder.from_name (g_imp.name, g_imp.source_reference);
            v_class.add_base_type (imp_type);
        }

        /* c_name */
        if (g_class.c_type != generate_cname (g_class)) {
            v_class.set_attribute_string ("CCode", "cname", g_class.c_type);
        }

        /* version */
        add_version_attrs (v_class);

        /* type_cname */
        if (g_class.glib_type_struct != null &&
                g_class.glib_type_struct != generate_type_cname (g_class)) {
            var type_cname = get_ns_prefix (g_class) + g_class.glib_type_struct;
            v_class.set_attribute_string ("CCode", "type_cname", type_cname);
        }

        /* get_type method */
        var type_id = g_class.glib_get_type;
        if (type_id == null) {
            v_class.set_attribute_bool ("CCode", "has_type_id", false);
        } else {
            v_class.set_attribute_string ("CCode", "type_id", type_id + " ()");
        }

        /* add constructors */
        if (! g_class.abstract) {
            foreach (var g_ctor in g_class.constructors) {
                var builder = new MethodBuilder (g_ctor);
                if (! builder.skip ()) {
                    v_class.add_method (builder.build_constructor ());
                }
            }
        }

        /* add functions */
        foreach (var g_function in g_class.functions) {
            var builder = new MethodBuilder (g_function);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_function ());
            } 
        }

        /* add methods */
        foreach (var g_method in g_class.methods) {
            var builder = new MethodBuilder (g_method);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_method ());
            } 
        }

        /* add virtual methods */
        foreach (var g_vm in g_class.virtual_methods) {
            var builder = new MethodBuilder (g_vm);
            if (! builder.skip ()) {
                v_class.add_method (builder.build_virtual_method ());
            } 
        }

        /* add fields, but skip the parent instance pointer */
        bool first_field = true;
        foreach (var g_field in g_class.fields) {
            /* first field is guaranteed to be the parent instance */
            if (first_field) {
                first_field = false;
                if (g_class.parent != null) {
                    continue;
                }
            }

            var builder = new FieldBuilder (g_field);
            if (! builder.skip ()) {
                v_class.add_field (builder.build ());
            }
        }

        /* add properties */
        foreach (var g_param in g_class.properties) {
            var builder = new PropertyBuilder (g_param);
            v_class.add_property (builder.build ());
        }

        /* add signals */
        foreach (var g_signal in g_class.signals) {
            var builder = new MethodBuilder (g_signal);
            v_class.add_signal (builder.build_signal ());
        }

        /* always provide constructor in generated bindings
         * to indicate that implicit Object () chainup is allowed */
        if (no_introspectable_constructors ()) {
            var v_cm = new CreationMethod (null, null, g_class.source_reference);
            v_cm.has_construct_function = false;
            v_cm.access = SymbolAccessibility.PROTECTED;
            v_class.add_method (v_cm);
        }

        return v_class;
    }

    /* check if one or more constructors will be generated for this class */
    private bool no_introspectable_constructors () {
        foreach (var ctor in g_class.constructors) {
            if (ctor.introspectable) {
                return false;
            }
        }

        return true;
    }
}
