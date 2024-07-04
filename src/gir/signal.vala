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

public class Gir.Signal : Node, InfoAttrs, DocElements, InfoElements {
	public string name {
		owned get {
			return attrs["name"];
		}
	}
	
	public bool detailed {
		get {
			return attr_bool ("detailed", false);
		}
	}
	
	public When? get_when () {
		return When.from_string (attrs["when"]);
	}
	
	public bool action {
		get {
			return attr_bool ("action", false);
		}
	}
	
	public bool no_hooks {
		get {
			return attr_bool ("no-hooks", false);
		}
	}
	
	public bool no_recurse {
		get {
			return attr_bool ("no-recurse", false);
		}
	}
	
	public string emitter {
		owned get {
			return attrs["emitter"];
		}
	}
	
	public Parameters? parameters {
		owned get {
			return any_of (typeof (Parameters));
		}
	}
	
	public ReturnValue? return_value {
		owned get {
			return any_of (typeof (ReturnValue));
		}
	}
}

