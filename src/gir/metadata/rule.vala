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
 * Represents a metadata rule (a glob pattern + an optional selector) that can
 * be matched against a Gir node.
 */
public class Gir.Metadata.Rule {
    private string pattern;
    private PatternSpec pattern_spec;
    private string? selector;

    public Rule (string pattern, string? selector) {
        this.pattern = pattern;
        this.pattern_spec = new PatternSpec (pattern);
        this.selector = selector;
    }

    public bool matches (Gir.Node node) {
        /* node type matches selector? */
        if (selector != null) {
            /* vala metadata selectors match Gir element tags, except they
             * use underscores instead of dashes */
            string tag_name = node.tag_name ().replace ("-", "_");
            if (selector != tag_name) {
                return false;
            }
        }

        /* match all nodes? */
        if (pattern == "*") {
            return true;
        }

        /* node name matches pattern? */
        string? name = null;
        if (node is Named) {
            name = ((Named) node).name;
        } else if (node is Parameter) {
            name = ((Parameter) node).name;
        }

        return name != null && pattern_spec.match_string (name);
    }
}
