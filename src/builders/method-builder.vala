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

public class Builders.MethodBuilder : CallableBuilder {

    public MethodBuilder (Gir.Callable callable) {
        base (callable);
    }

    public Vala.CreationMethod build_constructor () {
        var ctor = (Gir.Constructor) callable;

        /* name */
        var name = ctor.name;
        if (name == "new") {
            name = null;
        } else if (name.has_prefix ("new_")) {
            name = name.substring ("new_".length);
        }

        /* create the constructor */
        var cr_method = new CreationMethod (null, name, ctor.source_reference);
        cr_method.access = SymbolAccessibility.PUBLIC;
        cr_method.has_construct_function = false;

        /* c name */
        if (ctor.c_identifier != generate_cname (ctor)) {
            cr_method.set_attribute_string ("CCode", "cname", ctor.c_identifier);
        }

        /* version */
        cr_method.set_attribute_string ("Version", "since", ctor.version);

        /* return type annotation */
        if (ctor.parent_node is Gir.Class) {
            var parent_type = ((Gir.Class) ctor.parent_node).c_type;
            var return_type = ((Gir.TypeRef) ctor.return_value.anytype).c_type;
            if (return_type != null &&
                    (parent_type == null || return_type != parent_type + "*")) {
                cr_method.set_attribute_string ("CCode", "type", return_type);
            }
        }

        /* parameters */
        add_parameters (cr_method);

        /* throws */
        if (ctor.throws) {
            cr_method.add_error_type (new Vala.ErrorType (null, null));
        }

        return cr_method;
    }

    public Vala.Method build_function () {
        var function = (Gir.Function) callable;
        
        /* return type */
        var return_value = function.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* create a static method */
        var vmethod = new Method (function.name, return_type, function.source_reference);
        vmethod.access = SymbolAccessibility.PUBLIC;
        vmethod.binding = MemberBinding.STATIC;

        /* c name */
        if (function.c_identifier != generate_cname (function)) {
            vmethod.set_attribute_string ("CCode", "cname", function.c_identifier);
        }

        /* version */
        vmethod.set_attribute_string ("Version", "since", function.version);

        /* parameters */
        add_parameters (vmethod);

        /* throws */
        if (function.throws) {
            vmethod.add_error_type (new Vala.ErrorType (null, null));
        }

        return vmethod;
    }

    public Vala.Method build_method () {
        var method = (Gir.Method) callable;

        /* return type */
        var return_value = method.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* the method itself */
        var vmethod = new Method (method.name, return_type, method.source_reference);
        vmethod.access = SymbolAccessibility.PUBLIC;

        /* c name */
        if (method.c_identifier != generate_cname (method)) {
            vmethod.set_attribute_string ("CCode", "cname", method.c_identifier);
        }

        /* version */
        vmethod.set_attribute_string ("Version", "since", method.version);

        /* parameters */
        add_parameters (vmethod);

        /* throws */
        if (method.throws) {
            vmethod.add_error_type (new Vala.ErrorType (null, null));
        }

        return vmethod;
    }

    public Vala.Method build_virtual_method () {
        var method = (Gir.VirtualMethod) callable;

        /* return type */
        var return_value = method.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* the method itself */
        var vmethod = new Method (method.name, return_type, method.source_reference);
        vmethod.access = SymbolAccessibility.PUBLIC;
        if (method.parent_node is Interface) {
            vmethod.is_abstract = true;
        } else {
            vmethod.is_virtual = true;
        }

        /* version */
        vmethod.set_attribute_string ("Version", "since", method.version);

        /* parameters */
        add_parameters (vmethod);

        /* throws */
        if (method.throws) {
            vmethod.add_error_type (new Vala.ErrorType (null, null));
        }

        return vmethod;
    }

    public bool skip () {
        return (! callable.introspectable) || is_invoker_method ();
    }

    /* Find a virtual method invoked by this method. */
    private bool is_invoker_method () {
        if (! (callable is Gir.Method)) {
            return false;
        }

        Gir.Method m = (Gir.Method) callable;
        Gee.List<Gir.VirtualMethod> virtual_methods =
                callable.parent_node.all_of (typeof (Gir.VirtualMethod));

        foreach (var vm in virtual_methods) {
            /* ideally, the invoker annotation matches */
            if (vm.invoker == m.name) {
                return true;
            }

            /* check if the names match, and both or neither throws */
            if (m.name != vm.name || m.throws != vm.throws) {
                continue;
            }

            /* if both have no parameters, it's a match */
            if (m.parameters == null && vm.parameters == null) {
                return true;
            }

            /* if only one has no parameters, it's not a match */
            if (m.parameters == null || vm.parameters == null) {
                continue;
            }

            var m_params = m.parameters.parameters;
            var vm_params = vm.parameters.parameters;

            /* both should have the same number of parameters */
            if (m_params.size != vm_params.size) {
                continue;
            }

            /* both should have the same parameter names */
            bool same_param_names = true;
            for (int i = 0; i < m_params.size; i++) {
                if (m_params[i].name != vm_params[i].name) {
                    same_param_names = false;
                    break;
                }
            }

            if (same_param_names) {
                return true;
            }
        }

        /* no virtual method invoked by this method */
        return false;
    }

    /* generate the C function name from the GIR name and all prefixes */
    private string generate_cname (Gir.Callable callable) {
        var sb = new StringBuilder (callable.name);
        unowned var node = callable.parent_node;
        while (node != null) {
            var prefix = node.attrs["c:symbol-prefix"] ?? node.attrs["c:symbol-prefixes"];
            if (prefix != null) {
                sb.prepend (prefix + "_");
            }

            node = node.parent_node;
        }

        return sb.str;
    }
}
