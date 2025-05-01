/* vala-gir-parser
 * Copyright (C) 2025 Jan-Willem Harmannij
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

public interface Gir.CallableAttrs : Node {
    protected abstract CallableAttrsValues callable_attrs_values { get; set; }

    public bool introspectable {
        get { return callable_attrs_values.info_attrs_values.introspectable; }
        set { callable_attrs_values.info_attrs_values.introspectable = value; }
    }
    
    public bool deprecated {
        get { return callable_attrs_values.info_attrs_values.deprecated; }
        set { callable_attrs_values.info_attrs_values.deprecated = value; }
    }
    
    public string? deprecated_version {
        owned get { return callable_attrs_values.info_attrs_values.deprecated_version; }
        set { callable_attrs_values.info_attrs_values.deprecated_version = value; }
    }
    
    public string? version {
        owned get { return callable_attrs_values.info_attrs_values.version; }
        set { callable_attrs_values.info_attrs_values.version = value; }
    }
    
    public string? stability {
        owned get { return callable_attrs_values.info_attrs_values.stability; }
        set { callable_attrs_values.info_attrs_values.stability = value; }
    }

    public string name {
        owned get { return callable_attrs_values.name; }
        set { callable_attrs_values.name = value; }
    }
    
    public string? c_identifier {
        owned get { return callable_attrs_values.c_identifier; }
        set { callable_attrs_values.c_identifier = value; }
    }
    
    public Link<Callable> shadowed_by {
        owned get { return callable_attrs_values.shadowed_by; }
        set { callable_attrs_values.shadowed_by = value; }
    }
    
    public Link<Callable> shadows {
        owned get { return callable_attrs_values.shadows; }
        set { callable_attrs_values.shadows = value; }
    }
    
    public bool @throws {
        get { return callable_attrs_values.throws; }
        set { callable_attrs_values.throws = value; }
    }
    
    public string? moved_to {
        owned get { return callable_attrs_values.moved_to; }
        set { callable_attrs_values.moved_to = value; }
    }
    
    public Link<Callable> glib_async_func {
        owned get { return callable_attrs_values.glib_async_func; }
        set { callable_attrs_values.glib_async_func = value; }
    }
    
    public Link<Callable> glib_sync_func {
        owned get { return callable_attrs_values.glib_sync_func; }
        set { callable_attrs_values.glib_sync_func = value; }
    }
    
    public Link<Callable> glib_finish_func {
        owned get { return callable_attrs_values.glib_finish_func; }
        set { callable_attrs_values.glib_finish_func = value; }
    }
}

public struct Gir.CallableAttrsValues {
    InfoAttrsValues info_attrs_values;
    string name;
    string? c_identifier;
    Link<Callable> shadowed_by;
    Link<Callable> shadows;
    bool @throws;
    string? moved_to;
    Link<Callable> glib_async_func;
    Link<Callable> glib_sync_func;
    Link<Callable> glib_finish_func;
}