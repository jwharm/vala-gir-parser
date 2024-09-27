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

    public MetadataProcessor (Gir.Repository repository) {
        this.repository = repository;
    }

    public void apply (Metadata metadata) {
        metadata_stack.add (metadata);
        process_node (ref repository);
        metadata_stack.clear ();
    }

    private void process_node (ref Gir.Node node) {
        var tag = Gir.Node.type_to_element_name (node.get_type ());
        var relevant = node is Gir.Namespace
                    || node is Gir.Identifier
                    || node is Gir.Callable
                    || node is Gir.InstanceParameter
                    || node is Gir.Parameter;
        
        if (relevant) {
            push_metadata (node.attrs["name"], tag);
            apply_metadata (ref node, tag);
        }

        if (node is Gir.Namespace) {
            pop_metadata ();
        }

        /* no need to process child nodes when the parent node is skipped */
        if (node.attr_get_bool ("introspectable", true)) {
            foreach (var child_node in node.children) {
                process_node (ref child_node);
            }
        }
        
        if (relevant) {
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
            if (node is Gir.Identifier || node is Gir.Callable) {
                node.attr_set_bool ("introspectable", ! metadata.get_bool (SKIP));
            }
        }

        if (metadata.has_argument (HIDDEN)) {
            if (node is Gir.Identifier || node is Gir.Callable) {
                /* Unsure what to do with this; treat the same as 'skip' */
                node.attr_set_bool ("introspectable", ! metadata.get_bool (HIDDEN));
            }
        }

        if (metadata.has_argument (TYPE)) {
            if (node is Gir.Parameter || node is Gir.Callable) {
                node.remove<Gir.AnyType> ();
                var type_node = Gir.Node.create<Gir.TypeRef> (source,
                    "name", metadata.get_string (TYPE),
                    "expression", "1",
                    null);
                node.add (type_node);
            }
        }

        if (metadata.has_argument (TYPE_ARGUMENTS)) {
            if (node is Gir.Parameter || node is Gir.Callable) {
                string type_args = metadata.get_string (TYPE_ARGUMENTS);
                var current_type = (node is Gir.Callable)
                        ? ((Gir.Callable) node).return_value.anytype
                        : node.any_of<Gir.AnyType> ();
    
                if (current_type == null) {
                    Report.error (source, "Cannot set type arguments of %s", tag);
                } else {
                    foreach (var type_arg in type_args.split (",")) {
                        var type_node = Gir.Node.create<Gir.TypeRef> (source,
                            "name", type_arg, "expression", "1", null);
                        current_type.add (type_node);
                    }
                }
            }
        }

        if (metadata.has_argument (CHEADER_FILENAME) && node is Gir.Namespace) {
            var repo = (Gir.Repository) node.parent_node;
            repo.c_includes.clear ();

            var headers = metadata.get_string (CHEADER_FILENAME);
            foreach (var c_include in headers.split (",")) {
                var c_incl_node = Gir.Node.create<Gir.CInclude> (source,
                    "name", c_include, null);
                repo.add (c_incl_node);
            }
        }

        if (metadata.has_argument (NAME)) {
            var pattern = metadata.get_string (ArgumentType.NAME);
            var name = node.attrs["name"];
            if (pattern != null) {
                replace_name_with_pattern(ref name, pattern);
                node.attrs["name"] = name;
            }
        }

        if (metadata.has_argument (OWNED)) {
            if (node is Gir.Parameter) {
                ((Gir.Parameter) node).transfer_ownership = FULL;
            } else if (node is Gir.Callable) {
                ((Gir.Callable) node).return_value.transfer_ownership = FULL;
            }
        }

        if (metadata.has_argument (UNOWNED)) {
            if (node is Gir.Parameter) {
                ((Gir.Parameter) node).transfer_ownership = NONE;
            } else if (node is Gir.Callable) {
                ((Gir.Callable) node).return_value.transfer_ownership = NONE;
            }
        }

        if (metadata.has_argument (PARENT)) {
            if (node is Gir.Identifier) {
                var path = metadata.get_string (PARENT);
                var location = find_or_create_gir_node (path, source);
                node.parent_node.children.remove (node);
                location.add (node);
            }
        }

        if (metadata.has_argument (NULLABLE)) {
            var nullable = metadata.get_bool (NULLABLE);
            if (node is Gir.Parameter) {
                ((Gir.Parameter) node).nullable = nullable;
            } else if (node is Gir.Callable) {
                ((Gir.Callable) node).return_value.nullable = nullable;
            }
        }

        if (metadata.has_argument (DEPRECATED)) {
            var deprecated = metadata.get_bool (DEPRECATED);
            if (node is Gir.Identifier) {
                ((Gir.Identifier) node).deprecated = deprecated;
            } else if (node is Gir.Callable) {
                ((Gir.Callable) node).deprecated = deprecated;
            }
        }

        if (metadata.has_argument (REPLACEMENT) && node is Gir.CallableAttrs) {
            var replacement = metadata.get_string (REPLACEMENT);
            ((Gir.CallableAttrs) node).moved_to = replacement;
        }
        
        if (metadata.has_argument (DEPRECATED_SINCE)) {
            var deprecated_since = metadata.get_string (DEPRECATED_SINCE);
            if (node is Gir.Identifier) {
                ((Gir.Identifier) node).deprecated_version = deprecated_since;
            } else if (node is Gir.Callable) {
                ((Gir.Callable) node).deprecated_version = deprecated_since;
            }
        }

        if (metadata.has_argument (ARRAY)) {
            if (node is Gir.Parameter || node is Gir.Callable) {
                var anytype = (node is Gir.Callable)
                    ? ((Gir.Callable) node).return_value.anytype
                    : node.any_of<Gir.AnyType> ();

                var array = Gir.Node.create<Gir.Array> (source, null);
                array.add (anytype);
                node.remove<Gir.AnyType> ();
                node.add (array);
            }
        }

        if (metadata.has_argument (ARRAY_LENGTH_IDX)) {
            if (node is Gir.Parameter || node is Gir.Callable) {
                var array = (node is Gir.Callable)
                    ? ((Gir.Callable) node).return_value.any_of<Gir.Array> ()
                    : node.any_of<Gir.Array> ();

                if (array == null) {
                    Report.error (source, "Cannot set array length idx on %s", tag);
                } else {
                    array.length = metadata.get_integer (ARRAY_LENGTH_IDX);
                }
            }
        }

        if (metadata.has_argument (DEFAULT) && node is Gir.Parameter) {
            /* TODO: parse expression from string after building the Vala AST */
            node.attrs["default"] = metadata.get_string (DEFAULT);
        }

        if (metadata.has_argument (OUT)) {
            var is_out = metadata.get_bool (OUT);
            var direction = is_out ? Gir.Direction.OUT : Gir.Direction.IN;
            if (node is Gir.Parameter) {
                ((Gir.Parameter) node).direction = direction;
            } else if (node is Gir.InstanceParameter) {
                ((Gir.InstanceParameter) node).direction = direction;
            }
        }

        if (metadata.has_argument (REF)) {
            var is_ref = metadata.get_bool (REF);
            var direction = is_ref ? Gir.Direction.INOUT : Gir.Direction.IN;
            if (node is Gir.Parameter) {
                ((Gir.Parameter) node).direction = direction;
            } else if (node is Gir.InstanceParameter) {
                ((Gir.InstanceParameter) node).direction = direction;
            }
        }

        if (metadata.has_argument (VFUNC_NAME) && node is Gir.Callable) {
            string vm_name = metadata.get_string (VFUNC_NAME);
            string invoker_name = ((Gir.Callable) node).name;
            bool found = false;
            foreach (var vm in node.parent_node.all_of<Gir.VirtualMethod> ()) {
                if (vm.name == vm_name) {
                    vm.invoker = invoker_name;
                    found = true;
                    break;
                }
            }

            if (! found) {
                Report.error (source, "Cannot find vfunc named '%s'", vm_name);
            }
        }

        if (metadata.has_argument (VIRTUAL)) {
            if (node is Gir.Identifier || node is Gir.Callable) {
                node.attr_set_bool ("virtual", metadata.get_bool (VIRTUAL));
            }
        }

        if (metadata.has_argument (ABSTRACT)) {
            if (node is Gir.Class || node is Gir.Method) {
                node.attr_set_bool ("abstract", metadata.get_bool (ABSTRACT));
            }
        }

        if (metadata.has_argument (SCOPE) && node is Gir.Parameter) {
            var scope = Gir.Scope.from_string (metadata.get_string (SCOPE));
            ((Gir.Parameter) node).scope = scope;
        }

        if (metadata.has_argument (STRUCT)) {
            if (node is Gir.Boxed || node is Gir.Record) {
                node.attr_set_bool ("struct", metadata.get_bool (STRUCT));
            }
        }

        if (metadata.has_argument (PRINTF_FORMAT) && node is Gir.Callable) {
            var printf_format = metadata.get_bool (PRINTF_FORMAT);
            node.attr_set_bool ("printf-format", printf_format);
        }

        if (metadata.has_argument (ARRAY_LENGTH_FIELD) && node is Gir.Field) {
            var field_name = metadata.get_string (ARRAY_LENGTH_FIELD);
            var array = node.any_of<Gir.Array> ();
            if (array == null) {
                Report.error (source, "Cannot set array length field on %s", tag);
            } else {
                var fields = node.parent_node.all_of<Gir.Field> ();
                bool found = false;
                for (int i = 0; i < fields.size; i++) {
                    if (fields[i].name == field_name) {
                        array.length = i;
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
            node.attr_set_bool ("sentinel", metadata.get_bool (SENTINEL));
        }

        if (metadata.has_argument (CLOSURE)) {
            var closure = metadata.get_integer (CLOSURE);
            if (node is Gir.Callable) {
                ((Gir.Callable) node).return_value.closure = closure;
            } else if (node is Gir.Parameter) {
                ((Gir.Parameter) node).closure = closure;
            }
        }

        if (metadata.has_argument (ERRORDOMAIN) && node is Gir.Enumeration) {
            /* the value of this attribute isn't actually used, so put a dummy
             * value in it */
            ((Gir.Enumeration) node).glib_error_domain = "DUMMY";
        }

        if (metadata.has_argument (DESTROYS_INSTANCE) && node is Gir.Method) {
            /* a method destroys its instance when ownership is transferred to
             * the instance parameter */
            var method = ((Gir.Method) node);
            method.parameters.instance_parameter.transfer_ownership = FULL;
        }

        if (metadata.has_argument (THROWS) && node is Gir.Callable) {
            ((Gir.Callable) node).throws = metadata.get_bool (THROWS);
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
                var new_ns = Gir.Node.create<Gir.Namespace> (
                    source,
                    "name", name,
                    null
                );
                current_node.add (new_ns);
                current_node = new_ns;
            }
        }

        return current_node;
    }

    /* Replace `current_node` with a child node with the requested name, if it
     * is a namespace or type identifier (class, interface, record etc). */
    private bool move_down_gir_tree (ref Gir.Node current_node, string name) {
        foreach (var child in current_node.children) {
            if ((child is Gir.Namespace || child is Gir.Identifier) 
                    && (child.attrs["name"] == name)) {
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
