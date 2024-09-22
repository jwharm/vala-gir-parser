/* valagirparser.vala
 *
 * Copyright (C) 2008-2012  Jürg Billeter
 * Copyright (C) 2011-2014  Luca Bruno
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 * 	Luca Bruno <lucabru@src.gnome.org>
 */

using Vala;

public class GirMetadata.Metadata {
    private static Metadata _empty = null;
    public static Metadata empty {
        get {
            if (_empty == null) {
                _empty = new Metadata ("");
            }
            return _empty;
        }
    }

    public string pattern;
    public PatternSpec pattern_spec;
    public string? selector;
    public SourceReference source_reference;

    public bool used = false;
    public Vala.Map<ArgumentType,Argument> args = new HashMap<ArgumentType,Argument> ();
    public ArrayList<Metadata> children = new ArrayList<Metadata> ();

    public Metadata (string pattern, string? selector = null, SourceReference? source_reference = null) {
        this.pattern = pattern;
        this.pattern_spec = new PatternSpec (pattern);
        this.selector = selector;
        this.source_reference = source_reference;
    }

    public string to_string (int indent = 0) {
        StringBuilder sb = new StringBuilder ();
        sb.append (string.nfill (indent, ' '));
        sb.append (pattern);
        foreach (var key in args.get_keys ()) {
            string nick = key.to_string ()
                             .replace ("GIR_METADATA_ARGUMENT_TYPE_", "")
                             .down ();
            sb.append (" ").append(nick);
        }
        sb.append("\n");
        foreach (var child in children) {
            sb.append (child.to_string(indent + 2));
        }
        return sb.str;
    }

    public void add_child (Metadata metadata) {
        children.add (metadata);
    }

    public Metadata match_child (string name, string? selector = null) {
        var result = Metadata.empty;
        foreach (var metadata in children) {
            if ((selector == null || metadata.selector == null || metadata.selector == selector) && metadata.pattern_spec.match_string (name)) {
                metadata.used = true;
                if (result == Metadata.empty) {
                    // first match
                    result = metadata;
                } else {
                    var ms = result as MetadataSet;
                    if (ms == null) {
                        // second match
                        ms = new MetadataSet (selector);
                        ms.add_sibling (result);
                    }
                    ms.add_sibling (metadata);
                    result = ms;
                }
            }
        }
        return result;
    }

    public void add_argument (ArgumentType key, Argument value) {
        args.set (key, value);
    }

    public bool has_argument (ArgumentType key) {
        return args.contains (key);
    }

    public Expression? get_expression (ArgumentType arg) {
        var val = args.get (arg);
        if (val != null) {
            val.used = true;
            return val.expression;
        }
        return null;
    }

    public string? get_string (ArgumentType arg) {
        var lit = get_expression (arg) as StringLiteral;
        if (lit != null) {
            return lit.eval ();
        }
        return null;
    }

    public int get_integer (ArgumentType arg) {
        var unary = get_expression (arg) as UnaryExpression;
        if (unary != null && unary.operator == UnaryOperator.MINUS) {
            var lit = unary.inner as IntegerLiteral;
            if (lit != null) {
                return -int.parse (lit.value);
            }
        } else {
            var lit = get_expression (arg) as IntegerLiteral;
            if (lit != null) {
                return int.parse (lit.value);
            }
        }

        return 0;
    }

    public bool get_bool (ArgumentType arg, bool default_value = false) {
        var lit = get_expression (arg) as BooleanLiteral;
        if (lit != null) {
            return lit.value;
        }
        return default_value;
    }

    public SourceReference? get_source_reference (ArgumentType arg) {
        var val = args.get (arg);
        if (val != null) {
            return val.source_reference;
        }
        return null;
    }
}
