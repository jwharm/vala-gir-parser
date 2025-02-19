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

public class Gir.Repository : Node {
    public string? version { owned get; set; }
    public string? c_identifier_prefixes { owned get; set; }
    public string? c_symbol_prefixes { owned get; set; }
    public Vala.List<Include> includes { owned get; set; }
    public Vala.List<CInclude> cincludes { owned get; set; }
    public Vala.List<Package> packages { owned get; set; }
    public Vala.List<Namespace> namespaces { owned get; set; }
    public Vala.List<DocFormat> doc_formats { owned get; set; }

    public Repository (
            string? version,
            string? c_identifier_prefixes,
            string? c_symbol_prefixes,
            Vala.List<Include> includes,
            Vala.List<CInclude> cincludes,
            Vala.List<Package> packages,
            Vala.List<Namespace> namespaces,
            Vala.List<DocFormat> doc_formats,
            Vala.SourceReference? source) {
        base(source);
        this.version = version;
        this.c_identifier_prefixes = c_identifier_prefixes;
        this.c_symbol_prefixes = c_symbol_prefixes;
        this.includes = includes;
        this.cincludes = cincludes;
        this.packages = packages;
        this.namespaces = namespaces;
        this.doc_formats = doc_formats;
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_repository (this);
    }

    public override void accept_children (GirVisitor visitor) {
        foreach (var include in includes) {
            include.accept (visitor);
        }

        foreach (var cinclude in cincludes) {
            cinclude.accept (visitor);
        }

        foreach (var package in packages) {
            package.accept (visitor);
        }

        foreach (var namespace in namespaces) {
            namespace.accept (visitor);
        }

        foreach (var doc_format in doc_formats) {
            doc_format.accept (visitor);
        }
    }
}

