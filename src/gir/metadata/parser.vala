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
 * Parser for metadata files. The parser uses a Gir.Metadata.Scanner to tokenize
 * the metadata file contents, and builds a tree of metadata rules.
 * 
 * Grammar:
 * ```
 * metadata ::= [ rule [ '\n' relativerule ]* ]
 * rule ::= pattern ' ' [ args ]
 * relativerule ::= '.' rule
 * pattern ::= glob [ '#' selector ] [ '.' pattern ]
 * ```
 */
 public class Gir.Metadata.Parser {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; set; }

    // A "root" rule can have multiple "relative" rules on the following lines.
    private enum Relation {
        ROOT,
        RELATIVE
    }

    // The metadata scanner
    private Scanner scanner;

    // The last read token
    private Token token;

    /**
     * Create a new metadata parser.
     *
     * @param context the Gir Context
     */
    public Parser (Gir.Context context) {
        this.context = context;
    }

    /**
     * Parse the metadata file and create a list of rules. This function will
     * loop until the entire file has been parsed.
     * 
     * @param filename the metadata filename, only used for logging purposes
     * @return the rules list
     */
     public Gee.List<Rule> parse(string filename) {
        string contents = read_file_contents (filename);
        scanner = new Scanner (context, filename, contents);

        Gee.List<Rule> rules = new Gee.ArrayList<Rule>();

        // Scan the first token
        next ();

        while (true) {
            Rule? rule = parse_rule (Relation.ROOT);
            if (rule == null) {
                break;
            }
            
            rules.add (rule);
        }

        return rules;
    }

    // Read string contents from a file
    private string? read_file_contents (string filename) {
        try {
            string contents;
            size_t contents_length;
            FileUtils.get_contents (filename, out contents, out contents_length);
            return contents;
        } catch (FileError e) {
            context.report.error (null, "Unable to read file `%s': %s", filename, e.message);
            return null;
        }
    }

    // Parse a rule, with all rules below it. Return null at end of file.
    private Rule? parse_rule (Relation relation) {
        string glob;
        string? selector = null;
        Gee.Map<string, string?> args = new Gee.HashMap<string, string?> ();
        Gee.List<Rule> children = new Gee.ArrayList<Rule> ();
        Gir.Xml.Reference source;

        // Skip empty lines
        while (token.type == NEW_LINE) {
            next ();
        }

        // Skip leading '.'
        if (token.type == DOT) {
            next ();
        }

        // End of file?
        if (token.type == EOF) {
            return null;
        }

        // Read glob pattern
        expect ({IDENTIFIER});
        glob = token.text;
        source = scanner.get_source_reference ();
        next ();

        // Read #selector
        if (token.type == HASH) {
            next ();
            expect ({IDENTIFIER});
            selector = token.text;
            next ();
        }

        // Recursively parse rules on the same line
        if (token.type == DOT) {
            children.add (parse_rule (relation));
            return new Rule (glob, selector, args, children, source);
        }

        // Parse argument names and values
        while (token.type == IDENTIFIER) {
            string name = token.text;
            next ();
            string? value = token.type == EQUAL ? read_argument_value () : null;
            args[name] = value;
        }

        // We should be at the end of the line by now
        expect ({NEW_LINE, EOF});

        // Parse relative rules (starting with a dot) on following lines
        if (relation == Relation.ROOT) {
            while (true) {
                // Skip empty lines
                while (token.type == NEW_LINE) {
                    next ();
                }

                // Scan relative rule
                if (token.type == DOT) {
                    children.add (parse_rule (Relation.RELATIVE));
                } else {
                    break;
                }
            }
        }

        return new Rule (glob, selector, args, children, source);
    }

    // Scan the next token and store it in a global variable
    private void next () {
        token = scanner.next ();
    }

    // Log an error if the token doesn't have any of the expected types
    private void expect (TokenType[] expected) {
        foreach (TokenType type in expected) {
            if (token.type == type) return;
        }

        string[] strings = {};
        foreach (TokenType type in expected) {
            strings += type.name ();
        }

        string message = "Invalid token " + token.type.name () +
                ", expected " + string.joinv (" or ", strings);

        context.report.error (scanner.get_source_reference (), message);
    }

    /* Arguments like 'foo=1.0' contain reserved tokens, such as dots. The
     * scanner supports properly quoted strings like 'foo="1.0"', but otherwise
     * we must concatenate all tokens until the next whitespace. */
    private string read_argument_value () {
        next ();
        expect ({STRING, IDENTIFIER});
        StringBuilder value = new StringBuilder();

        if (token.type != STRING) {
            // Read tokens until whitespace
            scanner.significant_whitespace = true;
            while (token.type != WHITESPACE && token.type != NEW_LINE && token.type != EOF) {
                value.append (token.text);
                next ();
            }
            scanner.significant_whitespace = false;
        }

        if (token.type != NEW_LINE && token.type != EOF) {
            next ();
        }

        return value.str;
    }
}
