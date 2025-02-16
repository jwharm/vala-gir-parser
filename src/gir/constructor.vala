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

public class Gir.Constructor : Node, DocElements, InfoElements, InfoAttrs, CallableAttrs, Callable {
    public override string name                     { owned get; set; }
    public override bool introspectable             { get; set; }
    public override bool deprecated                 { get; set; }
    public override string deprecated_version       { owned get; set; }
    public override string version                  { owned get; set; }
    public override Stability stability             { get; set; }
    public override DocVersion? doc_version         { owned get; set; }
    public override DocStability? doc_stability     { owned get; set; }
    public override Doc? doc                        { owned get; set; }
    public override DocDeprecated? doc_deprecated   { owned get; set; }
    public override SourcePosition? source_position { owned get; set; }
    public override Vala.List<Attribute> attributes { owned get; set; }
    public override string? c_identifier            { owned get; set; }
    public override string? shadowed_by             { owned get; set; }
    public override string? shadows                 { owned get; set; }
    public override bool @throws                    { get; set; }
    public override string? moved_to                { owned get; set; }
    public override string? glib_async_func         { owned get; set; }
    public override string? glib_finish_func        { owned get; set; }
    public override Parameters? parameters          { owned get; set; }
    public override ReturnValue? return_value       { owned get; set; }

    public Constructor (string name, bool introspectable, bool deprecated,
                        string deprecated_version, string version, Stability stability,
                        DocVersion? doc_version, DocStability? doc_stability, Doc? doc,
                        DocDeprecated? doc_deprecated, SourcePosition? source_position,
                        Vala.List<Attribute> attributes, string? c_identifier,
                        string? shadowed_by, string? shadows, bool @throws,
                        string? moved_to, string? glib_async_func,
                        string? glib_finish_func, Parameters? parameters,
                        ReturnValue? return_value) {
        this.name = name;
        this.introspectable = introspectable;
        this.deprecated = deprecated;
        this.deprecated_version = deprecated_version;
        this.version = version;
        this.stability = stability;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.c_identifier = c_identifier;
        this.shadowed_by = shadowed_by;
        this.shadows = shadows;
        this.throws = @throws;
        this.moved_to = moved_to;
        this.glib_async_func = glib_async_func;
        this.glib_finish_func = glib_finish_func;
        this.parameters = parameters;
        this.return_value = return_value;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_constructor (this);
    }

    public override void accept_children (GirVisitor visitor) {
        doc_version.accept (visitor);
        doc_stability.accept (visitor);
        doc.accept (visitor);
        doc_deprecated.accept (visitor);
        source_position.accept (visitor);
        
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        parameters.accept (visitor);
        return_value.accept (visitor);
    }
}
