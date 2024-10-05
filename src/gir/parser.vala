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

using Vala;

public class Gir.Parser {
    private SourceFile source_file;
    private SourceLocation begin;
    private SourceLocation end;
    
    /**
     * Create a Gir Parser for the provided source file.
     *
     * @param source_file a valid Gir file
     */
    public Parser (SourceFile source_file) {
        this.source_file = source_file;
    }

    /**
     * Parse the provided Gir file into a tree of Gir Nodes.
     *
     * @return the repository node, or null in case the gir file is invalid
     */
    public Gir.Node? parse() {
        var reader = new MarkupReader (source_file.filename);
        
        /* Find the first START_ELEMENT token in the XML file */
        while (true) {
            var token_type = reader.read_token (out begin, out end);
            if (token_type == START_ELEMENT) {
                return parse_element (reader);
            } else if (token_type == EOF) {
                var source = new SourceReference (source_file, begin, end);
                Report.error (source, "No repository found");
                return null;
            }
        }
    }

    /* Parse one XML element (recursively), and return a new Gir Node */
    private Node parse_element (MarkupReader reader) {
        var tag = reader.name;
        var children = new Vala.ArrayList<Node> ();
        var attrs = reader.get_attributes ();
        var content = new StringBuilder ();
        var source = new SourceReference (source_file, begin, end);

        /* Keep parsing XML until an END_ELEMENT or EOF token is reached */
        while (true) {
            var token = reader.read_token (out begin, out end);
            if (token == MarkupTokenType.START_ELEMENT) {
                /* Recursively create a child node and add it to the list */
                Node node = parse_element (reader);
                children.add (node);
            } else if (token == MarkupTokenType.TEXT) {
                content.append (reader.content);
            } else {
                break;
            }
        }
        
        /* Create and return a new Gir Node */
        return new Gir.Node (tag, content.str.strip (), attrs, children, source);
    }
}
