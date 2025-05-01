/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
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

public interface Gir.InfoAttrs : Node {
    protected abstract InfoAttrsValues info_attrs_values { get; set; }

    public bool introspectable {
        get { return info_attrs_values.introspectable; }
        set { info_attrs_values.introspectable = value; }
    }
    
    public bool deprecated {
        get { return info_attrs_values.deprecated; }
        set { info_attrs_values.deprecated = value; }
    }
    
    public string? deprecated_version {
        owned get { return info_attrs_values.deprecated_version; }
        set { info_attrs_values.deprecated_version = value; }
    }
    
    public string? version {
        owned get { return info_attrs_values.version; }
        set { info_attrs_values.version = value; }
    }
    
    public string? stability {
        owned get { return info_attrs_values.stability; }
        set { info_attrs_values.stability = value; }
    }
}

public struct Gir.InfoAttrsValues {
    bool introspectable;
    bool deprecated;
    string? deprecated_version;
    string? version;
    string? stability;
}
