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

public class Gir.Namespace : Node {
    public string name {
        owned get {
            return attrs["name"];
        }
        set {
            attrs["name"] = value;
        }
    }
    
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
    
    public string c_prefix {
        owned get {
            return attrs["c:prefix"];
        }
        set {
            attrs["c:prefix"] = value;
        }
    }
    
    public string shared_library {
        owned get {
            return attrs["shared-library"];
        }
        set {
            attrs["shared-library"] = value;
        }
    }
    
    public Vala.List<Alias> aliases {
        owned get {
            return all_of<Alias> ();
        }
    }
    
    public Vala.List<Class> classes {
        owned get {
            return all_of<Class> ();
        }
    }
    
    public Vala.List<Interface> interfaces {
        owned get {
            return all_of<Interface> ();
        }
    }
    
    public Vala.List<Record> records {
        owned get {
            return all_of<Record> ();
        }
    }
    
    public Vala.List<Enumeration> enumerations {
        owned get {
            return all_of<Enumeration> ();
        }
    }
    
    public Vala.List<Function> functions {
        owned get {
            return all_of<Function> ();
        }
    }
    
    public Vala.List<FunctionInline> function_inlines {
        owned get {
            return all_of<FunctionInline> ();
        }
    }
    
    public Vala.List<FunctionMacro> function_macros {
        owned get {
            return all_of<FunctionMacro> ();
        }
    }
    
    public Vala.List<Union> unions {
        owned get {
            return all_of<Union> ();
        }
    }
    
    public Vala.List<Bitfield> bitfields {
        owned get {
            return all_of<Bitfield> ();
        }
    }
    
    public Vala.List<Callback> callbacks {
        owned get {
            return all_of<Callback> ();
        }
    }
    
    public Vala.List<Constant> constants {
        owned get {
            return all_of<Constant> ();
        }
    }
    
    public Vala.List<Attribute> attributes {
        owned get {
            return all_of<Attribute> ();
        }
    }
    
    public Vala.List<Boxed> boxeds {
        owned get {
            return all_of<Boxed> ();
        }
    }
    
    public Vala.List<Docsection> docsections {
        owned get {
            return all_of<Docsection> ();
        }
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_namespace (this);
    }
}
