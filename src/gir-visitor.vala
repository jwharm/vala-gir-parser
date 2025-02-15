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

public abstract class GirVisitor {
    public virtual void visit_alias (Gir.Alias alias) {
    }

    public virtual void visit_array (Gir.Array array) {
    }

    public virtual void visit_attribute (Gir.Attribute attribute) {
    }

    public virtual void visit_bitfield (Gir.Bitfield bitfield) {
    }

    public virtual void visit_boxed (Gir.Boxed boxed) {
    }

    public virtual void visit_c_include (Gir.CInclude c_include) {
    }

    public virtual void visit_callback (Gir.Callback callback) {
    }

    public virtual void visit_class (Gir.Class @class) {
    }

    public virtual void visit_constant (Gir.Constant constant) {
    }

    public virtual void visit_constructor (Gir.Constructor constructor) {
    }

    public virtual void visit_doc_deprecated (Gir.DocDeprecated doc_deprecated) {
    }

    public virtual void visit_doc_stability (Gir.DocStability doc_stability) {
    }

    public virtual void visit_doc_version (Gir.DocVersion doc_version) {
    }

    public virtual void visit_doc (Gir.Doc doc) {
    }

    public virtual void visit_docsection (Gir.Docsection docsection) {
    }

    public virtual void visit_enumeration (Gir.Enumeration enumeration) {
    }

    public virtual void visit_field (Gir.Field field) {
    }

    public virtual void visit_function_inline (Gir.FunctionInline function_inline) {
    }

    public virtual void visit_function_macro (Gir.FunctionMacro function_macro) {
    }

    public virtual void visit_function (Gir.Function function) {
    }

    public virtual void visit_implements (Gir.Implements implements) {
    }

    public virtual void visit_include (Gir.Include include) {
    }

    public virtual void visit_instance_parameter (Gir.InstanceParameter instance_parameter) {
    }

    public virtual void visit_interface (Gir.Interface @interface) {
    }

    public virtual void visit_member (Gir.Member member) {
    }

    public virtual void visit_method_inline (Gir.MethodInline method_inline) {
    }

    public virtual void visit_method (Gir.Method method) {
    }

    public virtual void visit_namespace (Gir.Namespace @namespace) {
    }

    public virtual void visit_package (Gir.Package package) {
    }

    public virtual void visit_parameter (Gir.Parameter parameter) {
    }

    public virtual void visit_parameters (Gir.Parameters parameters) {
    }

    public virtual void visit_prerequisite (Gir.Prerequisite prerequisite) {
    }

    public virtual void visit_property (Gir.Property property) {
    }

    public virtual void visit_record (Gir.Record record) {
    }

    public virtual void visit_repository (Gir.Repository repository) {
    }

    public virtual void visit_return_value (Gir.ReturnValue return_value) {
    }

    public virtual void visit_signal (Gir.Signal @signal) {
    }

    public virtual void visit_source_position (Gir.SourcePosition source_position) {
    }

    public virtual void visit_type (Gir.TypeRef type) {
    }

    public virtual void visit_union (Gir.Union union) {
    }

    public virtual void visit_varargs (Gir.Varargs varargs) {
    }

    public virtual void visit_virtual_method (Gir.VirtualMethod virtual_method) {
    }
}
