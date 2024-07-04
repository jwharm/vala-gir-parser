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

public class Gir.Property : Node, InfoAttrs, DocElements, InfoElements {
	public string name {
		owned get {
			return attrs["name"];
		}
	}
	
	public bool writable {
		get {
			return attr_bool ("writable", false);
		}
	}
	
	public bool readable {
		get {
			return attr_bool ("readable", false);
		}
	}
	
	public bool @construct {
		get {
			return attr_bool ("construct", false);
		}
	}
	
	public bool construct_only {
		get {
			return attr_bool ("construct-only", false);
		}
	}
	
	public string? setter {
		owned get {
			return attrs["setter"];
		}
	}
	
	public string? getter {
		owned get {
			return attrs["getter"];
		}
	}
	
	public string? default_value {
		owned get {
			return attrs["default-value"];
		}
	}
	
	public TransferOwnership transfer_ownership {
		get {
			return TransferOwnership.from_string (attrs["transfer-ownership"]);
		}
	}
	
	public AnyType anytype {
		owned get {
			return any_of (typeof (AnyType));
		}
	}
}

