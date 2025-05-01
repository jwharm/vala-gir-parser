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

public interface Gir.InfoElements : Node {
    protected abstract InfoElementsValues info_elements_values { get; set; }

    public DocVersion? doc_version {
        get { return info_elements_values.doc_elements_values.doc_version; }
        set { info_elements_values.doc_elements_values.doc_version = value; }
    }

    public DocStability? doc_stability {
        get { return info_elements_values.doc_elements_values.doc_stability; }
        set { info_elements_values.doc_elements_values.doc_stability = value; }
    }

    public Doc? doc {
        get { return info_elements_values.doc_elements_values.doc; }
        set { info_elements_values.doc_elements_values.doc = value; }
    }

    public DocDeprecated? doc_deprecated {
        get { return info_elements_values.doc_elements_values.doc_deprecated; }
        set { info_elements_values.doc_elements_values.doc_deprecated = value; }
    }

    public SourcePosition? source_position {
        get { return info_elements_values.doc_elements_values.source_position; }
        set { info_elements_values.doc_elements_values.source_position = value; }
    }

    public Gee.List<Attribute> attributes {
        owned get { return info_elements_values.attributes; }
        set { info_elements_values.attributes = value; }
    }

    public void accept_info_elements (Visitor visitor) {
        doc_version?.accept (visitor);
        doc_stability?.accept (visitor);
        doc?.accept (visitor);
        doc_deprecated?.accept (visitor);
        source_position?.accept (visitor);
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }
    }
}

public struct Gir.InfoElementsValues {
    DocElementsValues doc_elements_values;
    Gee.List<Attribute> attributes;
}
