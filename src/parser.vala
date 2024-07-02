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
using Gee;

public class Gir.Parser {
    /**
     * Parse the provided Gir file into a tree of Gir Nodes.
     */
    public Node? parse (string filename) {
		var reader = new MarkupReader (filename);
		SourceLocation begin;
		SourceLocation end;
		
		while (true) {
			var token_type = reader.read_token (out begin, out end);
			if (token_type == START_ELEMENT) {
				return parse_element (reader);
			} else if (token_type == EOF) {
				critical ("No repository found");
				return null;
			}
		}
    }
    
    /* Parse one XML element (recursively), and return a new Gir Node */
    private Node parse_element (MarkupReader reader) {
        var element = reader.name;
        var children = new Gee.ArrayList<Node> ();
        var attrs =  to_gee (reader.get_attributes ());
        var content = new StringBuilder ();
		SourceLocation begin;
		SourceLocation end;
        
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
        
        /* Create and return a new Gir Node. */
        return create(element, attrs, children, content.str.strip());
    }

	/* The following method is very ugly. I'd prefer to create Gir nodes
	 * dynamically (the XML element name can easily be converted to the GType
	 * of the corresponding class), and then call
	 * ``Object.new (gtype, attrs: at, children: ch, content: co)``, but that
	 * didn't work because the classes aren't loaded.
	 */
    private static Node create(string element,
    						   Gee.Map<string, string> at,
    						   Gee.List<Node> ch,
    						   string co) {
		switch (element) {
		case "namespace":
			return new Namespace () {attrs = at, children = ch, content = co};
		case "repository":
			return new Repository () {attrs = at, children = ch, content = co};
		case "attribute":
			return new Attribute () {attrs = at, children = ch, content = co};
		case "c:include":
			return new CInclude () {attrs = at, children = ch, content = co};
		case "include":
			return new Include () {attrs = at, children = ch, content = co};
		case "package":
			return new Package () {attrs = at, children = ch, content = co};
		case "alias":
			return new Alias () {attrs = at, children = ch, content = co};
		case "interface":
			return new Interface () {attrs = at, children = ch, content = co};
		case "class":
			return new Class () {attrs = at, children = ch, content = co};
		case "glib:boxed":
			return new Boxed () {attrs = at, children = ch, content = co};
		case "record":
			return new Record () {attrs = at, children = ch, content = co};
		case "doc-version":
			return new DocVersion () {attrs = at, children = ch, content = co};
		case "doc-stability":
			return new DocStability () {attrs = at, children = ch, content = co};
		case "doc":
			return new Doc () {attrs = at, children = ch, content = co};
		case "doc-deprecated":
			return new DocDeprecated () {attrs = at, children = ch, content = co};
		case "source-position":
			return new SourcePosition () {attrs = at, children = ch, content = co};
		case "constant":
			return new Constant () {attrs = at, children = ch, content = co};
		case "property":
			return new Property () {attrs = at, children = ch, content = co};
		case "glib:signal":
			return new Signal () {attrs = at, children = ch, content = co};
		case "field":
			return new Field () {attrs = at, children = ch, content = co};
		case "callback":
			return new Callback () {attrs = at, children = ch, content = co};
		case "implements":
			return new Implements () {attrs = at, children = ch, content = co};
		case "prerequisite":
			return new Prerequisite () {attrs = at, children = ch, content = co};
		case "type":
			return new TypeRef () {attrs = at, children = ch, content = co};
		case "array":
			return new Array () {attrs = at, children = ch, content = co};
		case "constructor":
			return new Constructor () {attrs = at, children = ch, content = co};
		case "varargs":
			return new Varargs () {attrs = at, children = ch, content = co};
		case "parameters":
			return new Parameters () {attrs = at, children = ch, content = co};
		case "parameter":
			return new Parameter () {attrs = at, children = ch, content = co};
		case "instance-parameter":
			return new InstanceParameter () {attrs = at, children = ch, content = co};
		case "return-value":
			return new ReturnValue () {attrs = at, children = ch, content = co};
		case "function":
			return new Function () {attrs = at, children = ch, content = co};
		case "function-inline":
			return new FunctionInline () {attrs = at, children = ch, content = co};
		case "function-macro":
			return new FunctionMacro () {attrs = at, children = ch, content = co};
		case "method":
			return new Method () {attrs = at, children = ch, content = co};
		case "method-inline":
			return new MethodInline () {attrs = at, children = ch, content = co};
		case "virtual-method":
			return new VirtualMethod () {attrs = at, children = ch, content = co};
		case "union":
			return new Union () {attrs = at, children = ch, content = co};
		case "bitfield":
			return new Bitfield () {attrs = at, children = ch, content = co};
		case "enumeration":
			return new Enumeration () {attrs = at, children = ch, content = co};
		case "member":
			return new Member () {attrs = at, children = ch, content = co};
		case "docsection":
			return new Docsection () {attrs = at, children = ch, content = co};
		default:
			warning ("Unsupported element %s", element);
			return new Node () {attrs = at, children = ch, content = co};
		}
	}
}

