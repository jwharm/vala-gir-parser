/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
 * 
 * Parts of this file were copied and adapted from Vala 0.56:
 * Copyright (C) 2008-2012  Jürg Billeter
 * Copyright (C) 2011-2014  Luca Bruno
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

public enum GirMetadata.ArgumentType {
    SKIP,
    HIDDEN,
    NEW,
    TYPE,
    TYPE_ARGUMENTS,
    CHEADER_FILENAME,
    NAME,
    OWNED,
    UNOWNED,
    PARENT,
    NULLABLE,
    DEPRECATED,
    REPLACEMENT,
    DEPRECATED_SINCE,
    SINCE,
    ARRAY,
    ARRAY_LENGTH_IDX,
    ARRAY_NULL_TERMINATED,
    DEFAULT,
    OUT,
    REF,
    VFUNC_NAME,
    VIRTUAL,
    ABSTRACT,
    COMPACT,
    SEALED,
    SCOPE,
    STRUCT,
    THROWS,
    PRINTF_FORMAT,
    ARRAY_LENGTH_FIELD,
    SENTINEL,
    CLOSURE,
    DESTROY,
    CPREFIX,
    LOWER_CASE_CPREFIX,
    LOWER_CASE_CSUFFIX,
    ERRORDOMAIN,
    DESTROYS_INSTANCE,
    BASE_TYPE,
    FINISH_NAME,
    FINISH_INSTANCE,
    SYMBOL_TYPE,
    INSTANCE_IDX,
    EXPERIMENTAL,
    FEATURE_TEST_MACRO,
    FLOATING,
    TYPE_ID,
    TYPE_GET_FUNCTION,
    COPY_FUNCTION,
    FREE_FUNCTION,
    REF_FUNCTION,
    REF_SINK_FUNCTION,
    UNREF_FUNCTION,
    RETURN_VOID,
    RETURNS_MODIFIED_POINTER,
    DELEGATE_TARGET_CNAME,
    DESTROY_NOTIFY_CNAME,
    FINISH_VFUNC_NAME,
    NO_ACCESSOR_METHOD,
    NO_WRAPPER,
    CNAME,
    DELEGATE_TARGET,
    CTYPE;

    public static ArgumentType? from_string (string name) {
        var enum_class = (EnumClass) typeof(ArgumentType).class_ref ();
        var nick = name.replace ("_", "-");
        unowned GLib.EnumValue? enum_value = enum_class.get_value_by_nick (nick);
        if (enum_value != null) {
            ArgumentType value = (ArgumentType) enum_value.value;
            return value;
        }
        return null;
    }
}

public class GirMetadata.Argument {
    public Expression expression;
    public SourceReference source_reference;

    public bool used = false;

    public Argument (Expression expression, SourceReference? source_reference = null) {
        this.expression = expression;
        this.source_reference = source_reference;
    }
}

public class GirMetadata.MetadataSet : Metadata {
    public MetadataSet (string? selector, SourceReference? source_reference = null) {
        base ("", selector, source_reference);
    }

    public void add_sibling (Metadata metadata) {
        foreach (var child in metadata.children) {
            add_child (child);
        }

        // merge arguments and take precedence
        foreach (var key in metadata.args.keys) {
            args[key] = metadata.args[key];
        }

        // copy the source reference
        source_reference = metadata.source_reference;
    }
}

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
    public Gee.Map<ArgumentType,Argument> args = new Gee.HashMap<ArgumentType,Argument> ();
    public Gee.ArrayList<Metadata> children = new Gee.ArrayList<Metadata> ();

    public Metadata (string pattern,
                     string? selector = null,
                     SourceReference? source_reference = null) {
        this.pattern = pattern;
        this.pattern_spec = new PatternSpec (pattern);
        this.selector = selector;
        this.source_reference = source_reference;
    }

    public string to_string (int indent = 0) {
        StringBuilder sb = new StringBuilder ();
        /* indent */
        sb.append (string.nfill (indent, ' '));
        if (indent > 0) {
            sb.append (".");
        }

        /* pattern and selector */
        sb.append (pattern);
        if (selector != null) {
            sb.append ("#")
              .append (selector);
        }

        /* arguments */
        foreach (var key in args.keys) {
            string nick = key.to_string ()
                             .replace ("GIR_METADATA_ARGUMENT_TYPE_", "")
                             .down ();
            sb.append (" ")
              .append (nick);
            var value = args[key].expression.to_string ();
            if (value != "true") { /* omit "=true" */
                sb.append ("=")
                  .append (value);
            }
        }

        /* children */
        if (children.size == 1) { /* single child on same line */
            sb.append (".")
              .append (children[0].to_string ());
        } else {
            if (pattern == "") { /* hide the empty root node */
                foreach (var child in children) {
                    sb.append (child.to_string (indent));
                }
            } else {
                sb.append ("\n");
                foreach (var child in children) {
                    sb.append (child.to_string (indent + 2));
                }
            }
        }

        return sb.str;
    }

    public void add_child (Metadata metadata) {
        children.add (metadata);
    }

    public Metadata match_child (string name, string? selector = null) {
        var result = Metadata.empty;
        foreach (var metadata in children) {
            if ((selector == null || metadata.selector == null || metadata.selector == selector)
                    && metadata.pattern_spec.match_string (name)) {
                metadata.used = true;
                if (result == Metadata.empty) {
                    // first match
                    result = metadata;
                } else {
                    var ms = result as MetadataSet;
                    if (ms == null) {
                        // second match
                        ms = new MetadataSet (selector, metadata.source_reference);
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
        return args.has_key (key);
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
                // treat as `true'
                metadata.add_argument (arg_type, new Argument (
                    new BooleanLiteral (true, get_src (begin)), get_src (begin)));
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
