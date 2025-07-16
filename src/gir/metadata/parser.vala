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

using Gir;

/**
 * Parse a metadata file and copy the attributes in gir ``<attribute />``
 * elements.
 */
public class Gir.Metadata.Parser {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; set; }

    /* Metadata file name, contents and length */
    private string filename;
    private string contents;
    private size_t contents_length;

    /* The last read token */
    private string? token;

    /* The current position to read the next token */
    private int pos = 0;

    /**
     * Create a new metadata parser.
     */
    public Parser (Gir.Context context) {
        this.context = context;
    }

    /**
     * Parse a metadata file and copy the attributes in the gir repository with
     * the provided name and version.
     */
    public void parse (string metadata_filename, string name_and_version) {
        this.filename = metadata_filename;

        /* lookup gir repository */
        Repository repository = context.get_repository (name_and_version);
        if (repository == null) {
            context.report.error (null, "Repository `%s' not found", name_and_version);
            return;
        }

        /* read metadata file */
        try {
            FileUtils.get_contents (metadata_filename, out contents, out contents_length);
        } catch (FileError e) {
            context.report.error (null, "Unable to read file `%s': %s", metadata_filename, e.message);
            return;
        }

        if (contents_length > int.MAX) {
            context.report.error (null, "File `%s' is too large", metadata_filename);
            return;
        }

        /* Sanitize whitespace characters.
         * The tokenizer could be extended to deal with this, but a global
         * search/replace is a lot simpler. It's a bit inefficient, but still
         * fast enough, because metadata files are typically very small.
         */
        contents = contents
            .replace ("\t", " ")    // tabs to spaces
            .replace ("\r\n", "\n") // windows line endings
            .replace ("\r", "\n");  // mac line endings

        /* Begin parsing */
        parse_metadata (repository);
    }

    /* Parse all identifiers in the metadata file and match them against the
     * gir namespace. */
    private void parse_metadata (Repository repository) {
        next (); /* read first token */
        do {
            parse_identifier (repository.namespaces, false);
        } while (token != null); /* "token == null" means end of file */
    }

    /* Parse a metadata identifier and copy the attributes.
     *
     * Metadata identifiers can be nested (Foo.Bar.Baz) and can contain
     * wildcards (*.Bar.Baz). The "nodes" parameter is the list of gir nodes
     * matched by the parent metadata identifier.
     */
    private void parse_identifier (Gee.List<Gir.Node> nodes, bool is_subidentifier) {
        /* skip empty lines */
        while (token == "\n") {
            next ();
        }

        if (token == null) {
            return; /* end of file */
        }

        if (token == ".") {
            if (is_subidentifier) {
                next ();
            } else {
                context.report.error (get_source_reference (pos), "Unexpected '%s', expected a pattern.\n", token);
                token = null;
                return;
            }
        }

        /* remember the current position for logging purposes */
        int begin = pos + 1 - token.length;
        int end = pos;

        string identifier = token;
        string? selector = null;
        if (next () == "#") {
            selector = next ();
            end = pos;
            next();
        }

        var rule = new Rule (identifier, selector);
        var child_nodes = match_identifier (nodes, rule);

        /* Log unused entries */
        if (child_nodes.is_empty) {
            context.report.warn (get_source_reference (begin, end), "Rule does not match anything");
        }

        switch (token) {
        case ".":
            /* parse sub-identifiers on the same line (recursively) */
            next ();
            parse_identifier (child_nodes, false);
            break;
        case "\n":
            /* parse sub-identifiers on new lines (in a loop) */
            do {
                parse_identifier (child_nodes, true);
            } while (token == "\n" && peek() == ".");
            break;
        default:
            parse_attributes (child_nodes);
            break;
        }
    }

    /* Parse attributes and write the values in the gir nodes. */
    private void parse_attributes (Gee.List<Gir.Node> nodes) {
        while (! (token == null || token == "\n")) {
            string? key = token;
            next ();

            if (token == "=") {
                /* next token is the attribute value */
                set_attribute (nodes, key, read_value ());
                next ();
            } else {
                /* when no value is specified, default to "1" (true) */
                set_attribute (nodes, key, "1");
            }
        }

        if (token == "\n" || token == null) {
            return;
        }
    }

    /* Same as next() but don't update the global state. */
    private string? peek () {
        string? previous_token = token;
        int previous_pos = pos;

        string? new_token = next();
        while (new_token == "\n") {
            new_token = next();
        }

        token = previous_token;
        pos = previous_pos;
        return new_token;
    }

    /* Read a literal value from an attribute. */
    private string? read_value () {
        if (pos >= contents_length) {
            context.report.error (get_source_reference (pos - 1), "Missing attribute value");
            token = null;
            return token;
        }

        /* string literal */
        if (contents[pos] == '"') {
            int begin = ++pos;
            token = read_token ({'"', '\n'});

            /* empty string */
            if (token == "\"") {
                pos++;
                return "";
            }

            /* end of line */
            if (token == null || contents[pos + token.length] == '\n') {
                context.report.error (get_source_reference (begin, pos), "Unclosed string literal");
                return null;
            }

            pos += token.length + 1;
            return token;
        }

        /* read until whitespace and update the current position */
        token = read_token ({' ', '\n'});
        if (token != null) {
            pos += token.length;
        }

        return token;
    }

    /* Read the next token and update the current position.
     * Comments and spaces are ignored. */
    private string? next () {
        const char[] separators = {'.', '#', '/', '=', '"', ' ', '\n'};

        /* read the next token and update the current position */
        token = read_token (separators);
        if (token != null) {
            pos += token.length;
        }

        /* space: skip and return next token */
        if (token == " ") {
            return next ();
        }

        /* single line comment: skip and return "\n" */
        if (token == "/" && read_token (separators) == "/") {
            pos = contents.index_of ("\n", pos);
            token = pos == -1 ? null : "\n";
        }

        /* multi line comment: skip and return next token */
        if (token == "/" && read_token (separators) == "*") {
            pos = contents.index_of ("*/", pos) + 2;
            token = pos == 1 ? null : next ();
        }

        return token;
    }

    /* Return the next token.
     * Tokens are strings, separated by the provided separator characters.
     * Both the tokens and separators are returned.
     * The current position is not updated. */
    private string? read_token (char[] separators) {
        for (int end = pos; end < contents_length; end++) {
            if (contents[end] in separators) {
                if (pos == end) end++;
                return contents.substring (pos, end - pos);
            }
        }

        /* end of file */
        return null;
    }

    /* Match a metadata pattern against the child nodes of the provided nodes */
    private Gee.ArrayList<Gir.Node> match_identifier (Gee.List<Gir.Node> nodes, Rule rule) {
        var result = new Gee.ArrayList<Gir.Node> ();
        foreach (var node in nodes) {
            node.accept_children (new ForeachVisitor (child => {
                /* recursively descent into the <parameters> node */
                if (child is Parameters) {
                    return ForeachResult.CONTINUE;
                }

                /* when this rule matches the gir element, add it to the list */
                if (rule.matches (child)) {
                    result.add (child);
                }

                return ForeachResult.SKIP;
            }));
        }

        return result;
    }

    /* Create a gir attribute element in the provided gir nodes */
    private void set_attribute (Gee.List<Gir.Node> nodes, string key, string? val) {
        if (val == null) {
            context.report.error (get_source_reference (pos - 1), "Unexpected end of file");
            return;
        }

        if (val == "\n") {
            context.report.error (get_source_reference (pos - 1), "Unexpected end of line");
            return;
        }

        foreach (var node in nodes) {
            if (node is InfoElements) {
                var info_elements = (InfoElements) node;
                info_elements.attributes.add (new Attribute (key, val, null));
            } else if (node is Parameter) {
                var parameter = (Parameter) node;
                parameter.attributes.add (new Attribute (key, val, null));
            } else if (node is ReturnValue) {
                var parameter = (ReturnValue) node;
                parameter.attributes.add (new Attribute (key, val, null));
            }
        }
    }

    /* Get a Gir.Xml.Reference for use in error logging */
    private Gir.Xml.Reference get_source_reference (int pos_begin, int pos_end = -1) {
        Gir.Xml.SourceLocation begin = get_source_location (pos_begin);
        Gir.Xml.SourceLocation end = get_source_location (pos_end == -1 ? pos_begin : pos_end);
        return new Gir.Xml.Reference (filename, begin, end);
    }

    /* Find the line and column index */
    private Gir.Xml.SourceLocation get_source_location (int location) {
        int line = 1;
        int col = 0;
        for (int i = 0; i < location; i++) {
            if (contents[i] == '\n') {
                line++;
                col = 0;
            } else {
                col++;
            }
        }

        return Gir.Xml.SourceLocation (contents, line, col);
    }
}
