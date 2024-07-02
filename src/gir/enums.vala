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

public enum Gir.Stability {
	STABLE,
	UNSTABLE,
	PRIVATE;
	
	public static Stability? from_string (string str) {
		if (str == "Stable")   return STABLE;
		if (str == "Unstable") return UNSTABLE;
		if (str == "Private")  return PRIVATE;
		return null;
	}
}

public enum Gir.TransferOwnership {
	NONE,
	CONTAINER,
	FULL;
	
	public static TransferOwnership? from_string (string str) {
		if (str == "none")      return NONE;
		if (str == "container") return CONTAINER;
		if (str == "full")      return FULL;
		return null;
	}
}

public enum Gir.When {
	FIRST,
	LAST,
	CLEANUP;
	
	public static When? from_string (string str) {
		if (str == "first")   return FIRST;
		if (str == "last")    return LAST;
		if (str == "cleanup") return CLEANUP;
		return null;
	}
}

public enum Gir.Scope {
	NOTIFIED,
	ASYNC,
	CALL,
	FOREVER;
	
	public static Scope? from_string (string str) {
		if (str == "notified") return NOTIFIED;
		if (str == "async")    return ASYNC;
		if (str == "call")     return CALL;
		if (str == "forever")  return FOREVER;
		return null;
	}
}

public enum Gir.Direction {
	IN,
	OUT,
	INOUT;
	
	public static Direction? from_string (string str) {
		if (str == "in")    return IN;
		if (str == "out")   return OUT;
		if (str == "inout") return INOUT;
		return null;
	}
}

