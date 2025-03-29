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

public class Gir.Function : InfoAttrs, DocElements, InfoElements, Callable, Node, CallableAttrs {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string? c_identifier { owned get; set; }
    public string? shadowed_by { owned get; set; }
    public string? shadows { owned get; set; }
    public bool @throws { get; set; }
    public string? moved_to { owned get; set; }
    public string? glib_async_func { owned get; set; }
    public string? glib_sync_func { owned get; set; }
    public string? glib_finish_func { owned get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Vala.List<Attribute> attributes { owned get; set; }
    public Parameters? parameters { get; set; }
    public ReturnValue? return_value { get; set; }

    public Function (
            bool introspectable,
            bool deprecated,
            string? deprecated_version,
            string? version,
            string? stability,
            string name,
            string? c_identifier,
            string? shadowed_by,
            string? shadows,
            bool @throws,
            string? moved_to,
            string? glib_async_func,
            string? glib_sync_func,
            string? glib_finish_func,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Vala.List<Attribute> attributes,
            Parameters? parameters,
            ReturnValue? return_value,
            Vala.SourceReference? source) {
        base(source);
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.name = name;
        this.c_identifier = c_identifier;
        this.shadowed_by = shadowed_by;
        this.shadows = shadows;
        this.throws = @throws;
        this.moved_to = moved_to;
        this.glib_async_func = glib_async_func;
        this.glib_sync_func = glib_sync_func;
        this.glib_finish_func = glib_finish_func;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.parameters = parameters;
        this.return_value = return_value;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_function (this);
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

        parameters?.accept (visitor);
        return_value?.accept (visitor);
    }
}

