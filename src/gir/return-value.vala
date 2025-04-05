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

public class Gir.ReturnValue : DocElements, Node {
    public bool introspectable { get; set; }
    public bool nullable { get; set; }
    public int closure { get; set; }
    public Scope scope { get; set; }
    public int destroy { get; set; }
    public bool skip { get; set; }
    public bool allow_none { get; set; }
    public TransferOwnership transfer_ownership { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Vala.List<Attribute> attributes { owned get; set; }
    public AnyType anytype { get; set; }

    public ReturnValue (
            bool introspectable,
            bool nullable,
            int closure,
            Scope scope,
            int destroy,
            bool skip,
            bool allow_none,
            TransferOwnership transfer_ownership,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Vala.List<Attribute> attributes,
            AnyType anytype,
            Vala.SourceReference? source) {
        base(source);
        this.introspectable = introspectable;
        this.nullable = nullable;
        this.closure = closure;
        this.scope = scope;
        this.destroy = destroy;
        this.skip = skip;
        this.allow_none = allow_none;
        this.transfer_ownership = transfer_ownership;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.anytype = anytype;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_return_value (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_doc_elements (visitor);
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        anytype.accept (visitor);
    }
}

