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

public class Gir.Repository : Node {
    public string version {
        owned get {
            return attrs["version"];
        }
        set {
            attrs["version"] = value;
        }
    }
    
    public string c_identifier_prefixes {
        owned get {
            return attrs["c:identifier-prefixes"];
        }
        set {
            attrs["c:identifier-prefixes"] = value;
        }
    }
    
    public string c_symbol_prefixes {
        owned get {
            return attrs["c:symbol-prefixes"];
        }
        set {
            attrs["c:symbol-prefixes"] = value;
        }
    }
    
    public Vala.List<Include> includes {
        owned get {
            return all_of<Include> ();
        }
    }
    
    public Vala.List<CInclude> c_includes {
        owned get {
            return all_of<CInclude> ();
        }
    }
    
    public Package? package {
        owned get {
            return any_of<Package> ();
        }
        set {
            remove_and_set (value);
        }
    }
    
    public Vala.List<Namespace> namespaces {
        owned get {
            return all_of<Namespace> ();
        }
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_repository (this);
    }
}

