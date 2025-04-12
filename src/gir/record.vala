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

public class Gir.Record : InfoAttrs, DocElements, InfoElements, Identifier, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string? c_type { owned get; set; }
    public bool disguised { get; set; }
    public bool opaque { get; set; }
    public bool pointer { get; set; }
    public string? glib_type_name { owned get; set; }
    public string? glib_get_type { owned get; set; }
    public string? c_symbol_prefix { owned get; set; }
    public bool foreign { get; set; }
    public string? glib_is_gtype_struct_for { owned get; set; }
    public string? copy_function { owned get; set; }
    public string? free_function { owned get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Gee.List<Field> fields { owned get; set; }
    public Gee.List<Function> functions { owned get; set; }
    public Gee.List<FunctionInline> function_inlines { owned get; set; }
    public Gee.List<Union> unions { owned get; set; }
    public Gee.List<Method> methods { owned get; set; }
    public Gee.List<MethodInline> method_inlines { owned get; set; }
    public Gee.List<Constructor> constructors { owned get; set; }

    public Record (
            bool introspectable,
            bool deprecated,
            string? deprecated_version,
            string? version,
            string? stability,
            string name,
            string? c_type,
            bool disguised,
            bool opaque,
            bool pointer,
            string? glib_type_name,
            string? glib_get_type,
            string? c_symbol_prefix,
            bool foreign,
            string? glib_is_gtype_struct_for,
            string? copy_function,
            string? free_function,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Gee.List<Attribute> attributes,
            Gee.List<Field> fields,
            Gee.List<Function> functions,
            Gee.List<FunctionInline> function_inlines,
            Gee.List<Union> unions,
            Gee.List<Method> methods,
            Gee.List<MethodInline> method_inlines,
            Gee.List<Constructor> constructors,
            Gir.Xml.Reference? source) {
        base(source);
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.name = name;
        this.c_type = c_type;
        this.disguised = disguised;
        this.opaque = opaque;
        this.pointer = pointer;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.c_symbol_prefix = c_symbol_prefix;
        this.foreign = foreign;
        this.glib_is_gtype_struct_for = glib_is_gtype_struct_for;
        this.copy_function = copy_function;
        this.free_function = free_function;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.fields = fields;
        this.functions = functions;
        this.function_inlines = function_inlines;
        this.unions = unions;
        this.methods = methods;
        this.method_inlines = method_inlines;
        this.constructors = constructors;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_record (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }

        foreach (var union in unions) {
            union.accept (visitor);
        }

        foreach (var method in methods) {
            method.accept (visitor);
        }

        foreach (var method_inline in method_inlines) {
            method_inline.accept (visitor);
        }

        foreach (var constructor in constructors) {
            constructor.accept (visitor);
        }

        foreach (var field in fields) {
            field.accept (visitor);
        }
    }
}

