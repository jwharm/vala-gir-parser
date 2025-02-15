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

public class Gir.Array : Node, AnyType {
    public bool zero_terminated {
        get {
            return attr_get_bool ("zero-terminated", false);
        }
        set {
            attr_set_bool ("zero-terminated", value);
        }
    }
    
    public int fixed_size {
        get {
            return attr_get_int ("fixed-size", -1);
        }
        set {
            attr_set_int ("fixed-size", value);
        }
    }
    
    public bool introspectable {
        get {
            return attr_get_bool ("introspectable", true);
        }
        set {
            attr_set_bool ("introspectable", value);
        }
    }
    
    public int length {
        get {
            return attr_get_int ("length", -1);
        }
        set {
            attr_set_int ("length", value);
        }
    }
    
    public string c_type {
        owned get {
            return attrs["c:type"];
        }
        set {
            attrs["c:type"] = value;
        }
    }
    
    public override Vala.List<AnyType> anytype {
        owned get {
            return all_of<AnyType> ();
        }
    }

    public override void accept (GirVisitor visitor) {
        visitor.visit_array (this);
    }
}

