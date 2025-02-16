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

public class Gir.InstanceParameter : Node, DocElements {
    public string name                              { owned get; set; }
    public override DocVersion? doc_version         { owned get; set; }
    public override DocStability? doc_stability     { owned get; set; }
    public override Doc? doc                        { owned get; set; }
    public override DocDeprecated? doc_deprecated   { owned get; set; }
    public override SourcePosition? source_position { owned get; set; }
    public bool nullable                            { get; set; }
    public bool allow_none                          { get; set; }
    public Direction direction                      { get; set; }
    public bool caller_allocates                    { get; set; }
    public TransferOwnership transfer_ownership     { get; set; }
    public TypeRef type_ref                         { owned get; set; }

    public InstanceParameter (string name, DocVersion? doc_version, DocStability? doc_stability,
                              Doc? doc, DocDeprecated? doc_deprecated, SourcePosition? source_position,
                              bool nullable, bool allow_none, Direction direction, bool caller_allocates,
                              TransferOwnership transfer_ownership, TypeRef type_ref) {
        this.name = name;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.nullable = nullable;
        this.allow_none = allow_none;
        this.direction = direction;
        this.caller_allocates = caller_allocates;
        this.transfer_ownership = transfer_ownership;
        this.type_ref = type_ref;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_instance_parameter (this);
    }

    public override void accept_children (GirVisitor visitor) {
        doc_version.accept (visitor);
        doc_stability.accept (visitor);
        doc.accept (visitor);
        doc_deprecated.accept (visitor);
        source_position.accept (visitor);
        type_ref.accept (visitor);
    }
}
