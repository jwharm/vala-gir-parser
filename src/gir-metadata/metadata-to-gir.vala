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

/**
 * Match a Gir metadata file against a Gir AST, and copy the rules into Gir
 * `<attribute name="vala:..." value="..." />` elements.
 */
public class GirMetadata.MetadataToGir : Gir.Visitor {
    private Gee.List<Metadata> metadata_stack = new Gee.ArrayList<Metadata> ();

    public void process (Metadata metadata, Gir.Node repository) {
        metadata_stack.add (metadata);
        repository.accept (this);
        metadata_stack.clear ();
    }
    
    public override void visit_alias (Gir.Alias alias) {
        alias.accept_children (this);
    }

    public override void visit_anonymous_record (Gir.AnonymousRecord record) {
        record.accept_children (this);
    }

    public override void visit_array (Gir.Array array) {
        array.accept_children (this);
    }

    public override void visit_attribute (Gir.Attribute attribute) {
        attribute.accept_children (this);
    }

    public override void visit_bitfield (Gir.Bitfield bitfield) {
        bitfield.accept_children (this);
    }

    public override void visit_boxed (Gir.Boxed boxed) {
        boxed.accept_children (this);
    }

    public override void visit_c_include (Gir.CInclude c_include) {
        c_include.accept_children (this);
    }

    public override void visit_callback (Gir.Callback callback) {
        callback.accept_children (this);
    }

    public override void visit_class (Gir.Class cls) {
        if (push_metadata (cls.name, "class")) {
            copy_metadata_to (cls.attributes);
            cls.accept_children (this);
            pop_metadata ();
        }
    }

    public override void visit_constant (Gir.Constant constant) {
        constant.accept_children (this);
    }

    public override void visit_constructor (Gir.Constructor constructor) {
        constructor.accept_children (this);
    }

    public override void visit_doc_deprecated (Gir.DocDeprecated doc_deprecated) {
        doc_deprecated.accept_children (this);
    }

    public override void visit_doc_format (Gir.DocFormat doc_format) {
        doc_format.accept_children (this);
    }

    public override void visit_doc_stability (Gir.DocStability doc_stability) {
        doc_stability.accept_children (this);
    }

    public override void visit_doc_version (Gir.DocVersion doc_version) {
        doc_version.accept_children (this);
    }

    public override void visit_doc (Gir.Doc doc) {
        doc.accept_children (this);
    }

    public override void visit_docsection (Gir.Docsection docsection) {
        docsection.accept_children (this);
    }

    public override void visit_enumeration (Gir.Enumeration enumeration) {
        enumeration.accept_children (this);
    }

    public override void visit_field (Gir.Field field) {
        field.accept_children (this);
    }

    public override void visit_function_inline (Gir.FunctionInline function_inline) {
        function_inline.accept_children (this);
    }

    public override void visit_function_macro (Gir.FunctionMacro function_macro) {
        function_macro.accept_children (this);
    }

    public override void visit_function (Gir.Function function) {
        function.accept_children (this);
    }

    public override void visit_implements (Gir.Implements implements) {
        implements.accept_children (this);
    }

    public override void visit_include (Gir.Include include) {
        include.accept_children (this);
    }

    public override void visit_instance_parameter (Gir.InstanceParameter instance_parameter) {
        instance_parameter.accept_children (this);
    }

    public override void visit_interface (Gir.Interface iface) {
        iface.accept_children (this);
    }

    public override void visit_member (Gir.Member member) {
        member.accept_children (this);
    }

    public override void visit_method_inline (Gir.MethodInline method_inline) {
        method_inline.accept_children (this);
    }

    public override void visit_method (Gir.Method method) {
        if (push_metadata (method.name, "method")) {
            copy_metadata_to (method.attributes);
            method.accept_children (this);
            pop_metadata ();
        }
    }

    public override void visit_namespace (Gir.Namespace ns) {
        ns.accept_children (this);
    }

    public override void visit_package (Gir.Package package) {
        package.accept_children (this);
    }

    public override void visit_parameter (Gir.Parameter parameter) {
        parameter.accept_children (this);
    }

    public override void visit_parameters (Gir.Parameters parameters) {
        parameters.accept_children (this);
    }

    public override void visit_prerequisite (Gir.Prerequisite prerequisite) {
        prerequisite.accept_children (this);
    }

    public override void visit_property (Gir.Property property) {
        property.accept_children (this);
    }

    public override void visit_record (Gir.Record record) {
        record.accept_children (this);
    }

    public override void visit_repository (Gir.Repository repository) {
        repository.accept_children (this);
    }

    public override void visit_return_value (Gir.ReturnValue return_value) {
        return_value.accept_children (this);
    }

    public override void visit_signal (Gir.Signal sig) {
        sig.accept_children (this);
    }

    public override void visit_source_position (Gir.SourcePosition source_position) {
        source_position.accept_children (this);
    }

    public override void visit_type (Gir.TypeRef type) {
        type.accept_children (this);
    }

    public override void visit_union (Gir.Union union) {
        union.accept_children (this);
    }

    public override void visit_varargs (Gir.Varargs varargs) {
        varargs.accept_children (this);
    }

    public override void visit_virtual_method (Gir.VirtualMethod virtual_method) {
        virtual_method.accept_children (this);
    }

    /* Find matching metadata and push it on the stack. Returns true when there
     * is a matching metadata rule, or false when no metadata rules matched.
     *
     * This function *always* pushes a Metadata instance on the stack, so it
     * must always be followed by a call to pop_metadata() later. */
    private bool push_metadata (string? name, string tag) {
        var metadata = get_current_metadata (name, tag);
        if (metadata == Metadata.empty) {
            return false;
        }

        metadata_stack.add (metadata);
        return true;
    }

    /* Read (but not remove) the current metadata from the stack. */
    private Metadata peek_metadata () {
        return metadata_stack.last ();
    }

    /* Pop (remove) the current metadata from the stack. */
    private void pop_metadata () {
        metadata_stack.remove_at (metadata_stack.size - 1);
    }

    /* Find the metadata rules matching the current Gir element name and tag. */
    private Metadata get_current_metadata (string? name, string selector) {
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

    /* Copy the attributes of the currently selected metadata rule into the
     * provided attributes list. */
    private void copy_metadata_to (Gee.List<Gir.Attribute> attributes) {
        foreach (var entry in peek_metadata ().args) {
            attributes.add (new Gir.Attribute (entry.key, entry.value, null));
        }
    }
}
