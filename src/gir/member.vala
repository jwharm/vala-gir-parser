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

public class Gir.Member : Node, InfoAttrs, DocElements, InfoElements {
    public string name { owned get; set; }
    public override bool introspectable               { get; set; }
    public override bool deprecated                   { get; set; }
    public override string deprecated_version         { owned get; set; }
    public override string version                    { owned get; set; }
    public override Stability stability               { get; set; }
    public override DocVersion? doc_version           { owned get; set; }
    public override DocStability? doc_stability       { owned get; set; }
    public override Doc? doc                          { owned get; set; }
    public override DocDeprecated? doc_deprecated     { owned get; set; }
    public override SourcePosition? source_position   { owned get; set; }
    public override Vala.List<Attribute> attributes   { owned get; set; }
    public string value                               { owned get; set; }
    public string? c_identifier                       { owned get; set; }
    public string? glib_nick                          { owned get; set; }
    public string? glib_name                          { owned get; set; }

    public Member (string name, bool introspectable, bool deprecated,
                   string deprecated_version, string version, Stability stability,
                   DocVersion? doc_version, DocStability? doc_stability, Doc? doc,
                   DocDeprecated? doc_deprecated, SourcePosition? source_position,
                   Vala.List<Attribute> attributes, string value, string? c_identifier,
                   string? glib_nick, string? glib_name) {
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
        this.value = value;
        this.c_identifier = c_identifier;
        this.glib_nick = glib_nick;
        this.glib_name = glib_name;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_member (this);
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

    }
}
