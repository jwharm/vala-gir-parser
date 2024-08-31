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

public class Gir.Signal : Node, InfoAttrs, DocElements, InfoElements, Callable {
    public bool detailed {
        get {
            return attr_get_bool ("detailed", false);
        }
        set {
            attr_set_bool ("detailed", value);
        }
    }
    
    public When when {
        get {
            return When.from_string (attrs["when"]);
        }
        set {
            if (value == When.UNDEFINED) {
                attrs.remove ("when");
            } else {
                attrs["when"] = value.to_string ();
            }
        }
    }
    
    public bool action {
        get {
            return attr_get_bool ("action", false);
        }
        set {
            attr_set_bool ("action", value);
        }
    }
    
    public bool no_hooks {
        get {
            return attr_get_bool ("no-hooks", false);
        }
        set {
            attr_set_bool ("no-hooks", value);
        }
    }
    
    public bool no_recurse {
        get {
            return attr_get_bool ("no-recurse", false);
        }
        set {
            attr_set_bool ("no-recurse", value);
        }
    }
    
    public string emitter {
        owned get {
            return attrs["emitter"];
        }
        set {
            attrs["emitter"] = value;
        }
    }
}
