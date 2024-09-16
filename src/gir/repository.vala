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

using Gee;

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
    
    public Gee.List<Include> includes {
        owned get {
            return all_of<Include> ();
        }
    }
    
    public Gee.List<CInclude> c_includes {
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
    
    /* 
     * The gir spec allows multiple namespaces in a gir file, but as far as I
     * know, there is always just one single namespace in a gir file, so to keep
     * things simple, we return only one namespace element.
     */
    public Namespace @namespace {
        owned get {
            return any_of<Namespace> ();
        }
        set {
            remove_and_set (value);
        }
    }
}

