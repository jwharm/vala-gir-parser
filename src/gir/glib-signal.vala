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

public class Gir.Signal : InfoAttrs, InfoElements, Callable, Node {
    protected InfoAttrsValues info_attrs_values { get; set; }
    public string name { owned get; set; }
    public bool detailed { get; set; }
    public When when { get; set; }
    public bool action { get; set; }
    public bool no_hooks { get; set; }
    public bool no_recurse { get; set; }
    public string? emitter { owned get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public Parameters? parameters { get; set; }
    public ReturnValue? return_value { get; set; }

    public Signal (
            InfoAttrsValues info_attrs_values,
            string name,
            bool detailed,
            When when,
            bool action,
            bool no_hooks,
            bool no_recurse,
            string? emitter,
            InfoElementsValues info_elements_values,
            Parameters? parameters,
            ReturnValue? return_value,
            Gir.Xml.Reference? source) {
        base(source);
        this.info_attrs_values = info_attrs_values;
        this.name = name;
        this.detailed = detailed;
        this.when = when;
        this.action = action;
        this.no_hooks = no_hooks;
        this.no_recurse = no_recurse;
        this.emitter = emitter;
        this.info_elements_values = info_elements_values;
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

