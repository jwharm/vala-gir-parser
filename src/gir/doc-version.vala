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

public class Gir.DocVersion : Node {
    public bool xml_space_preserve      { get; set; }
    public bool xml_whitespace_preserve { get; set; }
    public string? text                 { owned get; set; }

    public DocVersion (bool xml_space_preserve, bool xml_whitespace_preserve, string? text) {
        this.xml_space_preserve = xml_space_preserve;
        this.xml_whitespace_preserve = xml_whitespace_preserve;
        this.text = text;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_doc_version (this);
    }
}
