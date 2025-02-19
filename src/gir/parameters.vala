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

public class Gir.Parameters : Node {
    public Vala.List<Parameter> parameters { owned get; set; }
    public InstanceParameter? instance_parameter { get; set; }

    public Parameters (
            Vala.List<Parameter> parameters,
            InstanceParameter? instance_parameter,
            Vala.SourceReference? source) {
        base(source);
        this.parameters = parameters;
        this.instance_parameter = instance_parameter;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_parameters (this);
    }

    public override void accept_children (GirVisitor visitor) {
        foreach (var parameter in parameters) {
            parameter.accept (visitor);
        }

        instance_parameter?.accept (visitor);
    }
}

