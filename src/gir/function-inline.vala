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

public class Gir.FunctionInline : CallableAttrs, DocElements, Node, Callable {
    protected CallableAttrsValues callable_attrs_values { get; set; }
    public Parameters? parameters { get; set; }
    public ReturnValue? return_value { get; set; }
    protected DocElementsValues doc_elements_values { get; set; }

    public FunctionInline (
            CallableAttrsValues callable_attrs_values,
            Parameters? parameters,
            ReturnValue? return_value,
            DocElementsValues doc_elements_values,
            Gir.Xml.Reference? source) {
        base(source);
        this.callable_attrs_values = callable_attrs_values;
        this.parameters = parameters;
        this.return_value = return_value;
        this.doc_elements_values = doc_elements_values;
    }

    public override void accept (Visitor visitor) {
        visitor.visit_function_inline (this);
    }

    public override void accept_children (Visitor visitor) {
        accept_doc_elements (visitor);
        parameters?.accept (visitor);
        return_value?.accept (visitor);
    }
}

