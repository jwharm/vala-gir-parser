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

public class Builders.InfoAttrsBuilder {

    private Gir.Node g_info_attrs;

    public InfoAttrsBuilder (Gir.Node g_info_attrs) {
        this.g_info_attrs = g_info_attrs;
    }

    public void add_info_attrs (Symbol v_sym) {
        /* version */
        v_sym.version.since = g_info_attrs.get_string ("version");

        /* deprecated and deprecated_since */
        if (g_info_attrs.get_bool ("deprecated")) {
            /* omit deprecation attributes when the parent already has them */
            if (g_info_attrs.parent_node.get_bool ("deprecated")) {
                return;
            }

            v_sym.version.deprecated = true;
            var since = g_info_attrs.get_string ("deprecated-version");
            v_sym.version.deprecated_since = since;
        }

        if (g_info_attrs.has_attr ("vala:experimental")) {
            var experimental = g_info_attrs.get_bool ("vala:experimental");
            v_sym.set_attribute_bool ("Version", "experimental", experimental);
        }

        if (g_info_attrs.has_attr ("vala:instance-idx")) {
            var idx = (double) g_info_attrs.get_int ("vala:instance-idx");
            v_sym.set_attribute_double ("CCode", "instance_pos", idx + 0.5);
        }

        if (g_info_attrs.has_attr ("vala:type-get-function")) {
            var get_type = g_info_attrs.get_string ("vala:type-get-function");
            v_sym.set_attribute_string ("CCode", "type_get_function", get_type);
        }

        if (g_info_attrs.has_attr ("vala:hides")) {
            v_sym.hides = g_info_attrs.get_bool ("vala:hides");
        }

        if (g_info_attrs.get_bool ("vala:floating") && v_sym is Method) {
            unowned var v_method = (Method) v_sym;
            v_method.returns_floating_reference = true;
            v_method.return_type.value_owned = true;
        }

		if (g_info_attrs.has_attr ("glib:finish-func")) {
            var finish_func = g_info_attrs.get_string ("glib:finish-func");
            var name = g_info_attrs.get_string ("name");
            if (name.has_suffix ("_async")) {
                name = name.substring (0, name.length - 6);
            }
            var expected = name + "_finish";
            if (finish_func != expected) {
                v_sym.set_attribute_string ("CCode", "finish_name", finish_func);
            }
		}

        if (g_info_attrs.has_attr ("vala:finish-vfunc-name")) {
            var name = g_info_attrs.get_string ("vala:finish-vfunc-name");
			v_sym.set_attribute_string ("CCode", "finish_vfunc_name", name);
		}

        if (g_info_attrs.has_attr ("vala:finish-instance")) {
            var name = g_info_attrs.get_string ("vala:finish-instance");
			v_sym.set_attribute_string ("CCode", "finish_instance", name);
		}

        if (g_info_attrs.has_attr ("feature-test-macro")) {
            var macro = g_info_attrs.get_string ("feature-test-macro");
            v_sym.set_attribute_string ("CCode", "feature_test_macro", macro);
        }

        if (g_info_attrs.has_attr ("vala:delegate-target")) {
            var dlg_target = g_info_attrs.get_bool ("vala:delegate-target");
            v_sym.set_attribute_bool ("CCode", "delegate_target", dlg_target);
        }

        if (g_info_attrs.has_attr ("vala:printf-format")) {
            var printf_format = g_info_attrs.get_bool ("vala:printf-format");
            v_sym.set_attribute ("PrintfFormat", printf_format);
        }

        /* "sentinel" is the terminator value of a varargs parameter list */
        if (g_info_attrs.has_attr ("vala:sentinel")) {
            var sentinel = g_info_attrs.get_string ("vala:sentinel");
            v_sym.set_attribute_string ("CCode", "sentinel", sentinel);
        }

        if (g_info_attrs.has_attr ("vala:returns-modified-pointer")) {
            var ret_mod_p = g_info_attrs.get_bool ("vala:returns-modified-pointer");
            v_sym.set_attribute ("ReturnsModifiedPointer", ret_mod_p);
        }
    }
}
