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
 * Lexical scanner for metadata files, loosely based on the Scanner example in
 * chapter 4 of the book "Crafting Interpreters" by Robert Nystrom.
 * 
 * The scanner reads an input string, and turns it into a stream of tokens. The
 * tokens are then processed by the parser, to build a list of metadata rules.
 * 
 * The scanner is designed to be used in a loop that requests new tokens by
 * calling `next ()`, until `TokenType.EOF` is returned.
 */
public class Gir.Metadata.Scanner {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; set; }

    /**
     * Enable or disable `WHITESPACE` tokens for spaces and tabs. This is
     * initially disabled.
     */
    public bool significant_whitespace { get; set; default = false; }

    // Metadata filename and contents
    private string filename;
    private string contents;

    // The start of the current token and the current position
    private int start = 0;
    private int current = 0;

    /**
     * Create a new lexical scanner for metadata files.
     *
     * @param context  the Gir Context
     * @param filename the metadata filename, only used for logging purposes
     * @param contents the contents of the metadata file
     */
    public Scanner (Gir.Context context, string filename, string contents) {
        this.context = context;
        this.filename = filename;
        this.contents = contents;
    }

    /**
     * Scan and return the next token. When there are no more tokens to read,
     * all subsequent calls will return an "end-of-file" token (with type
     * {@link TokenType.EOF}).
     *
     * @return the scanned token
     */
    public Token next () {
        if (is_at_end ()) {
            return create_token (EOF);
        }
        
        start = current;
        char c = advance ();
        switch (c) {
            case '\r':
                // skipped
                return next ();
            case ' ':
            case '\t':
                return significant_whitespace ? create_token (WHITESPACE) : next ();
            case '.':
                return create_token (DOT);
            case '=':
                return create_token (EQUAL);
            case '#':
                return create_token (HASH);
            case '\n':
                return create_token (NEW_LINE);
            case '"':
                return scan_string ();
            case '/':
                if (match ('/')) {
                    skip_single_line_comment ();
                } else if (match ('*')) {
                    skip_multi_line_comment ();
                } else {
                    context.report.error (get_source_reference (), "Unexpected character");
                }

                return next ();
            default:
                if (is_valid (c)) {
                    return scan_identifier ();
                }

                context.report.error (get_source_reference (), "Unexpected character");
                return next ();
        }
    }

    // End of file?
    private bool is_at_end () {
        return current >= contents.length;
    }

    // Return the next char, and update the current position
    private char advance () {
        return contents[current++];
    }

    // Return the next char, but don't update anything
    private char peek () {
        if (is_at_end ()) {
            return '\0';
        }

        return contents[current];
    }

    // Advance only if the next char matches expectation
    private bool match (char expected) {
        if (peek () != expected) {
            return false;
        }

        advance ();
        return true;
    }

    // Read an IDENTIFIER token
    private Token scan_identifier () {
        while (is_valid (peek ())) {
            advance ();
        }

        return create_token (IDENTIFIER);
    }

    private bool is_valid (char c) {
        return (c >= 'a' && c <= 'z') ||
               (c >= 'A' && c <= 'Z') ||
               (c >= '0' && c <= '9') ||
                c == '(' || c == ')' ||
                c == '_' || c == '-' || c == ':' ||
                c == '?' || c == '*';
    }

    // Read a STRING token, such as "a string". The quotes are omitted.
    private Token scan_string () {
        while (peek () != '"' && peek () != '\n' && !is_at_end ()) {
            char c = advance ();
            if (c == '\\') {
                match ('"'); // handle escaped quotes
            }
        }
        
        if (peek () == '\n' || is_at_end ()) {
            context.report.error (get_source_reference (), "Unterminated string");
        } else {
            advance (); // The closing '"'
        }

        // Trim the surrounding quotes
        string text = contents.substring (start + 1, start - (current - 1));
        return {STRING, text, start};
    }

    // Skip past a '// ...' comment
    private void skip_single_line_comment () {
        while (!is_at_end () && peek () != '\n') {
            advance ();
        }
    }

    // Skip past a  '/* ... */' comment
    private void skip_multi_line_comment () {
        char c = 0;
        do {
            if (is_at_end ()) {
                context.report.error (get_source_reference (), "Unterminated comment");
                return;
            }

            c = advance ();
        } while (! (c == '*' && match ('/')));
    }

    // Create a Token with the scanned characters
    private Token create_token (TokenType type) {
        return {type, contents.substring (start, current - start), current};
    }

    /* Get a Gir.Xml.Reference for use in error logging */
    public Gir.Xml.Reference get_source_reference () {
        Gir.Xml.SourceLocation begin = get_source_location (start);
        Gir.Xml.SourceLocation end = get_source_location (current - 1);
        return new Gir.Xml.Reference (filename, begin, end);
    }

    /* Find the line and column index */
    private Gir.Xml.SourceLocation get_source_location (int location) {
        int line = 1;
        int col = 1;
        for (int i = 0; i < location; i++) {
            if (contents[i] == '\n') {
                line++;
                col = 1;
            } else {
                col++;
            }
        }

        return Gir.Xml.SourceLocation (contents, line, col);
    }
}