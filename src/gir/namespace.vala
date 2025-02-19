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
    public Vala.List<Alias> alias { owned get; set; }
    public Vala.List<Class> class { owned get; set; }
    public Vala.List<Interface> interfaces { owned get; set; }
    public Vala.List<Record> records { owned get; set; }
    public Vala.List<Enumeration> enums { owned get; set; }
    public Vala.List<Function> functions { owned get; set; }
    public Vala.List<FunctionInline> function_inlines { owned get; set; }
    public Vala.List<FunctionMacro> function_macros { owned get; set; }
    public Vala.List<Union> unions { owned get; set; }
    public Vala.List<Bitfield> bit_fields { owned get; set; }
    public Vala.List<Callback> callbacks { owned get; set; }
    public Vala.List<Constant> constants { owned get; set; }
    public Vala.List<Attribute> attributes { owned get; set; }
    public Vala.List<Boxed> boxeds { owned get; set; }
    public Vala.List<Docsection> doc_sections { owned get; set; }

    public Namespace (
            string? name,
            string? version,
            string? c_identifier_prefixes,
            string? c_symbol_prefixes,
            string? c_prefix,
            string? shared_library,
            Vala.List<Alias> alias,
            Vala.List<Class> class,
            Vala.List<Interface> interfaces,
            Vala.List<Record> records,
            Vala.List<Enumeration> enums,
            Vala.List<Function> functions,
            Vala.List<FunctionInline> function_inlines,
            Vala.List<FunctionMacro> function_macros,
            Vala.List<Union> unions,
            Vala.List<Bitfield> bit_fields,
            Vala.List<Callback> callbacks,
            Vala.List<Constant> constants,
            Vala.List<Attribute> attributes,
            Vala.List<Boxed> boxeds,
            Vala.List<Docsection> doc_sections,
            Vala.SourceReference? source) {
        base(source);
        this.name = name;
        this.version = version;
        this.c_identifier_prefixes = c_identifier_prefixes;
        this.c_symbol_prefixes = c_symbol_prefixes;
        this.c_prefix = c_prefix;
        this.shared_library = shared_library;
        this.alias = alias;
        this.class = class;
        this.interfaces = interfaces;
        this.records = records;
        this.enums = enums;
        this.functions = functions;
        this.function_inlines = function_inlines;
        this.function_macros = function_macros;
        this.unions = unions;
        this.bit_fields = bit_fields;
        this.callbacks = callbacks;
        this.constants = constants;
        this.attributes = attributes;
        this.boxeds = boxeds;
        this.doc_sections = doc_sections;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_namespace (this);
    }

    public override void accept_children (GirVisitor visitor) {
        foreach (var alias in alias) {
            alias.accept (visitor);
        }

        foreach (var class in class) {
            class.accept (visitor);
        }

        foreach (var interface in interfaces) {
            interface.accept (visitor);
        }

        foreach (var record in records) {
            record.accept (visitor);
        }

        foreach (var enum in enums) {
            enum.accept (visitor);
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

        foreach (var bit_field in bit_fields) {
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
    }
}

