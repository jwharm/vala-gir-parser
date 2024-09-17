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

public class GirMetadata.MetadataParser {
    /**
        * Grammar:
        * metadata ::= [ rule [ '\n' relativerule ]* ]
        * rule ::= pattern ' ' [ args ]
        * relativerule ::= '.' rule
        * pattern ::= glob [ '#' selector ] [ '.' pattern ]
        */
    private Metadata tree = new Metadata ("");
    private Vala.Scanner scanner;
    private SourceLocation begin;
    private SourceLocation end;
    private SourceLocation old_end;
    private Vala.TokenType current;
    private Metadata parent_metadata;

    public MetadataParser () {
        tree.used = true;
    }

    SourceReference get_current_src () {
        return new SourceReference (scanner.source_file, begin, end);
    }

    SourceReference get_src (SourceLocation begin, SourceLocation? end = null) {
        var e = this.end;
        if (end != null) {
            e = end;
        }
        return new SourceReference (scanner.source_file, begin, e);
    }

    public Metadata parse_metadata (SourceFile metadata_file) {
        scanner = new Vala.Scanner (metadata_file);
        next ();
        while (current != EOF) {
            if (!parse_rule ()) {
                return Metadata.empty;
            }
        }
        return tree;
    }

    Vala.TokenType next () {
        old_end = end;
        current = scanner.read_token (out begin, out end);
        return current;
    }

    bool has_space () {
        return old_end.pos != begin.pos;
    }

    bool has_newline () {
        return old_end.line != begin.line;
    }

    string get_string (SourceLocation? begin = null, SourceLocation? end = null) {
        var b = this.begin;
        var e = this.end;
        if (begin != null) {
            b = begin;
        }
        if (end != null) {
            e = end;
        }
        return ((string) b.pos).substring (0, (int) (e.pos - b.pos));
    }

    string? parse_identifier (bool is_glob) {
        var begin = this.begin;

        if (current == DOT || current == HASH) {
            if (is_glob) {
                Report.error (get_src (begin), "expected glob-style pattern");
            } else {
                Report.error (get_src (begin), "expected identifier");
            }
            return null;
        }

        if (is_glob) {
            while (current != EOF && current != DOT && current != HASH) {
                next ();
                if (has_space ()) {
                    break;
                }
            }
        } else {
            next ();
        }

        return get_string (begin, old_end);
    }

    string? parse_selector () {
        if (current != HASH || has_space ()) {
            return null;
        }
        next ();

        return parse_identifier (false);
    }

    Metadata? parse_pattern () {
        Metadata metadata;
        bool is_relative = false;
        if (current == IDENTIFIER || current == STAR) {
            // absolute pattern
            parent_metadata = tree;
        } else {
            // relative pattern
            if (current != DOT) {
                Report.error (get_current_src (), "expected pattern or `.', got `%s'", current.to_string ());
                return null;
            }
            next ();
            is_relative = true;
        }

        if (parent_metadata == null) {
            Report.error (get_current_src (), "cannot determinate parent metadata");
            return null;
        }

        SourceLocation begin = this.begin;
        var pattern = parse_identifier (true);
        if (pattern == null) {
            return null;
        }
        metadata = new Metadata (pattern, parse_selector (), get_src (begin));
        parent_metadata.add_child (metadata);

        while (current != EOF && !has_space ()) {
            if (current != DOT) {
                Report.error (get_current_src (), "expected `.' got `%s'", current.to_string ());
                break;
            }
            next ();

            begin = this.begin;
            pattern = parse_identifier (true);
            if (pattern == null) {
                return null;
            }
            var child = new Metadata (pattern, parse_selector (), get_src (begin, old_end));
            metadata.add_child (child);
            metadata = child;
        }
        if (!is_relative) {
            parent_metadata = metadata;
        }

        return metadata;
    }

    Expression? parse_expression () {
        var begin = this.begin;
        var src = get_current_src ();
        Expression expr = null;
        switch (current) {
        case NULL:
            expr = new NullLiteral (src);
            break;
        case TRUE:
            expr = new BooleanLiteral (true, src);
            break;
        case FALSE:
            expr = new BooleanLiteral (false, src);
            break;
        case MINUS:
            next ();
            var inner = parse_expression ();
            if (inner == null) {
                Report.error (src, "expected expression after `-', got `%s'", current.to_string ());
            } else {
                expr = new UnaryExpression (UnaryOperator.MINUS, inner, get_src (begin));
            }
            return expr;
        case INTEGER_LITERAL:
            expr = new IntegerLiteral (get_string (), src);
            break;
        case REAL_LITERAL:
            expr = new RealLiteral (get_string (), src);
            break;
        case STRING_LITERAL:
            expr = new StringLiteral (get_string (), src);
            break;
        case IDENTIFIER:
            expr = new MemberAccess (null, get_string (), src);
            while (next () == DOT) {
                if (next () != IDENTIFIER) {
                    Report.error (get_current_src (), "expected identifier got `%s'", current.to_string ());
                    break;
                }
                expr = new MemberAccess (expr, get_string (), get_current_src ());
            }
            return expr;
        case OPEN_PARENS:
            // empty tuple => no expression
            if (next () != CLOSE_PARENS) {
                Report.error (get_current_src (), "expected `)', got `%s'", current.to_string ());
                break;
            }
            expr = new Tuple (src);
            break;
        default:
            Report.error (src, "expected literal or symbol got %s", current.to_string ());
            break;
        }
        next ();
        return expr;
    }

    bool parse_args (Metadata metadata) {
        while (current != EOF && has_space () && !has_newline ()) {
            SourceLocation begin = this.begin;
            var id = parse_identifier (false);
            if (id == null) {
                return false;
            }
            var arg_type = ArgumentType.from_string (id);
            if (arg_type == null) {
                Report.warning (get_src (begin, old_end), "unknown argument `%s'", id);
                continue;
            }

            if (current != ASSIGN) {
                // threat as `true'
                metadata.add_argument (arg_type, new Argument (new BooleanLiteral (true, get_src (begin)), get_src (begin)));
                continue;
            }
            next ();

            Expression expr = parse_expression ();
            if (expr == null) {
                return false;
            }
            metadata.add_argument (arg_type, new Argument (expr, get_src (begin)));
        }

        return true;
    }

    bool parse_rule () {
        var old_end = end;
        var metadata = parse_pattern ();
        if (metadata == null) {
            return false;
        }

        if (current == EOF || old_end.line != end.line) {
            // eof or new rule
            return true;
        }
        return parse_args (metadata);
    }
}
