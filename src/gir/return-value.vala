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

public class Gir.ReturnValue : Node, DocElements {
    public bool introspectable {
        get {
            return attr_get_bool ("introspectable", true);
        }
        set {
            attr_set_bool ("introspectable", value);
        }
    }
    
    public bool nullable {
        get {
            return attr_get_bool ("nullable", false);
        }
        set {
            attr_set_bool ("nullable", value);
        }
    }
    
    public Scope scope {
        get {
            return Scope.from_string (attrs["scope"]);
        }
        set {
            if (value == Scope.UNDEFINED) {
                attrs.remove ("scope");
            } else {
                attrs["scope"] = value.to_string ();
            }
        }
    }
    
    public int closure {
        get {
            return attr_get_int ("closure", -1);
        }
        set {
            attr_set_int ("closure", value);
        }
    }
    
    public int destroy {
        get {
            return attr_get_int ("destroy", -1);
        }
        set {
            attr_set_int ("destroy", value);
        }
    }
    
    public bool skip {
        get {
            return attr_get_bool ("skip", false);
        }
        set {
            attr_set_bool ("skip", value);
        }
    }
    
    public bool allow_none {
        get {
            return attr_get_bool ("allow-none", false);
        }
        set {
            attr_set_bool ("allow-none", value);
        }
    }
    
    public TransferOwnership transfer_ownership {
        get {
            return TransferOwnership.from_string (attrs["transfer-ownership"]);
        }
        set {
            if (value == TransferOwnership.UNDEFINED) {
                attrs.remove ("transfer-ownership");
            } else {
                attrs["transfer-ownership"] = value.to_string ();
            }
        }
    }
    
    public Gee.List<Attribute> attributes {
        owned get {
            return all_of (typeof (Attribute));
        }
    }
    
    public AnyType anytype {
        owned get {
            return any_of (typeof (AnyType));
        }
        set {
            remove_and_set (value);
        }
    }
}

