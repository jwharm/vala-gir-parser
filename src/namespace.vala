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

public class Gir.Namespace : Node {
	public string name {
		owned get {
			return attrs["name"];
		}
	}
	
	public string version {
		owned get {
			return attrs["version"];
		}
	}
	
	public string c_identifier_prefixes {
		owned get {
			return attrs["c:identifier-prefixes"];
		}
	}
	
	public string c_symbol_prefixes {
		owned get {
			return attrs["c:symbol-prefixes"];
		}
	}
	
	public string c_prefix {
		owned get {
			return attrs["c:prefix"];
		}
	}
	
	public string shared_library {
		owned get {
			return attrs["shared-library"];
		}
	}
	
	public Gee.List<Alias> aliases {
		owned get {
			return (Gee.List<Alias>) all_of (typeof (Alias));
		}
	}
	
	public Gee.List<Class> classes {
		owned get {
			return (Gee.List<Class>) all_of (typeof (Class));
		}
	}
	
	public Gee.List<Interface> interfaces {
		owned get {
			return (Gee.List<Interface>) all_of (typeof (Interface));
		}
	}
	
	public Gee.List<Record> records {
		owned get {
			return (Gee.List<Record>) all_of (typeof (Record));
		}
	}
	
	public Gee.List<Enumeration> enumerations {
		owned get {
			return (Gee.List<Enumeration>) all_of (typeof (Enumeration));
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
	
	public Gee.List<FunctionMacro> function_macros {
		owned get {
			return (Gee.List<FunctionMacro>) all_of (typeof (FunctionMacro));
		}
	}
	
	public Gee.List<Union> unions {
		owned get {
			return (Gee.List<Union>) all_of (typeof (Union));
		}
	}
	
	public Gee.List<Bitfield> bitfields {
		owned get {
			return (Gee.List<Bitfield>) all_of (typeof (Bitfield));
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
	
	public Gee.List<Attribute> attributes {
		owned get {
			return (Gee.List<Attribute>) all_of (typeof (Attribute));
		}
	}
	
	public Gee.List<Boxed> boxeds {
		owned get {
			return (Gee.List<Boxed>) all_of (typeof (Boxed));
		}
	}
	
	public Gee.List<Docsection> docsections {
		owned get {
			return (Gee.List<Docsection>) all_of (typeof (Docsection));
		}
	}
}

