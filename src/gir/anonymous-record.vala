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

/**
 * Some gir files contain record definitions with unnamed nested records/unions.
 * This is annoying because records are otherwise guaranteed to have a name. To
 * resolve this issue, the AnonymousRecord type represents an unnamed record.
 */
public class Gir.AnonymousRecord : DocElements, Node {
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Vala.List<Field> fields { owned get; set; }
    public Vala.List<Union> unions { owned get; set; }

    public AnonymousRecord (
            DocVersion? doc_version,
            DocStability? doc_stability,
            Doc? doc,
            DocDeprecated? doc_deprecated,
            SourcePosition? source_position,
            Vala.List<Field> fields,
            Vala.List<Union> unions,
            Vala.SourceReference? source) {
        base(source);
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.fields = fields;
        this.unions = unions;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_anonymous_record (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_doc_elements (visitor);

        foreach (var union in unions) {
            union.accept (visitor);
        }

        foreach (var field in fields) {
            field.accept (visitor);
        }
    }
}
