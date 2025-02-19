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

public class Gir.InstanceParameter : DocElements, Node {
    public string name { owned get; set; }
    public bool nullable { get; set; }
    public bool allow_none { get; set; }
    public Direction direction { get; set; }
    public bool caller_allocates { get; set; }
    public TransferOwnership transfer_ownership { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public TypeRef type_ref { get; set; }

    public InstanceParameter (
            string name,
            bool nullable,
            bool allow_none,
            Direction direction,
            bool caller_allocates,
            TransferOwnership transfer_ownership,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            TypeRef type_ref) {
        this.name = name;
        this.nullable = nullable;
        this.allow_none = allow_none;
        this.direction = direction;
        this.caller_allocates = caller_allocates;
        this.transfer_ownership = transfer_ownership;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.type_ref = type_ref;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_instance_parameter (this);
    }

    public override void accept_children (GirVisitor visitor) {
        doc_version?.accept (visitor);
        doc_stability?.accept (visitor);
        doc?.accept (visitor);
        doc_deprecated?.accept (visitor);
        source_position?.accept (visitor);
        type_ref.accept (visitor);
    }
}

