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

public class GirMetadata.MetadataProcessor {

    private Vala.List<Metadata> metadata_stack = new ArrayList<Metadata> ();
    private Gir.Node repository;

    public MetadataProcessor (Gir.Node repository) {
        this.repository = repository;
    }

    public void apply (Metadata metadata) {
        metadata_stack.add (metadata);
        process_node (ref repository);
        metadata_stack.clear ();
    }

    private void process_node (ref Gir.Node node) {
        string[] relevant_types = {
            "alias", "bitfield", "glib:boxed", "callback", "constructor",
            "class", "enumeration", "function", "instance-parameter",
            "interface", "method", "namespace", "parameter", "record",
            "glib:signal", "union", "virtual-method"
        };
        
        if (node.tag in relevant_types) {
            push_metadata (node.get_string ("name"), node.tag);
            apply_metadata (ref node, node.tag);
        }

        if (node.tag == "namespace") {
            pop_metadata ();
        }

        /* no need to process child nodes when the parent node is skipped */
        if (node.get_bool ("introspectable", true)) {
            foreach (var child_node in node.children) {
                process_node (ref child_node);
            }
        }
        
        if (node.tag in relevant_types) {
            pop_metadata ();
        }
    }

    /* Apply metadata rules to this gir node. The changes are applied in-place,
     * destructively. It is possible that the node is completely replaced by
     * another node (possibly with another type) or moved to another location in
     * the tree. */
    private void apply_metadata (ref Gir.Node node, string tag) {
        var metadata = peek_metadata ();
        var source = metadata.source_reference;

        if (metadata.has_argument (SKIP)) {
            node.set_bool ("introspectable", ! metadata.get_bool (SKIP));
        }

        if (metadata.has_argument (HIDDEN)) {
            /* Unsure what to do with this; treat the same as 'skip' */
            node.set_bool ("introspectable", ! metadata.get_bool (HIDDEN));
        }

        if (metadata.has_argument (NEW)) {
            node.set_bool ("hides", metadata.get_bool (NEW));
        }

        if (metadata.has_argument (TYPE)) {
            node.remove ("type", "array");
            var type_node = Gir.Node.create ("type", source,
                "name", metadata.get_string (TYPE),
                "expression", "1");
            node.add (type_node);
        }

        if (metadata.has_argument (TYPE_ARGUMENTS)) {
            var current_type = node.any_of ("type", "array");
            if (current_type == null && node.has_any ("return-value")) {
                current_type = node.any_of ("return-value")
                                   .any_of ("type", "array");
            }

            if (current_type == null) {
                Report.error (source, "Cannot set type arguments of %s", tag);
            } else {
                string type_args = metadata.get_string (TYPE_ARGUMENTS);
                foreach (var type_arg in type_args.split (",")) {
                    var type_node = Gir.Node.create ("type", source,
                        "name", type_arg,
                        "expression", "1");
                    current_type.add (type_node);
                }
            }
        }

        if (metadata.has_argument (CHEADER_FILENAME) && node.tag == "namespace") {
            var repo = node.parent_node;
            repo.remove ("c:include");

            var headers = metadata.get_string (CHEADER_FILENAME);
            foreach (var c_include in headers.split (",")) {
                var c_incl_node = Gir.Node.create ("c:include", source,
                    "name", c_include);
                repo.add (c_incl_node);
            }
        }

        if (metadata.has_argument (NAME)) {
            var pattern = metadata.get_string (ArgumentType.NAME);
            var name = node.get_string ("name");
            if (pattern != null) {
                replace_name_with_pattern(ref name, pattern);
                node.set_string ("name", name);
            }
        }

        if (metadata.has_argument (OWNED)) {
            if (node.tag == "parameter") {
                node.set_string ("transfer-ownership", "full");
            } else if (node.has_any ("return-value")) {
                node.any_of ("return-value")
                    .set_string ("transfer-ownership", "full");
            }
        }

        if (metadata.has_argument (UNOWNED)) {
            if (node.tag == "parameter") {
                node.set_string ("transfer-ownership", "none");
            } else if (node.has_any ("return-value")) {
                node.any_of ("return-value")
                    .set_string ("transfer-ownership", "none");
            }
        }

        if (metadata.has_argument (PARENT)) {
            var path = metadata.get_string (PARENT);
            var location = find_or_create_gir_node (path, source);
            node.parent_node.children.remove (node);
            location.add (node);
        }

        if (metadata.has_argument (NULLABLE)) {
            var nullable = metadata.get_bool (NULLABLE);
            if (node.tag == "parameter") {
                node.set_bool ("nullable", nullable);
            } else if (node.has_any ("return-value")) {
                node.any_of ("return-value")
                    .set_bool ("nullable", nullable);
            }
        }

        if (metadata.has_argument (DEPRECATED)) {
            var deprecated = metadata.get_bool (DEPRECATED);
            node.set_bool ("deprecated", deprecated);
        }

        if (metadata.has_argument (REPLACEMENT)) {
            var replacement = metadata.get_string (REPLACEMENT);
            node.set_string ("moved-to", replacement);
        }
        
        if (metadata.has_argument (DEPRECATED_SINCE)) {
            var deprecated_since = metadata.get_string (DEPRECATED_SINCE);
            node.set_string ("deprecated-version", deprecated_since);
        }

        if (metadata.has_argument (SINCE)) {
            node.set_string ("version", metadata.get_string (SINCE));
        }

        if (metadata.has_argument (ARRAY)) {
            var current_type = node.any_of ("type", "array");
            if (current_type == null && node.has_any ("return-value")) {
                current_type = node.any_of ("return-value")
                                   .any_of ("type", "array");
            }

            var array = Gir.Node.create ("array", source);
            array.add (current_type);

            var parent = current_type.parent_node;
            parent.remove ("type", "array");
            parent.add (array);
        }

        if (metadata.has_argument (ARRAY_LENGTH_IDX)) {
            var array = node.any_of ("array");
            if (array == null && node.has_any ("return-value")) {
                array = node.any_of ("return-value").any_of ("array");
            }

            if (array == null) {
                Report.error (source, "Cannot set array_length_idx on %s", tag);
            } else {
                var array_length_idx = metadata.get_integer (ARRAY_LENGTH_IDX);
                array.set_int ("length", array_length_idx);
            }
        }

        if (metadata.has_argument (ARRAY_NULL_TERMINATED)) {
            var array = node.any_of ("array");
            if (array == null && node.has_any ("return-value")) {
                array = node.any_of ("return-value").any_of ("array");
            }

            if (array == null) {
                Report.error (source, "Cannot set array_null_terminated on %s", tag);
            } else {
                var null_terminated = metadata.get_bool (ARRAY_NULL_TERMINATED);
                array.set_bool ("zero-terminated", null_terminated);
            }
        }

        if (metadata.has_argument (DEFAULT) && node.tag == "parameter") {
            /* TODO: parse expression from string after building the Vala AST */
            node.set_string ("default", metadata.get_string (DEFAULT));
        }

        if (metadata.has_argument (OUT)) {
            var is_out = metadata.get_bool (OUT);
            node.set_string ("direction", is_out ? "out" : "in");
        }

        if (metadata.has_argument (REF)) {
            var is_ref = metadata.get_bool (REF);
            node.set_string ("direction", is_ref ? "inout" : "in");
        }

        if (metadata.has_argument (VFUNC_NAME)) {
            string vm_name = metadata.get_string (VFUNC_NAME);
            string invoker_name = node.get_string ("name");
            bool found = false;
            foreach (var vm in node.parent_node.all_of ("virtual-method")) {
                if (vm.get_string ("name") == vm_name) {
                    vm.set_string ("invoker", invoker_name);
                    found = true;
                    break;
                }
            }

            if (! found) {
                Report.error (source, "Cannot find vfunc named '%s'", vm_name);
            }
        }

        if (metadata.has_argument (VIRTUAL)) {
            node.set_bool ("virtual", metadata.get_bool (VIRTUAL));
        }

        if (metadata.has_argument (ABSTRACT)) {
            node.set_bool ("abstract", metadata.get_bool (ABSTRACT));
        }

        if (metadata.has_argument (COMPACT)) {
            node.set_bool ("compact", metadata.has_argument (COMPACT));
        }

        if (metadata.has_argument (SEALED)) {
            node.set_bool ("final", metadata.has_argument (SEALED));
        }

        if (metadata.has_argument (SCOPE)) {
            node.set_string ("scope", metadata.get_string (SCOPE));
        }

        if (metadata.has_argument (STRUCT)) {
            node.set_bool ("struct", metadata.get_bool (STRUCT));
        }

        if (metadata.has_argument (THROWS)) {
            node.set_bool ("throws", metadata.get_bool (THROWS));
        }

        if (metadata.has_argument (PRINTF_FORMAT)) {
            var printf_format = metadata.get_bool (PRINTF_FORMAT);
            node.set_bool ("printf-format", printf_format);
        }

        if (metadata.has_argument (ARRAY_LENGTH_FIELD)) {
            var field_name = metadata.get_string (ARRAY_LENGTH_FIELD);
            var array = node.any_of ("array");
            if (array == null) {
                Report.error (source, "Cannot set array length field on %s", tag);
            } else {
                var fields = node.parent_node.all_of ("field");
                bool found = false;
                for (int i = 0; i < fields.size; i++) {
                    if (fields[i].get_string ("name") == field_name) {
                        array.set_int ("length", i);
                        found = true;
                        break;
                    }
                }

                if (! found) {
                    Report.error (source, "Cannot find field named '%s'", field_name);
                }
            }
        }

        if (metadata.has_argument (SENTINEL)) {
            node.set_bool ("sentinel", metadata.get_bool (SENTINEL));
        }

        if (metadata.has_argument (CLOSURE)) {
            var closure = metadata.get_integer (CLOSURE);
            if (node.has_any ("return-value")) {
                node.any_of ("return-value").set_int ("closure", closure);
            } else {
                node.set_int ("closure", closure);
            }
        }

        if (metadata.has_argument (DESTROY)) {
            var destroy = metadata.get_integer (DESTROY);
            if (node.has_any ("return-value")) {
                node.any_of ("return-value").set_int ("destroy", destroy);
            } else {
                node.set_int ("destroy", destroy);
            }
        }

        if (metadata.has_argument (ERRORDOMAIN)) {
            /* the value of this attribute isn't actually used, so put a dummy
             * value in it */
            node.set_string ("glib:error-domain", "DUMMY");
        }

        if (metadata.has_argument (DESTROYS_INSTANCE) && node.tag == "method") {
            /* a method destroys its instance when ownership is transferred to
             * the instance parameter */
            node.any_of ("parameters")
                .any_of ("instance-parameter")
                .set_string ("transfer-ownership", "full");
        }

        if (metadata.has_argument (BASE_TYPE) && node.tag == "glib:boxed") {
            node.set_string ("parent", metadata.get_string (BASE_TYPE));
        }

        if (metadata.has_argument (FINISH_NAME)) {
            var finish_name = metadata.get_string (FINISH_NAME);
            node.set_string ("glib:finish-func", finish_name);
        }

        if (metadata.has_argument (FINISH_INSTANCE)) {
            var finish_instance = metadata.get_string (FINISH_INSTANCE);
            node.set_string ("glib:finish-instance", finish_instance);
        }
    }

    /* helper function for processing the NAME metadata attribute */
    private void replace_name_with_pattern (ref string name, string pattern) {
        if (pattern.index_of_char ('(') < 0) {
            /* shortcut for "(.+)/replacement" */
            name = pattern;
        } else {
            try {
                /* replace the whole name with the match by default */
                string replacement = "\\1";
                var split = pattern.split ("/");
                if (split.length > 1) {
                    pattern = split[0];
                    replacement = split[1];
                }
                var regex = new Regex (pattern, ANCHORED, ANCHORED);
                name = regex.replace (name, -1, 0, replacement);
            } catch (Error e) {
                name = pattern;
            }
        }
    }

    /* Find the node with the requested path down the gir tree. If not found, a
     * new namespace is created for the remaining part of the path. */
    private Gir.Node find_or_create_gir_node (string path,
                                              SourceReference? source) {
        Gir.Node current_node = repository;
        foreach (string name in path.split(".")) {
            if (! move_down_gir_tree (ref current_node, name)) {
                var new_ns = Gir.Node.create ("namespace", source, "name", name);
                current_node.add (new_ns);
                current_node = new_ns;
            }
        }

        return current_node;
    }

    /* Replace `current_node` with a child node with the requested name, if it
     * is a namespace or type identifier (class, interface, record etc). */
    private bool move_down_gir_tree (ref Gir.Node current_node, string name) {
        string[] relevant_types = {
            "alias", "bitfield", "glib:boxed", "callback", "class",
            "enumeration", "interface", "namespace", "record", "union"
        };

        foreach (var child in current_node.children) {
            if (child.tag in relevant_types
                    && (child.get_string ("name") == name)) {
                current_node = child;
                return true;
            }
        }

        return false;
    }

	private void push_metadata (string? name, string tag) {
		metadata_stack.add (get_current_metadata (name, tag));
	}

    private Metadata peek_metadata () {
        return metadata_stack.last ();
    }

	private void pop_metadata () {
		metadata_stack.remove_at (metadata_stack.size - 1);
	}

	private Metadata get_current_metadata (string? name, string tag) {
        var selector = tag.replace ("glib:", "");

		/* Give a transparent union the generic name "union" */
		if (selector == "union" && name == null) {
			name = "union";
		}

		if (name == null) {
			return Metadata.empty;
		}
		
        var child_selector = selector.replace ("-", "_");
		var child_name = name.replace ("-", "_");
        var result = peek_metadata ().match_child (child_name, child_selector);
		return result;
	}
}
