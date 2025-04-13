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

public class Gir.Interface : InfoAttrs, DocElements, InfoElements, Identifier, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string glib_type_name { owned get; set; }
    public string glib_get_type { owned get; set; }
    public string? c_symbol_prefix { owned get; set; }
    public string? c_type { owned get; set; }
    public Record? glib_type_struct { owned get; set; }
    public string glib_type_struct_unresolved { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Gee.List<Prerequisite> prerequisites { owned get; set; }
    public Gee.List<Implements> implements { owned get; set; }
    public Gee.List<Function> functions { owned get; set; }
    public Gee.List<FunctionInline> function_inlines { owned get; set; }
    public Constructor? constructor { get; set; }
    public Gee.List<Method> methods { owned get; set; }
    public Gee.List<MethodInline> method_inlines { owned get; set; }
    public Gee.List<VirtualMethod> virtual_methods { owned get; set; }
    public Gee.List<Field> fields { owned get; set; }
    public Gee.List<Property> properties { owned get; set; }
    public Gee.List<Signal> @signals { owned get; set; }
    public Gee.List<Callback> callbacks { owned get; set; }
    public Gee.List<Constant> constants { owned get; set; }

    public Interface (
            bool introspectable,
            bool deprecated,
            string? deprecated_version,
            string? version,
            string? stability,
            string name,
            string glib_type_name,
            string glib_get_type,
            string? c_symbol_prefix,
            string? c_type,
            string? glib_type_struct,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Gee.List<Attribute> attributes,
            Gee.List<Prerequisite> prerequisites,
            Gee.List<Implements> implements,
            Gee.List<Function> functions,
            Gee.List<FunctionInline> function_inlines,
            Constructor? constructor,
            Gee.List<Method> methods,
            Gee.List<MethodInline> method_inlines,
            Gee.List<VirtualMethod> virtual_methods,
            Gee.List<Field> fields,
            Gee.List<Property> properties,
            Gee.List<Signal> @signals,
            Gee.List<Callback> callbacks,
            Gee.List<Constant> constants,
            Gir.Xml.Reference? source) {
        base(source);
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.name = name;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.c_symbol_prefix = c_symbol_prefix;
        this.c_type = c_type;
        this.glib_type_struct_unresolved = glib_type_struct;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.prerequisites = prerequisites;
        this.implements = implements;
        this.functions = functions;
        this.function_inlines = function_inlines;
        this.constructor = constructor;
        this.methods = methods;
        this.method_inlines = method_inlines;
        this.virtual_methods = virtual_methods;
        this.fields = fields;
        this.properties = properties;
        this.@signals = @signals;
        this.callbacks = callbacks;
        this.constants = constants;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_interface (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);

        foreach (var prerequisite in prerequisites) {
            prerequisite.accept (visitor);
        }

        foreach (var implements in implements) {
            implements.accept (visitor);
        }

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }

        constructor?.accept (visitor);
        
        foreach (var method in methods) {
            method.accept (visitor);
        }

        foreach (var method_inline in method_inlines) {
            method_inline.accept (visitor);
        }

        foreach (var virtual_method in virtual_methods) {
            virtual_method.accept (visitor);
        }

        foreach (var property in properties) {
            property.accept (visitor);
        }

        foreach (var @signal in @signals) {
            @signal.accept (visitor);
        }

        foreach (var callback in callbacks) {
            callback.accept (visitor);
        }

        foreach (var constant in constants) {
            constant.accept (visitor);
        }

        foreach (var field in fields) {
            field.accept (visitor);
        }
    }
}

