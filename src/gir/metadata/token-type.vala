/* vala-gir-parser
 * Copyright (C) 2025 Jan-Willem Harmannij
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

/**
 * The types of tokens that are read by the metadata scanner.
 */
public enum Gir.Metadata.TokenType {
    /**
     * A `.` character
     */
    DOT,

    /**
     * A `=` character
     */
    EQUAL,

    /**
     * A `#` character
     */
    HASH,

    /**
     * A pattern (glob), selector, argument name or argument value.
     * 
     * Valid characters for an identifier:
     * - Alphabetic letters (upper and lower case)
     * - Digits
     * - Parens `(` and `)`, used as `()` to clear/unset a gir attribute
     * - Underscore `_`, dash `-` and semicolon `:`
     * - Glob wildcards `?` and `*`
     */
    IDENTIFIER,

    /**
     * A double-quoted string. The quotes are not included in the
     * `Token.text()`
     */
    STRING,

    /**
     * A `' '` or `\t`
     * 
     * @see MetadataScanner#setSignificantWhitespace
     */
    WHITESPACE,

    /**
     * A `\n` character
     */
    NEW_LINE,

    /**
     * End of file
     */
    EOF;

    /**
     * Return the name of the TokenType, without any prefixes
     */
    public string name () {
        return to_string ().substring ("GIR_METADATA_TOKEN_TYPE_".length);
    }
}
