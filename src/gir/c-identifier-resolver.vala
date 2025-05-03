/* vala-gir-parser
 * Copyright (C) 2025 Jan-Willem Harmannij
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

/**
 * Gir Node visitor that will traverse the entire tree in order to find a symbol
 * with the given C identifier. We check the namespace and type definitions for
 * a matching "c:identifier-prefix" to make sure we're searching in the correct
 * place.
 */
public class Gir.CIdentifierResolver : Gir.Visitor {
    public string c_identifier;
    public bool found;
    public Node result;

    public CIdentifierResolver (string c_identifier) {
        this.c_identifier = c_identifier;
        this.found = false;
        this.result = null;
    }

    public override void visit_bitfield (Bitfield bitfield) {
        if (!found) {
            bitfield.accept_children (this);
        }
    }

    public override void visit_boxed (Boxed boxed) {
        if (!found && c_identifier.has_prefix (boxed.c_symbol_prefix)) {
            boxed.accept_children (this);
        }
    }

    public override void visit_class (Class cls) {
        if (!found && c_identifier.has_prefix (cls.c_symbol_prefix)) {
            cls.accept_children (this);
        }
    }

    public override void visit_constant (Constant constant) {
        if (!found && constant.c_identifier == c_identifier) {
            result = constant;
            found = true;
        }
    }

    public override void visit_constructor (Constructor constructor) {
        if (!found && constructor.c_identifier == c_identifier) {
            result = constructor;
            found = true;
        }
    }

    public override void visit_enumeration (Enumeration enumeration) {
        if (!found) {
            enumeration.accept_children (this);
        }
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        if (!found && function_inline.c_identifier == c_identifier) {
            result = function_inline;
            found = true;
        }
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        if (!found && function_macro.c_identifier == c_identifier) {
            result = function_macro;
            found = true;
        }
    }

    public override void visit_function (Function function) {
        if (!found && function.c_identifier == c_identifier) {
            result = function;
            found = true;
        }
    }

    public override void visit_interface (Interface iface) {
        if (!found && c_identifier.has_prefix (iface.c_symbol_prefix)) {
            iface.accept_children (this);
        }
    }

    public override void visit_member (Member member) {
        if (!found && member.c_identifier == c_identifier) {
            result = member;
            found = true;
        }
    }

    public override void visit_method_inline (MethodInline method_inline) {
        if (!found && method_inline.c_identifier == c_identifier) {
            result = method_inline;
            found = true;
        }
    }

    public override void visit_method (Method method) {
        if (!found && method.c_identifier == c_identifier) {
            result = method;
            found = true;
        }
    }

    public override void visit_namespace (Namespace ns) {
        if (!found && c_identifier.has_suffix (ns.c_symbol_prefixes)) {
            ns.accept_children (this);
        }
    }

    public override void visit_record (Record record) {
        if (!found && c_identifier.has_prefix (record.c_symbol_prefix)) {
            record.accept_children (this);
        }
    }

    public override void visit_repository (Repository repository) {
        if (!found) {
            repository.accept_children (this);
        }
    }

    public override void visit_union (Union union) {
        if (!found && c_identifier.has_prefix (union.c_symbol_prefix)) {
            union.accept_children (this);
        }
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        if (!found && virtual_method.c_identifier == c_identifier) {
            result = virtual_method;
            found = true;
        }
    }
}
