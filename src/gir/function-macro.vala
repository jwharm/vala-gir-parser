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

public class Gir.FunctionMacro : InfoAttrs, DocElements, InfoElements, Node, CallableAttrs {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public string? c_identifier { owned get; set; }
    public Link<Callable> shadowed_by { owned get; set; }
    public Link<Callable> shadows { owned get; set; }
    public bool @throws { get; set; }
    public string? moved_to { owned get; set; }
    public Link<Callable> glib_async_func { owned get; set; }
    public Link<Callable> glib_sync_func { owned get; set; }
    public Link<Callable> glib_finish_func { owned get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Parameters? parameters { get; set; }

    public FunctionMacro (
            CallableAttrsParameters callable_attrs,
            InfoElementsParameters info_elements,
            Parameters? parameters,
            Gir.Xml.Reference? source) {
        base(source);
        init_callable_attrs (callable_attrs);
        init_info_elements (info_elements);
        this.parameters = parameters;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_function_macro (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
        parameters?.accept (visitor);
    }
}

