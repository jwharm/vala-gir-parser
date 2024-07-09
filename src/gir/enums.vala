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

public enum Gir.Stability {
	UNDEFINED,
	STABLE,
	UNSTABLE,
	PRIVATE;
	
	public static Stability from_string (string? str) {
		switch (str) {
			case "Stable":   return STABLE;
			case "Unstable": return UNSTABLE;
			case "Private":  return PRIVATE;
			default:         return UNDEFINED;
		}
	}
}

public enum Gir.TransferOwnership {
	UNDEFINED,
	NONE,
	CONTAINER,
	FULL;
	
	public static TransferOwnership from_string (string? str) {
		switch (str) {
			case "none":      return NONE;
			case "container": return CONTAINER;
			case "full":      return FULL;
			default:          return UNDEFINED;
		}
	}
}

public enum Gir.When {
	UNDEFINED,
	FIRST,
	LAST,
	CLEANUP;
	
	public static When from_string (string? str) {
		switch (str) {
			case "first":   return FIRST;
			case "last":    return LAST;
			case "cleanup": return CLEANUP;
			default:        return UNDEFINED;
		}
	}
}

public enum Gir.Scope {
	UNDEFINED,
	NOTIFIED,
	ASYNC,
	CALL,
	FOREVER;
	
	public static Scope from_string (string? str) {
		switch (str) {
			case "notified": return NOTIFIED;
			case "async":    return ASYNC;
			case "call":     return CALL;
			case "forever":  return FOREVER;
			default:         return UNDEFINED;
		}
	}
}

public enum Gir.Direction {
	UNDEFINED,
	IN,
	OUT,
	INOUT;
	
	public static Direction from_string (string? str) {
		switch (str) {
			case "in":    return IN;
			case "out":   return OUT;
			case "inout": return INOUT;
			default:      return UNDEFINED;
		}
	}
}

