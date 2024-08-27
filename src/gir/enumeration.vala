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

public class Gir.Enumeration : Node, InfoAttrs, DocElements, InfoElements, EnumBase {
	public override string name {
		owned get {
			return attrs["name"];
		}
		set {
			attrs["name"] = value;
		}
	}
	
	public override string c_type {
		owned get {
			return attrs["c:type"];
		}
		set {
			attrs["c:type"] = value;
		}
	}
	
	public override string? glib_type_name {
		owned get {
			return attrs["glib:type-name"];
		}
		set {
			attrs["glib:type-name"] = value;
		}
	}
	
	public override string? glib_get_type {
		owned get {
			return attrs["glib:get-type"];
		}
		set {
			attrs["glib:get-type"] = value;
		}
	}
	
	public string? glib_error_domain {
		owned get {
			return attrs["glib:error-domain"];
		}
		set {
			attrs["glib:error-domain"] = value;
		}
	}
	
	public override Gee.List<Member> members {
		owned get {
			return all_of (typeof (Member));
		}
	}
	
	public override Gee.List<Function> functions {
		owned get {
			return all_of (typeof (Function));
		}
	}
	
	public override Gee.List<FunctionInline> function_inlines {
		owned get {
			return all_of (typeof (FunctionInline));
		}
	}
}

