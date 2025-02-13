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

public class Gir.Record : Node, InfoAttrs, DocElements, InfoElements,
                          Identifier {
    public string name {
        owned get {
            return attrs["name"];
        }
        set {
            attrs["name"] = value;
        }
    }
    
    public string? c_type {
        owned get {
            return attrs["c:type"];
        }
        set {
            attrs["c:type"] = value;
        }
    }
    
    public bool disguised {
        get {
            return attr_get_bool ("disguised", false);
        }
        set {
            attr_set_bool ("disguised", value);
        }
    }   
    
    public bool opaque {
        get {
            return attr_get_bool ("opaque", false);
        }
        set {
            attr_set_bool ("opaque", value);
        }
    }   
    
    public bool pointer {
        get {
            return attr_get_bool ("pointer", false);
        }
        set {
            attr_set_bool ("pointer", value);
        }
    }
    
    public string? glib_type_name {
        owned get {
            return attrs["glib:type-name"];
        }
        set {
            attrs["glib:type-name"] = value;
        }
    }
    
    public string? glib_get_type {
        owned get {
            return attrs["glib:get-type"];
        }
        set {
            attrs["glib:get-type"] = value;
        }
    }
    
    public string? c_symbol_prefix {
        owned get {
            return attrs["c:symbol-prefix"];
        }
        set {
            attrs["c:symbol-prefix"] = value;
        }
    }
    
    public bool foreign {
        get {
            return attr_get_bool ("foreign", false);
        }
        set {
            attr_set_bool ("foreign", value);
        }
    }
    
    public string? glib_is_gtype_struct_for {
        owned get {
            return attrs["glib:is-gtype-struct-for"];
        }
        set {
            attrs["glib:is-gtype-struct-for"] = value;
        }
    }
    
    public string? copy_function {
        owned get {
            return attrs["copy-function"];
        }
        set {
            attrs["copy-function"] = value;
        }
    }
    
    public string? free_function {
        owned get {
            return attrs["free-function"];
        }
        set {
            attrs["free-function"] = value;
        }
    }
    
    public Vala.List<Field> fields {
        owned get {
            return all_of<Field> ();
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
    
    public Vala.List<Union> unions {
        owned get {
            return all_of<Union> ();
        }
    }
    
    public Vala.List<Method> methods {
        owned get {
            return all_of<Method> ();
        }
    }
    
    public Vala.List<MethodInline> method_inlines {
        owned get {
            return all_of<MethodInline> ();
        }
    }
    
    public Vala.List<Constructor> constructors {
        owned get {
            return all_of<Constructor> ();
        }
    }
}

