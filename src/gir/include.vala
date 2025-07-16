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

public class Gir.Include : Node, Named {
    public string name { owned get; set; }
    public string? version { owned get; set; }
    public Link<Repository> repository {owned get; set; }

    public Include (string name, string? version, Gir.Xml.Reference? source) {
        base (source);
        this.name = name;
        this.version = version;
        this.repository = new Link<Repository> (name + "-" + version);
    }

    public override void accept (Visitor visitor) {
        visitor.visit_include (this);
    }
}

