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
 * Creates Gir <attribute> elements for Vala metadata arguments on the Gir nodes
 * that match the metadata rules.
 */
public class Gir.Metadata.Matcher {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; set; }

    /**
     * Create a new MetadataToGirAttrs
     * 
     * @param context the Gir Context
     */
    public Matcher (Gir.Context context) {
        this.context = context;
    }

    /**
     * Add the provided metadata rules as Gir <attribute> elements in the
     * matching nodes of the Gir repository.
     *
     * @param metadata a list of metadata rules
     * @param repository a Gir repository
     */
    public void create_gir_attributes (Gee.List<Rule> metadata, Repository repository) {
        foreach (Rule rule in metadata) {
            process_rule (repository.namespaces, rule);
        }
    }

    // Create Gir attributes for a metadata rule and all related rules
    private void process_rule (Gee.List<Gir.Node> nodes, Rule rule) {
        // Create a list of all matching gir nodes for this rule
        var matching_gir_nodes = match_rule (nodes, rule);

        // Log unused entries
        if (matching_gir_nodes.is_empty) {
            context.report.warn (rule.source_reference, "Rule does not match anything");
        }

        // Create gir <attribute> elements for the metadata arguments.
        // When the argument has no value, default to "1" (i.e. boolean "true").
        foreach (var arg in rule.args) {
            create_attributes (matching_gir_nodes, arg.key, arg.value ?? "1");
        }

        // Match relative rules against the matching gir nodes
        foreach (var relative_rule in rule.children) {
            process_rule (matching_gir_nodes, relative_rule);
        }
    }

    // Match a metadata pattern against the child nodes of the provided nodes
    private Gee.List<Gir.Node> match_rule (Gee.List<Gir.Node> nodes, Rule rule) {
        var result = new Gee.ArrayList<Gir.Node> ();
        foreach (var node in nodes) {
            node.accept_children (new ForeachVisitor (child => {
                // recursively descent into the <parameters> node
                if (child is Parameters) {
                    return ForeachResult.CONTINUE;
                }

                // when this rule matches the gir element, add it to the list
                if (rule.matches (child)) {
                    result.add (child);
                }

                return ForeachResult.SKIP;
            }));
        }
        
        return result;
    }

    // Create a gir <attribute> element in the provided gir nodes
    private void create_attributes (Gee.List<Gir.Node> nodes, string key, string? val) {
        foreach (var node in nodes) {
            if (node is InfoElements) {
                var info_elements = (InfoElements) node;
                info_elements.attributes.add (new Attribute (key, val, null));
            } else if (node is Parameter) {
                var parameter = (Parameter) node;
                parameter.attributes.add (new Attribute (key, val, null));
            }
        }
    }
}
