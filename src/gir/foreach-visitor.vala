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
 * A Gir.Visitor implementation that runs a delegate in every Gir node.
 *
 * The behavior of the ForeachVisitor depends on the result of the delegate:
 *
 * | Result   | Description                                                 |
 * | -------- | ----------------------------------------------------------- |
 * | CONTINUE | Continue traversing the Gir tree                            |
 * | SKIP     | Skip the child nodes below this node, but continue visiting |
 * |          |   the rest of the tree                                      |
 * | STOP     | Stop the visitor completely                                 |
 */
public class Gir.ForeachVisitor : Gir.Visitor {
    private unowned ForEachFunc func;
    private ForeachResult result = CONTINUE;

    public ForeachVisitor (ForEachFunc func) {
        this.func = func;
    }

    public override void visit_alias (Gir.Alias alias) {
        if (result != STOP) {
            result = func (alias);
            if (result == CONTINUE) {
                alias.accept_children (this);
            }
        }
    }

    public override void visit_anonymous_record (Gir.AnonymousRecord record) {
        if (result != STOP) {
            result = func (record);
            if (result == CONTINUE) {
                record.accept_children (this);
            }
        }
    }

    public override void visit_array (Gir.Array array) {
        if (result != STOP) {
            result = func (array);
            if (result == CONTINUE) {
                array.accept_children (this);
            }
        }
    }

    public override void visit_attribute (Gir.Attribute attribute) {
        if (result != STOP) {
            result = func (attribute);
            if (result == CONTINUE) {
                attribute.accept_children (this);
            }
        }
    }

    public override void visit_bitfield (Gir.Bitfield bitfield) {
        if (result != STOP) {
            result = func (bitfield);
            if (result == CONTINUE) {
                bitfield.accept_children (this);
            }
        }
    }

    public override void visit_boxed (Gir.Boxed boxed) {
        if (result != STOP) {
            result = func (boxed);
            if (result == CONTINUE) {
                boxed.accept_children (this);
            }
        }
    }

    public override void visit_c_include (Gir.CInclude c_include) {
        if (result != STOP) {
            result = func (c_include);
            if (result == CONTINUE) {
                c_include.accept_children (this);
            }
        }
    }

    public override void visit_callback (Gir.Callback callback) {
        if (result != STOP) {
            result = func (callback);
            if (result == CONTINUE) {
                callback.accept_children (this);
            }
        }
    }

    public override void visit_class (Gir.Class cls) {
        if (result != STOP) {
            result = func (cls);
            if (result == CONTINUE) {
                cls.accept_children (this);
            }
        }
    }

    public override void visit_constant (Gir.Constant constant) {
        if (result != STOP) {
            result = func (constant);
            if (result == CONTINUE) {
                constant.accept_children (this);
            }
        }
    }

    public override void visit_constructor (Gir.Constructor constructor) {
        if (result != STOP) {
            result = func (constructor);
            if (result == CONTINUE) {
                constructor.accept_children (this);
            }
        }
    }

    public override void visit_doc_deprecated (Gir.DocDeprecated doc_deprecated) {
        if (result != STOP) {
            result = func (doc_deprecated);
            if (result == CONTINUE) {
                doc_deprecated.accept_children (this);
            }
        }
    }

    public override void visit_doc_format (Gir.DocFormat doc_format) {
        if (result != STOP) {
            result = func (doc_format);
            if (result == CONTINUE) {
                doc_format.accept_children (this);
            }
        }
    }

    public override void visit_doc_stability (Gir.DocStability doc_stability) {
        if (result != STOP) {
            result = func (doc_stability);
            if (result == CONTINUE) {
                doc_stability.accept_children (this);
            }
        }
    }

    public override void visit_doc_version (Gir.DocVersion doc_version) {
        if (result != STOP) {
            result = func (doc_version);
            if (result == CONTINUE) {
                doc_version.accept_children (this);
            }
        }
    }

    public override void visit_doc (Gir.Doc doc) {
        if (result != STOP) {
            result = func (doc);
            if (result == CONTINUE) {
                doc.accept_children (this);
            }
        }
    }

    public override void visit_docsection (Gir.Docsection docsection) {
        if (result != STOP) {
            result = func (docsection);
            if (result == CONTINUE) {
                docsection.accept_children (this);
            }
        }
    }

    public override void visit_enumeration (Gir.Enumeration enumeration) {
        if (result != STOP) {
            result = func (enumeration);
            if (result == CONTINUE) {
                enumeration.accept_children (this);
            }
        }
    }

    public override void visit_field (Gir.Field field) {
        if (result != STOP) {
            result = func (field);
            if (result == CONTINUE) {
                field.accept_children (this);
            }
        }
    }

    public override void visit_function_inline (Gir.FunctionInline function_inline) {
        if (result != STOP) {
            result = func (function_inline);
            if (result == CONTINUE) {
                function_inline.accept_children (this);
            }
        }
    }

    public override void visit_function_macro (Gir.FunctionMacro function_macro) {
        if (result != STOP) {
            result = func (function_macro);
            if (result == CONTINUE) {
                function_macro.accept_children (this);
            }
        }
    }

    public override void visit_function (Gir.Function function) {
        if (result != STOP) {
            result = func (function);
            if (result == CONTINUE) {
                function.accept_children (this);
            }
        }
    }

    public override void visit_implements (Gir.Implements implements) {
        if (result != STOP) {
            result = func (implements);
            if (result == CONTINUE) {
                implements.accept_children (this);
            }
        }
    }

    public override void visit_include (Gir.Include include) {
        if (result != STOP) {
            result = func (include);
            if (result == CONTINUE) {
                include.accept_children (this);
            }
        }
    }

    public override void visit_instance_parameter (Gir.InstanceParameter instance_parameter) {
        if (result != STOP) {
            result = func (instance_parameter);
            if (result == CONTINUE) {
                instance_parameter.accept_children (this);
            }
        }
    }

    public override void visit_interface (Gir.Interface iface) {
        if (result != STOP) {
            result = func (iface);
            if (result == CONTINUE) {
                iface.accept_children (this);
            }
        }
    }

    public override void visit_member (Gir.Member member) {
        if (result != STOP) {
            result = func (member);
            if (result == CONTINUE) {
                member.accept_children (this);
            }
        }
    }

    public override void visit_method_inline (Gir.MethodInline method_inline) {
        if (result != STOP) {
            result = func (method_inline);
            if (result == CONTINUE) {
                method_inline.accept_children (this);
            }
        }
    }

    public override void visit_method (Gir.Method method) {
        if (result != STOP) {
            result = func (method);
            if (result == CONTINUE) {
                method.accept_children (this);
            }
        }
    }

    public override void visit_namespace (Gir.Namespace ns) {
        if (result != STOP) {
            result = func (ns);
            if (result == CONTINUE) {
                ns.accept_children (this);
            }
        }
    }

    public override void visit_package (Gir.Package package) {
        if (result != STOP) {
            result = func (package);
            if (result == CONTINUE) {
                package.accept_children (this);
            }
        }
    }

    public override void visit_parameter (Gir.Parameter parameter) {
        if (result != STOP) {
            result = func (parameter);
            if (result == CONTINUE) {
                parameter.accept_children (this);
            }
        }
    }

    public override void visit_parameters (Gir.Parameters parameters) {
        if (result != STOP) {
            result = func (parameters);
            if (result == CONTINUE) {
                parameters.accept_children (this);
            }
        }
    }

    public override void visit_prerequisite (Gir.Prerequisite prerequisite) {
        if (result != STOP) {
            result = func (prerequisite);
            if (result == CONTINUE) {
                prerequisite.accept_children (this);
            }
        }
    }

    public override void visit_property (Gir.Property property) {
        if (result != STOP) {
            result = func (property);
            if (result == CONTINUE) {
                property.accept_children (this);
            }
        }
    }

    public override void visit_record (Gir.Record record) {
        if (result != STOP) {
            result = func (record);
            if (result == CONTINUE) {
                record.accept_children (this);
            }
        }
    }

    public override void visit_repository (Gir.Repository repository) {
        if (result != STOP) {
            result = func (repository);
            if (result == CONTINUE) {
                repository.accept_children (this);
            }
        }
    }

    public override void visit_return_value (Gir.ReturnValue return_value) {
        if (result != STOP) {
            result = func (return_value);
            if (result == CONTINUE) {
                return_value.accept_children (this);
            }
        }
    }

    public override void visit_signal (Gir.Signal sig) {
        if (result != STOP) {
            result = func (sig);
            if (result == CONTINUE) {
                sig.accept_children (this);
            }
        }
    }

    public override void visit_source_position (Gir.SourcePosition source_position) {
        if (result != STOP) {
            result = func (source_position);
            if (result == CONTINUE) {
                source_position.accept_children (this);
            }
        }
    }

    public override void visit_type (Gir.TypeRef type) {
        if (result != STOP) {
            result = func (type);
            if (result == CONTINUE) {
                type.accept_children (this);
            }
        }
    }

    public override void visit_union (Gir.Union union) {
        if (result != STOP) {
            result = func (union);
            if (result == CONTINUE) {
                union.accept_children (this);
            }
        }
    }

    public override void visit_varargs (Gir.Varargs varargs) {
        if (result != STOP) {
            result = func (varargs);
            if (result == CONTINUE) {
                varargs.accept_children (this);
            }
        }
    }

    public override void visit_virtual_method (Gir.VirtualMethod virtual_method) {
        if (result != STOP) {
            result = func (virtual_method);
            if (result == CONTINUE) {
                virtual_method.accept_children (this);
            }
        }
    }
}

/** The delegate that must be implemented when using the ForeachVisitor */
public delegate Gir.ForeachResult Gir.ForEachFunc (Node n);

/** Returned from ForeachFunc */
public enum Gir.ForeachResult {
    /** Continue visiting all nodes, including the children of this node */
    CONTINUE,

    /** Continue visiting all nodes, but skip the children of this node */
    SKIP,

    /** Do not visit any other nodes */
    STOP
}
