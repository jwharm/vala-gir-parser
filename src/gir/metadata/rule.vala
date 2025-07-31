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
 * Represents a metadata rule: a glob pattern, an optional selector, zero or
 * more arguments, and zero or more nested (relative) rules. A rule can be
 * matched against a Gir node.
 *
 * Vala metadata globs and selectors match Gir element names and tags, except
 * in metadata, underscores are used instead of dashes.
 */
public class Gir.Metadata.Rule {
    public string glob;
    public PatternSpec pattern_spec;
    public string? selector;
    public Gee.Map<string, string?> args;
    public Gee.List<Rule> children;
    public Gir.Xml.Reference source_reference;

    public Rule (string pattern, string? selector,
            Gee.Map<string, string?> args, Gee.List<Rule> children,
            Gir.Xml.Reference source_reference) {
        this.glob = pattern;
        this.pattern_spec = new PatternSpec (pattern);
        this.selector = selector;
        this.args = args;
        this.children = children;
        this.source_reference = source_reference;
    }

    public bool matches (Gir.Node node) {
        /* node type matches selector? */
        if (selector != null) {
            if (selector != node.tag_name ().replace ("-", "_")) {
                return false;
            }
        }

        /* match all nodes? */
        if (glob == "*") {
            return true;
        }

        /* node name matches pattern? */
        string? name = null;
        if (node is Named) {
            name = ((Named) node).name;
        } else if (node is Parameter) {
            name = ((Parameter) node).name;
        }

        return name != null && pattern_spec.match_string (name.replace ("-", "_"));
    }

    /**
     * Return a string representation of this metadata rule and all relative rules.
     */
    public string to_string () {
        return to_string_indented (0);
    }

    private string to_string_indented (int indent) {
        var sb = new StringBuilder (glob);

        if (selector != null) {
            sb.append ("#").append (selector);
        }

        // Only one relative rule: Append it on the same line
        if (args.is_empty && children.size == 1) {
            return sb.append (".")
                     .append (children[0].to_string ())
                     .str;
        }

        // Append arguments
        foreach (var arg in args) {
            sb.append (" ").append (arg.key);
            if (arg.value != null) {
                sb.append ("=").append (arg.value);
            }
        }

        sb.append ("\n");

        // Recursively add the relative rules on new lines
        foreach (var rule in children) {
            sb.append (string.nfill (indent, ' '))
              .append (".")
              .append (rule.to_string_indented (indent + 2));
        }

        return sb.str;
    }
}
