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

public class Gir.Class : Node, InfoAttrs, DocElements, InfoElements {
	public string name {
		owned get {
			return attrs["name"];
		}
	}
	
	public string glib_type_name {
		owned get {
			return attrs["glib:type-name"];
		}
	}
	
	public string glib_get_type {
		owned get {
			return attrs["glib:get-type"];
		}
	}
	
	public string? parent {
		owned get {
			return attrs["parent"];
		}
	}
	
	public string? glib_type_struct {
		owned get {
			return attrs["glib:type-struct"];
		}
	}
	
	public string? glib_ref_func {
		owned get {
			return attrs["glib:ref-func"];
		}
	}
	
	public string? glib_unref_func {
		owned get {
			return attrs["glib:unref-func"];
		}
	}
	
	public string? glib_set_value_func {
		owned get {
			return attrs["glib:set-value-func"];
		}
	}
	
	public string? glib_get_value_func {
		owned get {
			return attrs["glib:get-value-func"];
		}
	}
	
	public string? c_type {
		owned get {
			return attrs["c:type"];
		}
	}
	
	public string? c_symbol_prefix {
		owned get {
			return attrs["c:symbol-prefix"];
		}
	}
	
	public bool @abstract {
		get {
			return attr_bool ("abstract", false);
		}
	}
	
	public bool fundamental {
		get {
			return attr_bool ("fundamental", false);
		}
	}
	
	public bool final {
		get {
			return attr_bool ("final", false);
		}
	}
	
	public Gee.List<Implements> implements {
		owned get {
			return all_of (typeof (Implements));
		}
	}
	
	public Gee.List<Constructor> constructors {
		owned get {
			return all_of (typeof (Constructor));
		}
	}

	public Gee.List<Method> methods {
		owned get {
			return all_of (typeof (Method));
		}
	}
	
	public Gee.List<MethodInline> method_inlines {
		owned get {
			return all_of (typeof (MethodInline));
		}
	}
	
	public Gee.List<Function> functions {
		owned get {
			return all_of (typeof (Function));
		}
	}
	
	public Gee.List<FunctionInline> function_inlines {
		owned get {
			return all_of (typeof (FunctionInline));
		}
	}
	
	public Gee.List<VirtualMethod> virtual_methods {
		owned get {
			return all_of (typeof (VirtualMethod));
		}
	}
	
	public Gee.List<Field> fields {
		owned get {
			return all_of (typeof (Field));
		}
	}
	
	public Gee.List<Property> properties {
		owned get {
			return all_of (typeof (Property));
		}
	}
	
	public Gee.List<Signal> signals {
		owned get {
			return all_of (typeof (Signal));
		}
	}
	
	public Gee.List<Union> unions {
		owned get {
			return all_of (typeof (Union));
		}
	}
	
	public Gee.List<Constant> constants {
		owned get {
			return all_of (typeof (Constant));
		}
	}
	
	public Gee.List<Record> records {
		owned get {
			return all_of (typeof (Record));
		}
	}
	
	public Gee.List<Callback> callbacks {
		owned get {
			return all_of (typeof (Callback));
		}
	}
}

