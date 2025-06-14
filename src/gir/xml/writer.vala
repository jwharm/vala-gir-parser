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

using Gir;

/**
 * Gir Visitor that writes Xml to a Gio FileStream.
 */
public class Gir.Xml.Writer : Gir.Visitor {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; private set; }

    /**
     * The FileStream to write to
     */
    public unowned FileStream out { get; set; }

    /**
     * The number of spaces used for indentation of the Xml
     */
    public const int INDENT_SPACES = 2;

    private int indent = 0;
    private bool writing_tag = false;

    /**
     * Create a new Gir.Xml.Writer.
     *
     * @param context the Gir Context, used for error reporting
     * @param out     the file output stream, can be a file or ``stdout``
     */
    public Writer (Gir.Context context, FileStream out) {
        this.context = context;
        this.out = out;
    }

    /* Write to the FileStream and log write errors */
    private void write (string str) {
        int result = out.puts (str);
        if (result == FileStream.EOF) {
            context.report.error (null, "Error writing to output stream");
        }
    }

    /* Write the xml open tag */
    private void start_element (string tag) {
        if (writing_tag) {
            write (">\n");
            indent += INDENT_SPACES;
        }
        write (string.nfill (indent, ' '));
        write ("<");
        write (tag);
        writing_tag = true;
    }

    /* When the value is not null, write attribute key and value */
    private void attr_string (string key, string? val) {
        if (val != null & val != "") {
            write (" ");
            write (key);
            write ("=");
            write ("\"");
            write (val);
            write ("\"");
        }
    }

    /* When the value differs from the default, write it as "1" or "0" */
    private void attr_bool (string key, bool val) {
        if (val != (key in Gir.Parser.DEFAULT_TRUE_ATTRIBUTES)) {
            attr_string (key, val ? "1" : "0");
        }
    }

    /* Write attribute, unless the value is -1 (i.e. not set) */
    private void attr_int (string key, int val) {
        if (val != -1) {
            attr_string (key, val.to_string ());
        }
    }

    /* Write attribute with the link text */
    private void attr_link (string key, Gir.Link<Gir.Node> val) {
        attr_string (key, val.text);
    }

    /* Write text contents and then the xml close tag */
    private void end_element_with_text (string tag, string text) {
        if (writing_tag) {
            write (">");
            writing_tag = false;
        }

        string escaped = text.replace ("&", "&amp;")
                             .replace ("\"", "&quot;")
                             .replace ("<", "&lt;")
                             .replace (">", "&gt;");
        write (escaped);
        write ("</");
        write (tag);
        write (">\n");
    }

    /* Write xml close tag */
    private void end_element (string tag) {
        if (writing_tag) {
            write ("/>\n");
            writing_tag = false;
        } else {
            indent -= INDENT_SPACES;
            write (string.nfill (indent, ' '));
            write ("</");
            write (tag);
            write (">\n");
        }
    }

    private void visit_info_attrs (Gir.InfoAttrs i_attrs) {
        attr_bool ("introspectable", i_attrs.introspectable);
        attr_bool ("deprecated", i_attrs.deprecated);
        attr_string ("deprecated_version", i_attrs.deprecated_version);
        attr_string ("version", i_attrs.version);
        attr_string ("stability", i_attrs.stability);
    }

    private void visit_callable_attrs (Gir.CallableAttrs c_attrs) {
        visit_info_attrs (c_attrs);
        attr_string ("name", c_attrs.name);
        attr_string ("c:identifier", c_attrs.c_identifier);
        attr_link ("shadowed-by", c_attrs.shadowed_by);
        attr_link ("shadows", c_attrs.shadows);
        attr_bool ("throws", c_attrs.throws);
        attr_string ("moved-to", c_attrs.moved_to);
        attr_link ("glib:async-func", c_attrs.glib_async_func);
        attr_link ("glib:sync-func", c_attrs.glib_sync_func);
        attr_link ("glib:finish-func", c_attrs.glib_finish_func);
    }

    public override void visit_alias (Gir.Alias alias) {
        start_element ("alias");
        attr_string ("name", alias.name);
        attr_string ("c:type", alias.c_type);
        visit_info_attrs (alias);
        alias.accept_children (this);
        end_element ("alias");
    }

    public override void visit_anonymous_record (Gir.AnonymousRecord rec) {
        start_element ("record");
        rec.accept_children (this);
        end_element ("record");
    }

    public override void visit_array (Gir.Array array) {
        start_element ("array");
        attr_string ("name", array.name);
        attr_bool ("zero-terminated", array.zero_terminated);
        attr_int ("fixed-size", array.fixed_size);
        attr_bool ("introspectable", array.introspectable);
        attr_link ("length", array.length);
        attr_string ("c:type", array.c_type);
        array.accept_children (this);
        end_element ("array");
    }

    public override void visit_attribute (Gir.Attribute attribute) {
        start_element ("attribute");
        attr_string ("name", attribute.name);
        attr_string ("value", attribute.value);
        attribute.accept_children (this);
        end_element ("attribute");
    }

    public override void visit_bitfield (Gir.Bitfield bitfield) {
        start_element ("bitfield");
        attr_string ("name", bitfield.name);
        attr_string ("c:type", bitfield.c_type);
        attr_string ("glib:type-name", bitfield.glib_type_name);
        attr_string ("glib:get-type", bitfield.glib_get_type);
        visit_info_attrs (bitfield);
        bitfield.accept_children (this);
        end_element ("bitfield");
    }

    public override void visit_boxed (Gir.Boxed boxed) {
        start_element ("glib:boxed");
        attr_string ("name", boxed.name);
        attr_string ("c:symbol-prefix", boxed.c_symbol_prefix);
        attr_string ("glib:type-name", boxed.glib_type_name);
        attr_string ("glib:get-type", boxed.glib_get_type);
        visit_info_attrs (boxed);
        boxed.accept_children (this);
        end_element ("glib:boxed");
    }

    public override void visit_c_include (Gir.CInclude c_include) {
        start_element ("c:include");
        attr_string ("name", c_include.name);
        c_include.accept_children (this);
        end_element ("c:include");
    }

    public override void visit_callback (Gir.Callback callback) {
        start_element ("callback");
        visit_info_attrs (callback);
        callback.accept_children (this);
        end_element ("callback");
    }

    public override void visit_class (Gir.Class cls) {
        start_element ("class");
        attr_string ("name", cls.name);
        attr_string ("glib:type-name", cls.glib_type_name);
        attr_string ("glib:get-type", cls.glib_get_type);
        attr_link ("parent", cls.parent);
        attr_link ("glib:type-struct", cls.glib_type_struct);
        attr_link ("glib:ref-func", cls.glib_ref_func);
        attr_link ("glib:unref-func", cls.glib_unref_func);
        attr_link ("glib:set-value-func", cls.glib_set_value_func);
        attr_link ("glib:get-value-func", cls.glib_get_value_func);
        attr_string ("c:type", cls.c_type);
        attr_string ("c:symbol-prefix", cls.c_symbol_prefix);
        attr_bool ("abstract", cls.abstract);
        attr_bool ("glib:fundamental", cls.glib_fundamental);
        attr_bool ("final", cls.final);
        visit_info_attrs (cls);
        cls.accept_children (this);
        end_element ("class");
    }

    public override void visit_constant (Gir.Constant constant) {
        start_element ("constant");
        attr_string ("name", constant.name);
        attr_string ("value", constant.value);
        attr_string ("c:type", constant.c_type);
        attr_string ("c:identifier", constant.c_identifier);
        visit_info_attrs (constant);
        constant.accept_children (this);
        end_element ("constant");
    }

    public override void visit_constructor (Gir.Constructor constructor) {
        start_element ("constructor");
        visit_callable_attrs (constructor);
        constructor.accept_children (this);
        end_element ("constructor");
    }

    public override void visit_doc_deprecated (Gir.DocDeprecated doc_dep) {
        start_element ("doc-deprecated");
        doc_dep.accept_children (this);
        end_element ("doc-deprecated");
    }

    public override void visit_doc_format (Gir.DocFormat doc_format) {
        start_element ("doc-format");
        attr_string ("name", doc_format.name);
        doc_format.accept_children (this);
        end_element ("doc-format");
    }

    public override void visit_doc_stability (Gir.DocStability doc_stability) {
        if (doc_stability.text != null) {
            start_element ("doc-stability");
            doc_stability.accept_children (this);
            end_element_with_text ("doc-stability", doc_stability.text);
        }
    }

    public override void visit_doc_version (Gir.DocVersion doc_version) {
        if (doc_version.text != null) {
            start_element ("doc-version");
            doc_version.accept_children (this);
            end_element_with_text ("doc-version", doc_version.text);
        }
    }

    public override void visit_doc (Gir.Doc doc) {
        if (doc.text != null) {
            start_element ("doc");
            attr_string ("filename", doc.filename);
            attr_string ("line", doc.line);
            attr_string ("column", doc.column);
            doc.accept_children (this);
            end_element_with_text ("doc", doc.text);
        }
    }

    public override void visit_docsection (Gir.Docsection docsection) {
        start_element ("docsection");
        attr_string ("name", docsection.name);
        docsection.accept_children (this);
        end_element ("docsection");
    }

    public override void visit_enumeration (Gir.Enumeration enumeration) {
        start_element ("enumeration");
        attr_string ("name", enumeration.name);
        attr_string ("c:type", enumeration.c_type);
        attr_string ("glib:type-name", enumeration.glib_type_name);
        attr_string ("glib:get-type", enumeration.glib_get_type);
        attr_string ("glib:error-domain", enumeration.glib_error_domain);
        visit_info_attrs (enumeration);
        enumeration.accept_children (this);
        end_element ("enumeration");
    }

    public override void visit_field (Gir.Field field) {
        start_element ("field");
        attr_string ("name", field.name);
        attr_bool ("readable", field.readable);
        attr_bool ("writable", field.writable);
        attr_int ("bits", field.bits);
        visit_info_attrs (field);
        field.accept_children (this);
        end_element ("field");
    }

    public override void visit_function_inline (Gir.FunctionInline f_inline) {
        start_element ("function-inline");
        visit_callable_attrs (f_inline);
        f_inline.accept_children (this);
        end_element ("function-inline");
    }

    public override void visit_function_macro (Gir.FunctionMacro f_macro) {
        start_element ("function-macro");
        visit_callable_attrs (f_macro);
        f_macro.accept_children (this);
        end_element ("function-macro");
    }

    public override void visit_function (Gir.Function function) {
        start_element ("function");
        visit_callable_attrs (function);
        function.accept_children (this);
        end_element ("function");
    }

    public override void visit_implements (Gir.Implements implements) {
        start_element ("implements");
        attr_string ("name", implements.name);
        implements.accept_children (this);
        end_element ("implements");
    }

    public override void visit_include (Gir.Include include) {
        start_element ("include");
        attr_string ("name", include.name);
        attr_string ("version", include.version);
        include.accept_children (this);
        end_element ("include");
    }

    public override void visit_instance_parameter (Gir.InstanceParameter par) {
        start_element ("instance-parameter");
        attr_string ("name", par.name);
        attr_bool ("nullable", par.nullable);
        attr_bool ("allow-none", par.allow_none);
        attr_string ("direction", par.direction.to_string ());
        attr_bool ("caller-allocates", par.caller_allocates);
        attr_string ("transfer-ownership", par.transfer_ownership.to_string ());
        par.accept_children (this);
        end_element ("instance-parameter");
    }

    public override void visit_interface (Gir.Interface iface) {
        start_element ("interface");
        attr_string ("name", iface.name);
        attr_string ("glib:type-name", iface.glib_type_name);
        attr_string ("glib:get-type", iface.glib_get_type);
        attr_string ("c:symbol-prefix", iface.c_symbol_prefix);
        attr_string ("c:type", iface.c_type);
        attr_link ("glib:type-struct", iface.glib_type_struct);
        visit_info_attrs (iface);
        iface.accept_children (this);
        end_element ("interface");
    }

    public override void visit_member (Gir.Member member) {
        start_element ("member");
        attr_string ("name", member.name);
        attr_string ("value", member.value);
        attr_string ("c:identifier", member.c_identifier);
        attr_string ("glib:nick", member.glib_nick);
        attr_string ("glib:name", member.glib_name);
        visit_info_attrs (member);
        member.accept_children (this);
        end_element ("member");
    }

    public override void visit_method_inline (Gir.MethodInline m_inline) {
        start_element ("method-inline");
        visit_callable_attrs (m_inline);
        m_inline.accept_children (this);
        end_element ("method-inline");
    }

    public override void visit_method (Gir.Method method) {
        start_element ("method");
        visit_callable_attrs (method);
        attr_link ("glib:set-property", method.glib_set_property);
        attr_link ("glib:get-property", method.glib_get_property);
        method.accept_children (this);
        end_element ("method");
    }

    public override void visit_namespace (Gir.Namespace ns) {
        start_element ("namespace");
        attr_string ("name", ns.name);
        attr_string ("version", ns.version);
        attr_string ("c:identifier-prefixes", ns.c_identifier_prefixes);
        attr_string ("c:symbol-prefixes", ns.c_symbol_prefixes);
        attr_string ("c:prefix", ns.c_prefix);
        attr_string ("shared-library", ns.shared_library);
        ns.accept_children (this);
        end_element ("namespace");
    }

    public override void visit_package (Gir.Package package) {
        start_element ("package");
        attr_string ("name", package.name);
        package.accept_children (this);
        end_element ("package");
    }

    public override void visit_parameter (Gir.Parameter par) {
        start_element ("parameter");
        attr_string ("name", par.name);
        attr_bool ("nullable", par.nullable);
        attr_bool ("allow-none", par.allow_none);
        attr_bool ("introspectable", par.introspectable);
        attr_link ("closure", par.closure);
        attr_link ("destroy", par.destroy);
        attr_string ("scope", par.scope.to_string ());
        attr_string ("direction", par.direction.to_string ());
        attr_bool ("caller-allocates", par.caller_allocates);
        attr_bool ("optional", par.optional);
        attr_bool ("skip", par.skip);
        attr_string ("transfer-ownership", par.transfer_ownership.to_string ());
        par.accept_children (this);
        end_element ("parameter");
    }

    public override void visit_parameters (Gir.Parameters parameters) {
        start_element ("parameters");
        parameters.accept_children (this);
        end_element ("parameters");
    }

    public override void visit_prerequisite (Gir.Prerequisite prerequisite) {
        start_element ("prerequisite");
        attr_string ("name", prerequisite.name);
        prerequisite.accept_children (this);
        end_element ("prerequisite");
    }

    public override void visit_property (Gir.Property property) {
        start_element ("property");
        attr_string ("name", property.name);
        attr_bool ("writable", property.writable);
        attr_bool ("readable", property.readable);
        attr_bool ("construct", property.construct);
        attr_bool ("construct-only", property.construct_only);
        attr_link ("setter", property.setter);
        attr_link ("getter", property.getter);
        attr_string ("default-value", property.default_value);
        visit_info_attrs (property);
        property.accept_children (this);
        end_element ("property");
    }

    public override void visit_record (Gir.Record rec) {
        start_element ("record");
        attr_string ("name", rec.name);
        attr_string ("c:type", rec.c_type);
        attr_bool ("disguised", rec.disguised);
        attr_bool ("opaque", rec.opaque);
        attr_bool ("pointer", rec.pointer);
        attr_string ("glib:type-name", rec.glib_type_name);
        attr_string ("glib:get-type", rec.glib_get_type);
        attr_string ("c:symbol-prefix", rec.c_symbol_prefix);
        attr_string ("glib:is-gtype-struct-for", rec.glib_is_gtype_struct_for);
        attr_link ("copy-function", rec.copy_function);
        attr_link ("free-function", rec.free_function);
        visit_info_attrs (rec);
        rec.accept_children (this);
        end_element ("record");
    }

    public override void visit_repository (Gir.Repository repository) {
        write ("<?xml version=\"1.0\"?>\n");
        write ("<!-- This file was automatically generated by vala-gir-parser - DO NOT EDIT! -->\n");
        start_element ("repository");
        attr_string ("xmlns", "http://www.gtk.org/introspection/core/1.0");
        attr_string ("xmlns:c", "http://www.gtk.org/introspection/c/1.0");
        attr_string ("xmlns:doc", "http://www.gtk.org/introspection/doc/1.0");
        attr_string ("xmlns:glib", "http://www.gtk.org/introspection/glib/1.0");
        attr_string ("version", repository.version);
        attr_string ("c:identifier-prefixes", repository.c_identifier_prefixes);
        attr_string ("c:symbol-prefixs", repository.c_symbol_prefixes);
        repository.accept_children (this);
        end_element ("repository");
    }

    public override void visit_return_value (Gir.ReturnValue rv) {
        start_element ("return-value");
        attr_bool ("introspectable", rv.nullable);
        attr_bool ("nullable", rv.nullable);
        attr_link ("closure", rv.closure);
        attr_string ("scope", rv.scope.to_string ());
        attr_link ("destroy", rv.destroy);
        attr_bool ("skip", rv.skip);
        attr_bool ("allow-none", rv.allow_none);
        attr_string ("transfer-ownership", rv.transfer_ownership.to_string ());
        rv.accept_children (this);
        end_element ("return-value");
    }

    public override void visit_signal (Gir.Signal sig) {
        start_element ("glib:signal");
        attr_string ("name", sig.name);
        attr_bool ("detailed", sig.detailed);
        attr_string ("when", sig.when.to_string ());
        attr_bool ("action", sig.action);
        attr_bool ("no-hooks", sig.no_hooks);
        attr_bool ("no-recurse", sig.no_recurse);
        attr_string ("emitter", sig.emitter);
        visit_info_attrs (sig);
        sig.accept_children (this);
        end_element ("glib:signal");
    }

    public override void visit_source_position (Gir.SourcePosition pos) {
        start_element ("source-position");
        attr_string ("filename", pos.filename);
        attr_string ("line", pos.line);
        attr_string ("column", pos.column);
        pos.accept_children (this);
        end_element ("source-position");
    }

    public override void visit_type (Gir.TypeRef type) {
        start_element ("type");
        attr_string ("name", type.name);
        attr_string ("c:type", type.c_type);
        attr_bool ("introspectable", type.introspectable);
        type.accept_children (this);
        end_element ("type");
    }

    public override void visit_union (Gir.Union union) {
        start_element ("union");
        attr_string ("name", union.name);
        attr_string ("c:type", union.c_type);
        attr_string ("c:symbol-prefix", union.c_symbol_prefix);
        attr_string ("glib:type-name", union.glib_type_name);
        attr_string ("glib:get-type", union.glib_get_type);
        attr_link ("copy-function", union.copy_function);
        attr_link ("free-function", union.free_function);
        visit_info_attrs (union);
        union.accept_children (this);
        end_element ("union");
    }

    public override void visit_varargs (Gir.Varargs varargs) {
        start_element ("varargs");
        varargs.accept_children (this);
        end_element ("varargs");
    }

    public override void visit_virtual_method (Gir.VirtualMethod vm) {
        start_element ("virtual-method");
        visit_callable_attrs (vm);
        vm.accept_children (this);
        end_element ("virtual-method");
    }
}
