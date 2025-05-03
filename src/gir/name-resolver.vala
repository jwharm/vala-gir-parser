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
 * Gir Node visitor to find a symbol with the given name. We only check the
 * node itself, so accept_children() for a NameResolver will only visit the
 * direct child nodes.
 */
public class Gir.NameResolver : Gir.Visitor {
    public string name;
    public bool found;
    public Node result;

    public NameResolver (string name) {
        this.name = name;
        this.found = false;
        this.result = null;
    }

    public override void visit_alias (Alias alias) {
        if (!found && name == alias.name) {
            result = alias;
            found = true;
        }
    }

    public override void visit_array (Array array) {
        if (!found && name == array.name) {
            result = array;
            found = true;
        }
    }

    public override void visit_attribute (Attribute attribute) {
        if (!found && name == attribute.name) {
            result = attribute;
            found = true;
        }
    }

    public override void visit_bitfield (Bitfield bitfield) {
        if (!found && name == bitfield.name) {
            result = bitfield;
            found = true;
        }
    }

    public override void visit_boxed (Boxed boxed) {
        if (!found && name == boxed.name) {
            result = boxed;
            found = true;
        }
    }

    public override void visit_c_include (CInclude c_include) {
        if (!found && name == c_include.name) {
            result = c_include;
            found = true;
        }
    }

    public override void visit_callback (Callback callback) {
        if (!found && name == callback.name) {
            result = callback;
            found = true;
        }
    }

    public override void visit_class (Class cls) {
        if (!found && name == cls.name) {
            result = cls;
            found = true;
        }
    }

    public override void visit_constant (Constant constant) {
        if (!found && name == constant.name) {
            result = constant;
            found = true;
        }
    }

    public override void visit_constructor (Constructor constructor) {
        if (!found && name == constructor.name) {
            result = constructor;
            found = true;
        }
    }

    public override void visit_enumeration (Enumeration enumeration) {
        if (!found && name == enumeration.name) {
            result = enumeration;
            found = true;
        }
    }

    public override void visit_field (Field field) {
        if (!found && name == field.name) {
            result = field;
            found = true;
        }
    }

    public override void visit_function_inline (FunctionInline function_inline) {
        if (!found && name == function_inline.name) {
            result = function_inline;
            found = true;
        }
    }

    public override void visit_function_macro (FunctionMacro function_macro) {
        if (!found && name == function_macro.name) {
            result = function_macro;
            found = true;
        }
    }

    public override void visit_function (Function function) {
        if (!found && name == function.name) {
            result = function;
            found = true;
        }
    }

    public override void visit_implements (Implements implements) {
        if (!found && name == implements.name) {
            result = implements;
            found = true;
        }
    }

    public override void visit_include (Include include) {
        if (!found && name == include.name) {
            result = include;
            found = true;
        }
    }

    public override void visit_instance_parameter (InstanceParameter instance_parameter) {
        if (!found && name == instance_parameter.name) {
            result = instance_parameter;
            found = true;
        }
    }

    public override void visit_interface (Interface iface) {
        if (!found && name == iface.name) {
            result = iface;
            found = true;
        }
    }

    public override void visit_member (Member member) {
        if (!found && name == member.name) {
            result = member;
            found = true;
        }
    }

    public override void visit_method_inline (MethodInline method_inline) {
        if (!found && name == method_inline.name) {
            result = method_inline;
            found = true;
        }
    }

    public override void visit_method (Method method) {
        if (!found && name == method.name) {
            result = method;
            found = true;
        }
    }

    public override void visit_namespace (Namespace ns) {
        if (!found && name == ns.name) {
            result = ns;
            found = true;
        }
    }

    public override void visit_package (Package package) {
        if (!found && name == package.name) {
            result = package;
            found = true;
        }
    }

    public override void visit_parameter (Parameter parameter) {
        if (!found && name == parameter.name) {
            result = parameter;
            found = true;
        }
    }

    public override void visit_prerequisite (Prerequisite prerequisite) {
        if (!found && name == prerequisite.name) {
            result = prerequisite;
            found = true;
        }
    }

    public override void visit_property (Property property) {
        if (!found && name == property.name) {
            result = property;
            found = true;
        }
    }

    public override void visit_record (Record record) {
        if (!found && name == record.name) {
            result = record;
            found = true;
        }
    }

    public override void visit_signal (Signal sig) {
        if (!found && name == sig.name) {
            result = sig;
            found = true;
        }
    }

    public override void visit_type (TypeRef type) {
        if (!found && name == type.name) {
            result = type;
            found = true;
        }
    }

    public override void visit_union (Union union) {
        if (!found && name == union.name) {
            result = union;
            found = true;
        }
    }

    public override void visit_virtual_method (VirtualMethod virtual_method) {
        if (!found && name == virtual_method.name) {
            result = virtual_method;
            found = true;
        }
    }
}
