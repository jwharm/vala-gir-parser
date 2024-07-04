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

public interface Gir.InfoAttrs : Node {
	public bool introspectable {
		get {
			return attr_bool ("introspectable", true);
		}
	}
	
	public bool deprecated {
		get {
			return attr_bool ("deprecated", false);
		}
	}
	
	public string deprecated_version {
		owned get {
			return attrs["deprecated-version"];
		}
	}
	
	public string version {
		owned get {
			return attrs["version"];
		}
	}
	
	public Stability? get_stability () {
		return Stability.from_string (attrs["stability"]);
	}
}

public interface Gir.DocElements : Node {
	public DocVersion? doc_version {
		owned get {
			return any_of (typeof (DocVersion));
		}
	}
	
	public DocStability? doc_stability {
		owned get {
			return any_of (typeof (DocStability));
		}
	}
	
	public Doc? doc {
		owned get {
			return any_of (typeof (Doc));
		}
	}
	
	public DocDeprecated? doc_deprecated {
		owned get {
			return any_of (typeof (DocDeprecated));
		}
	}
	
	public SourcePosition? SourcePosition {
		owned get {
			return any_of (typeof (SourcePosition));
		}
	}
}

