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

public interface Gir.CallableAttrs : Node, InfoAttrs {
    public abstract string name                     { owned get; set; }
    public abstract string? c_identifier            { owned get; set; }
    public abstract Link<Callable> shadowed_by      { owned get; set; }
    public abstract Link<Callable> shadows          { owned get; set; }
    public abstract bool @throws                    { get; set; }
    public abstract string? moved_to                { owned get; set; }
    public abstract Link<Callable> glib_async_func  { owned get; set; }
    public abstract Link<Callable> glib_sync_func   { owned get; set; }
    public abstract Link<Callable> glib_finish_func { owned get; set; }

    internal void init_callable_attrs (CallableAttrsParameters parameters) {
        init_info_attrs (parameters.info_attrs_parameters);
        this.name = parameters.name;
        this.c_identifier = parameters.c_identifier;
        this.shadowed_by = parameters.shadowed_by;
        this.shadows = parameters.shadows;
        this.throws = parameters.throws;
        this.moved_to = parameters.moved_to;
        this.glib_async_func = parameters.glib_async_func;
        this.glib_sync_func = parameters.glib_sync_func;
        this.glib_finish_func = parameters.glib_finish_func;
    }
}

public struct Gir.CallableAttrsParameters {
    InfoAttrsParameters info_attrs_parameters;
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
