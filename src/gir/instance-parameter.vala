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

public class Gir.InstanceParameter : Node, DocElements {
    public string name {
        owned get {
            return attrs["name"];
        }
        set {
            attrs["name"] = value;
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
    
    public bool allow_none {
        get {
            return attr_get_bool ("allow-none", true);
        }
        set {
            attr_set_bool ("allow-none", value);
        }
    }
    
    public Direction direction {
        get {
            return Direction.from_string (attrs["direction"]);
        }
        set {
            if (value == Direction.UNDEFINED) {
                attrs.remove ("direction");
            } else {
                attrs["direction"] = value.to_string ();
            }
        }
    }
    
    public bool caller_allocates {
        get {
            return attr_get_bool ("caller-allocates", false);
        }
        set {
            attr_set_bool ("caller-allocates", value);
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
    
    public TypeRef type_ref {
        owned get {
            return any_of<TypeRef> ();
        }
        set {
            remove_and_set (value);
        }
    }
}

