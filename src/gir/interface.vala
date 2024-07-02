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

public class Gir.Interface : Node, InfoAttrs, DocElements, InfoElements {
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
	
	public string? c_symbol_prefix {
		owned get {
			return attrs["c:symbol-prefix"];
		}
	}
	
	public string? c_type {
		owned get {
			return attrs["c:type"];
		}
	}
	
	public string? glib_type_struct {
		owned get {
			return attrs["glib:type-struct"];
		}
	}
	
	public Gee.List<Prerequisite> prerequisites {
		owned get {
			return (Gee.List<Prerequisite>) all_of (typeof (Prerequisite));
		}
	}
	
	public Gee.List<Implements> implements {
		owned get {
			return (Gee.List<Implements>) all_of (typeof (Implements));
		}
	}
	
	public Gee.List<Function> functions {
		owned get {
			return (Gee.List<Function>) all_of (typeof (Function));
		}
	}
	
	public Gee.List<FunctionInline> function_inlines {
		owned get {
			return (Gee.List<FunctionInline>) all_of (typeof (FunctionInline));
		}
	}
	
    public Constructor? constructor {
		owned get {
			return (Constructor?) any_of (typeof (Constructor));
		}
	}
	
	public Gee.List<Method> methods {
		owned get {
			return (Gee.List<Method>) all_of (typeof (Method));
		}
	}
	
	public Gee.List<MethodInline> method_inlines {
		owned get {
			return (Gee.List<MethodInline>) all_of (typeof (MethodInline));
		}
	}
	
	public Gee.List<VirtualMethod> virtual_methods {
		owned get {
			return (Gee.List<VirtualMethod>) all_of (typeof (VirtualMethod));
		}
	}
	
	public Gee.List<Field> fields {
		owned get {
			return (Gee.List<Field>) all_of (typeof (Field));
		}
	}
	
	public Gee.List<Property> properties {
		owned get {
			return (Gee.List<Property>) all_of (typeof (Property));
		}
	}
	
	public Gee.List<Signal> signals {
		owned get {
			return (Gee.List<Signal>) all_of (typeof (Signal));
		}
	}
	
	public Gee.List<Callback> callbacks {
		owned get {
			return (Gee.List<Callback>) all_of (typeof (Callback));
		}
	}
	
	public Gee.List<Constant> constants {
		owned get {
			return (Gee.List<Constant>) all_of (typeof (Constant));
		}
	}
}

