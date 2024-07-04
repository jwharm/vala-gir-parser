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

public class Gir.Parameter : Node, DocElements {
	public string name {
		owned get {
			return attrs["name"];
		}
	}
	
	public bool nullable {
		get {
			return attr_bool ("nullable", false);
		}
	}
	
	public bool allow_none {
		get {
			return attr_bool ("allow-none", true);
		}
	}
	
	public bool introspectable {
		get {
			return attr_bool ("introspectable", true);
		}
	}
	
	public int closure {
		get {
			return attr_int ("closure", -1);
		}
	}
	
	public int destroy {
		get {
			return attr_int ("destroy", -1);
		}
	}
	
	public Scope scope {
		get {
			return Scope.from_string (attrs["scope"]);
		}
	}
	
	public Direction direction {
		get {
			return Direction.from_string (attrs["direction"]);
		}
	}
	
	public bool caller_allocates {
		get {
			return attr_bool ("caller-allocates", false);
		}
	}
	
	public bool optional {
		get {
			return attr_bool ("optional", false);
		}
	}
	
	public bool skip {
		get {
			return attr_bool ("skip", false);
		}
	}
	
	public TransferOwnership transfer_ownership {
		get {
			return TransferOwnership.from_string (attrs["transfer-ownership"]);
		}
	}
	
	public AnyType? anytype {
		owned get {
			return any_of (typeof (AnyType));
		}
	}
	
	public Varargs? varargs {
		owned get {
			return any_of (typeof (Varargs));
		}
	}
	
	public Gee.List<Attribute> attributes {
		owned get {
			return all_of (typeof (Attribute));
		}
	}
}

