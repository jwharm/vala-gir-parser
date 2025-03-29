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

public class Gir.Enumeration : InfoAttrs, DocElements, InfoElements, Identifier, EnumBase, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string c_type { owned get; set; }
    public string? glib_type_name { owned get; set; }
    public string? glib_get_type { owned get; set; }
    public string? glib_error_domain { owned get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Vala.List<Attribute> attributes { owned get; set; }
    public Vala.List<Member> members { owned get; set; }
    public Vala.List<Function> functions { owned get; set; }
    public Vala.List<FunctionInline> function_inlines { owned get; set; }

    public Enumeration (
            bool introspectable,
            bool deprecated,
            string? deprecated_version,
            string? version,
            string? stability,
            string name,
            string c_type,
            string? glib_type_name,
            string? glib_get_type,
            string? glib_error_domain,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Vala.List<Attribute> attributes,
            Vala.List<Member> members,
            Vala.List<Function> functions,
            Vala.List<FunctionInline> function_inlines,
            Vala.SourceReference? source) {
        base(source);
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.name = name;
        this.c_type = c_type;
        this.glib_type_name = glib_type_name;
        this.glib_get_type = glib_get_type;
        this.glib_error_domain = glib_error_domain;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.members = members;
        this.functions = functions;
        this.function_inlines = function_inlines;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_enumeration (this);
    }

    public override void accept_children (Visitor visitor) {
        doc_version?.accept (visitor);
        doc_stability?.accept (visitor);
        doc?.accept (visitor);
        doc_deprecated?.accept (visitor);
        source_position?.accept (visitor);
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        foreach (var member in members) {
            member.accept (visitor);
        }

        foreach (var function in functions) {
            function.accept (visitor);
        }

        foreach (var function_inline in function_inlines) {
            function_inline.accept (visitor);
        }
    }
}

