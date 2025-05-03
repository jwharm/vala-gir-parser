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

 public interface Gir.DocElements : Node {
    public abstract DocVersion? doc_version         { get; set; }
    public abstract DocStability? doc_stability     { get; set; }
    public abstract Doc? doc                        { get; set; }
    public abstract DocDeprecated? doc_deprecated   { get; set; }
    public abstract SourcePosition? source_position { get; set; }

    public void accept_doc_elements (Visitor visitor) {
        doc_version?.accept (visitor);
        doc_stability?.accept (visitor);
        doc?.accept (visitor);
        doc_deprecated?.accept (visitor);
        source_position?.accept (visitor);
    }

    internal void init_doc_elements (DocElementsParameters parameters) {
        this.doc_version = parameters.doc_version;
        this.doc_stability = parameters.doc_stability;
        this.doc = parameters.doc;
        this.doc_deprecated = parameters.doc_deprecated;
        this.source_position = parameters.source_position;
    }
}

public struct Gir.DocElementsParameters {
    DocVersion? doc_version;
    DocStability? doc_stability;
    Doc? doc;
    DocDeprecated? doc_deprecated;
    SourcePosition? source_position;
}
