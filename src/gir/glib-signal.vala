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

public class Gir.Signal : InfoAttrs, DocElements, InfoElements, Callable, Node {
    public bool introspectable { get; set; }
    public bool deprecated { get; set; }
    public string? deprecated_version { owned get; set; }
    public string? version { owned get; set; }
    public string? stability { owned get; set; }
    public string name { owned get; set; }
    public bool detailed { get; set; }
    public When when { get; set; }
    public bool action { get; set; }
    public bool no_hooks { get; set; }
    public bool no_recurse { get; set; }
    public string? emitter { owned get; set; }
    public DocVersion? doc_version { get; set; }
    public DocStability? doc_stability { get; set; }
    public Doc? doc { get; set; }
    public DocDeprecated? doc_deprecated { get; set; }
    public SourcePosition? source_position { get; set; }
    public Gee.List<Attribute> attributes { owned get; set; }
    public Parameters? parameters { get; set; }
    public ReturnValue? return_value { get; set; }

    public Signal (
            InfoAttrsParameters info_attrs,
            string name,
            bool detailed,
            When when,
            bool action,
            bool no_hooks,
            bool no_recurse,
            string? emitter,
            InfoElementsParameters info_elements,
            Parameters? parameters,
            ReturnValue? return_value,
            Gir.Xml.Reference? source) {
        base(source);
        init_info_attrs (info_attrs);
        this.name = name;
        this.detailed = detailed;
        this.when = when;
        this.action = action;
        this.no_hooks = no_hooks;
        this.no_recurse = no_recurse;
        this.emitter = emitter;
        init_info_elements (info_elements);
        this.parameters = parameters;
        this.return_value = return_value;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_signal (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
        parameters?.accept (visitor);
        return_value?.accept (visitor);
    }
}

