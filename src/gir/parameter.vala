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

public class Gir.Parameter : Node, DocElements {
    public string name                              { owned get; set; }
    public bool introspectable                      { get; set; }
    public override DocVersion? doc_version         { owned get; set; }
    public override DocStability? doc_stability     { owned get; set; }
    public override Doc? doc                        { owned get; set; }
    public override DocDeprecated? doc_deprecated   { owned get; set; }
    public override SourcePosition? source_position { owned get; set; }
    public Vala.List<Attribute> attributes          { owned get; set; }
    public bool nullable                            { get; set; }
    public bool allow_none                          { get; set; }
    public int closure                              { get; set; }
    public int destroy                              { get; set; }
    public Scope scope                              { get; set; }
    public Direction direction                      { get; set; }
    public bool caller_allocates                    { get; set; }
    public bool optional                            { get; set; }
    public bool skip                                { get; set; }
    public TransferOwnership transfer_ownership     { get; set; }
    public AnyType? anytype                         { owned get; set; }
    public Varargs? varargs                         { owned get; set; }

    public Parameter (string name, bool introspectable, DocVersion? doc_version,
                      DocStability? doc_stability, Doc? doc, DocDeprecated? doc_deprecated,
                      SourcePosition? source_position, Vala.List<Attribute> attributes,
                      bool nullable, bool allow_none, int closure, int destroy,
                      Scope scope, Direction direction, bool caller_allocates,
                      bool optional, bool skip, TransferOwnership transfer_ownership,
                      AnyType? anytype, Varargs? varargs) {
        this.name = name;
        this.introspectable = introspectable;
        this.doc_version = doc_version;
        this.doc_stability = doc_stability;
        this.doc = doc;
        this.doc_deprecated = doc_deprecated;
        this.source_position = source_position;
        this.attributes = attributes;
        this.nullable = nullable;
        this.allow_none = allow_none;
        this.closure = closure;
        this.destroy = destroy;
        this.scope = scope;
        this.direction = direction;
        this.caller_allocates = caller_allocates;
        this.optional = optional;
        this.skip = skip;
        this.transfer_ownership = transfer_ownership;
        this.anytype = anytype;
        this.varargs = varargs;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_parameter (this);
    }

    public override void accept_children (GirVisitor visitor) {
        doc_version.accept (visitor);
        doc_stability.accept (visitor);
        doc.accept (visitor);
        doc_deprecated.accept (visitor);
        source_position.accept (visitor);
        
        foreach (var attribute in attributes) {
            attribute.accept (visitor);
        }

        anytype.accept (visitor);
        varargs.accept (visitor);
    }
}
