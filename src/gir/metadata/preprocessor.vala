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
 * A basic preprocessor for `#if`, `#elif`, `#else` and `#endif` directives in
 * metadata files.
 */
public class Gir.Metadata.Preprocessor {
    /**
     * The Gir Context
     */
    public Gir.Context context { get; set; }

    /**
     * Regular expressions
     */
    private Regex directive_pattern = /^\s*#(?<directive>if|elif|else|endif)\b(?<condition>.*)?/i;
    private Regex equal_pattern = /(?<first>\w+)\s*==\s*(?<second>\w+)/;
    private Regex not_equal_pattern = /(?<first>\w+)\s*!=\s*(?<second>\w+)/;
    private Regex and_pattern = /(?<first>\w+)\s*&&\s*(?<second>\w+)/;
    private Regex or_pattern = /(?<first>\w+)\s*\|\|\s*(?<second>\w+)/;
    private Regex not_pattern = /!\s*(?<symbol>\w+)/;

    private string filename;
    private Gee.ArrayQueue<ConditionalState?> condition_stack;
    private int line_nr;

    /**
     * Construct a new Preprocessor. The Gir Context and filename parameters are
     * used for error logging only.
     */
    public Preprocessor (Gir.Context context, string filename) {
        this.context = context;
        this.filename = filename;
        this.condition_stack = new Gee.ArrayQueue<ConditionalState?> ();
        this.line_nr = 0;
    }

    /**
     * Preprocess the provided file contents. Returns the resulting file
     * contents, or null when an error occurred.
     */
    public string? process (string file_contents) {
        var sb = new StringBuilder ();
        foreach (string line in file_contents.split ("\n")) {
            line_nr++;
            switch (process_line (line)) {
            case KEEP_LINE:
                sb.append (line).append ("\n");
                break;
            case DROP_LINE:
                sb.append ("\n");
                break;
            case ERROR:
                return null;
            }
        }

        if (!condition_stack.is_empty) {
            Gir.Xml.Reference source = get_source_reference (condition_stack.peek ().line_nr);
            context.report.error (source, "missing #endif");
        }

        return sb.str;
    }

    private PreprocessingResult process_line (string line) {
        MatchInfo info;
        if (directive_pattern.match (line, 0, out info)) {
            string directive = info.fetch_named ("directive").ascii_down ();
            string condition = info.fetch_named ("condition").strip ();

            switch (directive) {
            case "if":
                bool parent_active = condition_stack.is_empty || condition_stack.peek ().is_active;
                bool is_active = evaluate (condition);
                condition_stack.offer (ConditionalState () {
                    line_nr = this.line_nr,
                    any_branch_taken = is_active,
                    is_active = parent_active && is_active,
                    parent_is_active = parent_active,
                    in_else = false
                });

                break;
                
            case "elif":
                ConditionalState current = condition_stack.peek ();
                if (current.in_else) {
                    context.report.error (get_source_reference (), "#elif after #else");
                    return PreprocessingResult.ERROR;
                }

                if (current.any_branch_taken) {
                    current.is_active = false;
                } else {
                    bool condValue = evaluate (condition);
                    current.any_branch_taken = condValue;
                    current.is_active = current.parent_is_active && condValue;
                }

                break;

            case "else":
                ConditionalState cs = condition_stack.peek ();
                if (cs.in_else) {
                    context.report.error (get_source_reference (), "multiple #else");
                    return PreprocessingResult.ERROR;
                }

                cs.in_else = true;
                cs.is_active = cs.parent_is_active && !cs.any_branch_taken;
                break;

            case "endif":
                condition_stack.poll ();
                break;
            }
        } else if (condition_stack.is_empty || condition_stack.peek ().is_active) {
            return PreprocessingResult.KEEP_LINE;
        }

        return PreprocessingResult.DROP_LINE;
    }

    private bool evaluate (string condition) {
        MatchInfo info;
        if (equal_pattern.match (condition, 0, out info)) {
            string first = info.fetch_named ("first");
            string second = info.fetch_named ("second");
            return is_defined (first) == is_defined (second);
        }

        if (not_equal_pattern.match (condition, 0, out info)) {
            string first = info.fetch_named ("first");
            string second = info.fetch_named ("second");
            return is_defined (first) != is_defined (second);
        }

        if (and_pattern.match (condition, 0, out info)) {
            string first = info.fetch_named ("first");
            string second = info.fetch_named ("second");
            return is_defined (first) && is_defined (second);
        }

        if (or_pattern.match (condition, 0, out info)) {
            string first = info.fetch_named ("first");
            string second = info.fetch_named ("second");
            return is_defined (first) || is_defined (second);
        }

        if (not_pattern.match (condition, 0, out info)) {
            string symbol = info.fetch_named ("symbol");
            return !is_defined (symbol);
        }

        return is_defined (condition);
    }

    private bool is_defined (string variable) {
        return context.is_defined (variable)
            || (Environment.get_variable (variable) != null);
    }

    private Gir.Xml.Reference get_source_reference (int line_nr = this.line_nr) {
        var begin = Gir.Xml.SourceLocation (null, line_nr, 1);
        var end = Gir.Xml.SourceLocation (null, line_nr, 2);
        return new Gir.Xml.Reference (filename, begin, end);
    }
}

internal struct Gir.Metadata.ConditionalState {
    int line_nr;
    bool any_branch_taken;
    bool is_active;
    bool parent_is_active;
    bool in_else;
}

internal enum Gir.Metadata.PreprocessingResult {
    KEEP_LINE,
    DROP_LINE,
    ERROR
}
