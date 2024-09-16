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

public interface Gir.InfoAttrs : Node {
    public bool introspectable {
        get {
            return attr_get_bool ("introspectable", true);
        }
        set {
            attr_set_bool ("introspectable", value);
        }
    }
    
    public bool deprecated {
        get {
            return attr_get_bool ("deprecated", false);
        }
        set {
            attr_set_bool ("deprecated", value);
        }
    }
    
    public string deprecated_version {
        owned get {
            return attrs["deprecated-version"];
        }
        set {
            attrs["deprecated-version"] = value;
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
    
    public Stability stability {
        get {
            return Stability.from_string (attrs["stability"]);
        }
        set {
            if (value == Stability.UNDEFINED) {
                attrs.remove ("stability");
            } else {
                attrs["stability"] = value.to_string ();
            }
        }
    }
}

public interface Gir.DocElements : Node {
    public DocVersion? doc_version {
        owned get {
            return any_of<DocVersion> ();
        }
        set {
            remove_and_set (value);
        }
    }
    
    public DocStability? doc_stability {
        owned get {
            return any_of<DocStability> ();
        }
        set {
            remove_and_set (value);
        }
    }
    
    public Doc? doc {
        owned get {
            return any_of<Doc> ();
        }
        set {
            remove_and_set (value);
        }
    }
    
    public DocDeprecated? doc_deprecated {
        owned get {
            return any_of<DocDeprecated> ();
        }
        set {
            remove_and_set (value);
        }
    }
    
    public SourcePosition? SourcePosition {
        owned get {
            return any_of<SourcePosition> ();
        }
        set {
            remove_and_set (value);
        }
    }
}

