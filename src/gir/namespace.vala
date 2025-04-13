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

public class Gir.Namespace : Node {
    public string? name { owned get; set; }
    public string? version { owned get; set; }
    public string? c_identifier_prefixes { owned get; set; }
    public string? c_symbol_prefixes { owned get; set; }
    public string? c_prefix { owned get; set; }
    public string? shared_library { owned get; set; }
    public Gee.List<Alias> aliases { owned get; set; }
    public Gee.List<Class> classes { owned get; set; }
    public Gee.List<Interface> interfaces { owned get; set; }
    public Gee.List<Record> records { owned get; set; }
    public Gee.List<Enumeration> enums { owned get; set; }
    public Gee.List<Function> functions { owned get; set; }
    public Gee.List<FunctionInline> function_inlines { owned get; set; }
    public Gee.List<FunctionMacro> function_macros { owned get; set; }
    public Gee.List<Union> unions { owned get; set; }
    public Gee.List<Bitfield> bitfields { owned get; set; }
    public Gee.List<Callback> callbacks { owned get; set; }
    public Gee.List<Constant> constants { owned get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Gee.List<Boxed> boxeds { owned get; set; }
    public Gee.List<Docsection> doc_sections { owned get; set; }

    public Namespace (
            string? name,
            string? version,
            string? c_identifier_prefixes,
            string? c_symbol_prefixes,
            string? c_prefix,
            string? shared_library,
            Gee.List<Alias> aliases,
            Gee.List<Class> classes,
            Gee.List<Interface> interfaces,
            Gee.List<Record> records,
            Gee.List<Enumeration> enums,
            Gee.List<Function> functions,
            Gee.List<FunctionInline> function_inlines,
            Gee.List<FunctionMacro> function_macros,
            Gee.List<Union> unions,
            Gee.List<Bitfield> bit_fields,
            Gee.List<Callback> callbacks,
            Gee.List<Constant> constants,
            Gee.List<Attribute> attributes,
            Gee.List<Boxed> boxeds,
            Gee.List<Docsection> doc_sections,
            Gir.Xml.Reference? source) {
        base(source);
        this.name = name;
        this.version = version;
        this.c_identifier_prefixes = c_identifier_prefixes;
        this.c_symbol_prefixes = c_symbol_prefixes;
        this.c_prefix = c_prefix;
        this.shared_library = shared_library;
        this.aliases = aliases;
        this.classes = classes;
        this.interfaces = interfaces;
        this.records = records;
        this.enums = enums;
        this.functions = functions;
        this.function_inlines = function_inlines;
        this.function_macros = function_macros;
        this.unions = unions;
        this.bitfields = bit_fields;
        this.callbacks = callbacks;
        this.constants = constants;
        this.attributes = attributes;
        this.boxeds = boxeds;
        this.doc_sections = doc_sections;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_namespace (this);
    }

    public override void accept_children (Visitor visitor) {
        foreach (var @class in classes) {
            @class.accept (visitor);
        }

        foreach (var @interface in interfaces) {
            @interface.accept (visitor);
        }

        foreach (var record in records) {
            record.accept (visitor);
        }

        foreach (var @enum in enums) {
            @enum.accept (visitor);
        }

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }

        foreach (var function_macro in function_macros) {
            function_macro.accept (visitor);
        }

        foreach (var union in unions) {
            union.accept (visitor);
        }

        foreach (var bit_field in bitfields) {
            bit_field.accept (visitor);
        }

        foreach (var callback in callbacks) {
            callback.accept (visitor);
        }

        foreach (var constant in constants) {
            constant.accept (visitor);
        }

        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        foreach (var boxed in boxeds) {
            boxed.accept (visitor);
        }

        foreach (var doc_section in doc_sections) {
            doc_section.accept (visitor);
        }

        foreach (var alias in aliases) {
            alias.accept (visitor);
        }
    }
}

