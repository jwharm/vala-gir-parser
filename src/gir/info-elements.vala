/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
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

public interface Gir.InfoElements : Node, DocElements {
    public abstract Gee.List<Attribute> attributes { owned get; set; }

    public void accept_info_elements (Visitor visitor) {
        accept_doc_elements (visitor);
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }
    }

    internal void init_info_elements (InfoElementsParameters parameters) {
        init_doc_elements (parameters.doc_elements_parameters);
        this.attributes = parameters.attributes;
    }
}

public struct Gir.InfoElementsParameters {
    DocElementsParameters doc_elements_parameters;
    Gee.List<Attribute> attributes;
}
