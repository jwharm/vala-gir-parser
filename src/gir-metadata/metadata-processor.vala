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

using Vala;

public class GirMetadata.MetadataProcessor : CodeVisitor {

    private Vala.List<Metadata> metadata_stack = new ArrayList<Metadata> ();
    private Metadata metadata = Metadata.empty;
    private string ns_name;

    public MetadataProcessor (Metadata metadata, string ns_name) {
        this.metadata_stack.add (metadata);
        this.ns_name = ns_name;
    }

    public void apply (CodeContext context) {
        context.accept (this);
    }

    public override void visit_namespace (Vala.Namespace ns) {
        if (ns.name == null || ns.name == ns_name) {
            ns.accept_children (this);
        }
    }

    public override void visit_class (Vala.Class cl) {
        if (push_metadata (cl.name, "class")) {
            cl.accept_children (this);
            pop_metadata ();
        }
    }

    public override void visit_method (Vala.Method m) {
        if (push_metadata (m.name, "method")) {
			m.set_attribute ("PrintfFormat", metadata.get_bool (PRINTF_FORMAT));
            pop_metadata ();
        }
    }

	private Metadata get_current_metadata (string name, string selector) {
		/* Give a transparent union the generic name "union" */
		if (selector == "union" && name == null) {
			name = "union";
		}

		if (name == null) {
			return Metadata.empty;
		}
		
        var child_selector = selector.replace ("-", "_");
		var child_name = name.replace ("-", "_");
		return metadata.match_child (child_name, child_selector);
	}

	private bool push_metadata (string name, string selector) {
		var new_metadata = get_current_metadata (name, selector);
		/* skip ? */
		if (new_metadata.has_argument (SKIP)) {
			if (new_metadata.get_bool (SKIP)) {
				return false;
			}
		}

		metadata_stack.add (metadata);
		metadata = new_metadata;
		return true;
	}

	private void pop_metadata () {
		metadata = metadata_stack.remove_at (metadata_stack.size - 1);
	}
}
