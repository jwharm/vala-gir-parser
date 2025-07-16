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

public class Gir.SourcePosition : Node {
    public string filename { owned get; set; }
    public string line { owned get; set; }
    public string? column { owned get; set; }

    public SourcePosition (
            string filename,
            string line,
            string? column,
            Gir.Xml.Reference? source) {
        base (source);
        this.filename = filename;
        this.line = line;
        this.column = column;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_source_position (this);
    }
}

