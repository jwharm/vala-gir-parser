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

public class Gir.Constructor : CallableAttrs, InfoElements, Callable, Node {
    protected CallableAttrsValues callable_attrs_values { get; set; }
    protected InfoElementsValues info_elements_values { get; set; }
    public Parameters? parameters { get; set; }
    public ReturnValue? return_value { get; set; }

    public Constructor (
            CallableAttrsValues callable_attrs_values,
            InfoElementsValues info_elements_values,
            Parameters? parameters,
            ReturnValue? return_value,
            Gir.Xml.Reference? source) {
        base(source);
        this.callable_attrs_values = callable_attrs_values;
        this.info_elements_values = info_elements_values;
        this.parameters = parameters;
        this.return_value = return_value;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_constructor (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_info_elements (visitor);
        parameters?.accept (visitor);
        return_value?.accept (visitor);
    }
}

