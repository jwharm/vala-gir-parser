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

public class Gir.Class : InfoAttrs, InfoElements, Identifier, DocElements, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string glib_type_name { owned get; set; }
    public string glib_get_type { owned get; set; }
    public string? parent { owned get; set; }
    public string? glib_type_struct { owned get; set; }
    public string? glib_ref_func { owned get; set; }
    public string? glib_unref_func { owned get; set; }
    public string? glib_set_value_func { owned get; set; }
    public string? glib_get_value_func { owned get; set; }
    public string? c_type { owned get; set; }
    public string? c_symbol_prefix { owned get; set; }
    public bool @abstract { get; set; }
    public bool glib_fundamental { get; set; }
    public bool @final { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Vala.List<Attribute> attributes { owned get; set; }
    public Vala.List<Implements> implements { owned get; set; }
    public Vala.List<Constructor> constructors { owned get; set; }
    public Vala.List<Method> methods { owned get; set; }
    public Vala.List<MethodInline> method_inlines { owned get; set; }
    public Vala.List<Function> functions { owned get; set; }
    public Vala.List<FunctionInline> function_inlines { owned get; set; }
    public Vala.List<VirtualMethod> virtual_methods { owned get; set; }
    public Vala.List<Field> fields { owned get; set; }
    public Vala.List<Property> properties { owned get; set; }
    public Vala.List<Signal> @signals { owned get; set; }
    public Vala.List<Union> unions { owned get; set; }
    public Vala.List<Constant> constants { owned get; set; }
    public Vala.List<Record> records { owned get; set; }
    public Vala.List<Callback> callbacks { owned get; set; }

    public Class (
            bool introspectable,
            bool deprecated,
            string? deprecated_version,
            string? version,
            string? stability,
            string name,
            string glib_type_name,
            string glib_get_type,
            string? parent,
            string? glib_type_struct,
            string? glib_ref_func,
            string? glib_unref_func,
            string? glib_set_value_func,
            string? glib_get_value_func,
            string? c_type,
            string? c_symbol_prefix,
            bool @abstract,
            bool glib_fundamental,
            bool @final,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Vala.List<Attribute> attributes,
            Vala.List<Implements> implements,
            Vala.List<Constructor> constructors,
            Vala.List<Method> methods,
            Vala.List<MethodInline> method_inlines,
            Vala.List<Function> functions,
            Vala.List<FunctionInline> function_inlines,
            Vala.List<VirtualMethod> virtual_methods,
            Vala.List<Field> fields,
            Vala.List<Property> properties,
            Vala.List<Signal> @signals,
            Vala.List<Union> unions,
            Vala.List<Constant> constants,
            Vala.List<Record> records,
            Vala.List<Callback> callbacks,
            Vala.SourceReference? source) {
        base(source);
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.name = name;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.parent = parent;
        this.glib_type_struct = glib_type_struct;
        this.glib_ref_func = glib_ref_func;
        this.glib_unref_func = glib_unref_func;
        this.glib_set_value_func = glib_set_value_func;
        this.glib_get_value_func = glib_get_value_func;
        this.c_type = c_type;
        this.c_symbol_prefix = c_symbol_prefix;
        this.@abstract = @abstract;
        this.glib_fundamental = glib_fundamental;
        this.@final = @final;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.implements = implements;
        this.constructors = constructors;
        this.methods = methods;
        this.method_inlines = method_inlines;
        this.functions = functions;
        this.function_inlines = function_inlines;
        this.virtual_methods = virtual_methods;
        this.fields = fields;
        this.properties = properties;
        this.@signals = @signals;
        this.unions = unions;
        this.constants = constants;
        this.records = records;
        this.callbacks = callbacks;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_class (this);
    }

    public override void accept_children (GirVisitor visitor) {
        doc_version?.accept (visitor);
        doc_stability?.accept (visitor);
        doc?.accept (visitor);
        doc_deprecated?.accept (visitor);
        source_position?.accept (visitor);
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        foreach (var implements in implements) {
            implements.accept (visitor);
        }

        foreach (var constructor in constructors) {
            constructor.accept (visitor);
        }

        foreach (var method in methods) {
            method.accept (visitor);
        }

        foreach (var method_inline in method_inlines) {
            method_inline.accept (visitor);
        }

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }

        foreach (var virtual_method in virtual_methods) {
            virtual_method.accept (visitor);
        }

        foreach (var field in fields) {
            field.accept (visitor);
        }

        foreach (var property in properties) {
            property.accept (visitor);
        }

        foreach (var @signal in @signals) {
            @signal.accept (visitor);
        }

        foreach (var union in unions) {
            union.accept (visitor);
        }

        foreach (var constant in constants) {
            constant.accept (visitor);
        }

        foreach (var record in records) {
            record.accept (visitor);
        }

        foreach (var callback in callbacks) {
            callback.accept (visitor);
        }
    }
}

