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

public class Gir.TypeRef : DocElements, AnyType {
    public override string? name { owned get; set; }
    public string? c_type { owned get; set; }
    public bool introspectable { get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<AnyType> anytypes { owned get; set; }

    public TypeRef (
            string? name,
            string? c_type,
            bool introspectable,
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Gee.List<AnyType> anytypes,
            Gir.Xml.Reference? source) {
        base(source);
        this.name = name;
        this.c_type = c_type;
        this.introspectable = introspectable;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.anytypes = anytypes;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_type (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_doc_elements (visitor);
        foreach (var anytype in anytypes) {
            anytype.accept (visitor);
        }
    }
}

