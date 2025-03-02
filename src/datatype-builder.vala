/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
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

public class DataTypeBuilder {

    private Gir.AnyType? g_anytype;

    public DataTypeBuilder (Gir.AnyType? g_anytype) {
        this.g_anytype = g_anytype;
    }

    /* Create Vala DataType from a Gir AnyType, which is either 
     * an <array> or <type> element. */
    public DataType build () {
        if (g_anytype == null) {
            Report.error (null, "expected <array> or <type>");
            return new VoidType ();
        }

        /* <type> */
        if (g_anytype is Gir.TypeRef) {
            var g_type = (Gir.TypeRef) g_anytype;
            return build_type (g_anytype.name, g_type.anytypes, g_anytype.source);
        }

        /* <array> */
        var g_array = (Gir.Array) g_anytype;
        if (g_array.name == "GLib.PtrArray") {
            var inner_types = new ArrayList<Gir.AnyType>();
            inner_types.add (g_array.anytype);
            return build_type (g_anytype.name, inner_types, g_anytype.source);
        }

        DataType v_type = new DataTypeBuilder (g_array.anytype).build ();
        return new ArrayType (v_type, 1, g_anytype.source);
    }

    /* Create Vala DataType from a Gir <type> element. */
    private DataType build_type (string name, Vala.List<Gir.AnyType> g_inner_type, SourceReference? source) {
        string? builtin = to_builtin_type (name);
        if (builtin != null) {
            var sym = new UnresolvedSymbol (null, builtin, source);
            return new UnresolvedType.from_symbol (sym, source);
        }

        var v_type = from_name (name, source);

        foreach (var g_type_arg in g_inner_type) {
            var v_type_arg = new DataTypeBuilder (g_type_arg).build ();
            v_type.add_type_argument (v_type_arg);
        }

        return v_type;
    }

    /* Create Vala DataType from a string (for example "Gio.File"). */
    public static DataType from_name (string name, SourceReference? source = null) {
        if (name == "none") {
            return new VoidType (source);
        }

        if (name == "gpointer") {
            return new PointerType (new VoidType (source), source);
        }

        string input = convert_name (name);
        UnresolvedSymbol? sym = null;
        foreach (unowned string str in input.split (".")) {
            sym = new UnresolvedSymbol (sym, str, source);
        }

        if (sym == null) {
            Report.error (source, "a symbol must be specified");
        }

        return new UnresolvedType.from_symbol ((!) sym, source);
    }

    private static string convert_name (string name) {
        if (name == "GType") {
            return "GLib.Type";
        }

        if (name == "GLib.String") {
            return "GLib.StringBuilder";
        }

        if (name == "GLib.Data") {
            return "GLib.Datalist";
        }

        if (name == "GLib.PtrArray") {
            return "GLib.GenericArray";
        }

        if (name.has_prefix ("GObject.")) {
            return name.replace ("GObject.", "GLib.");
        }

        if (name.has_prefix ("Gio.")) {
            return name.replace ("Gio.", "GLib.");
        }

        return name;
    }

    private string? to_builtin_type (string name) {
        switch (name) {
            case "gboolean": return "bool";
            case "gchar":    return "char";
            case "gunichar": return "unichar";
            case "gshort":   return "short";
            case "gushort":  return "ushort";
            case "gint":     return "int";
            case "guint":    return "uint";
            case "glong":    return "long";
            case "gulong":   return "ulong";
            case "gint8":    return "int8";
            case "guint8":   return "uint8";
            case "gint16":   return "int16";
            case "guint16":  return "uint16";
            case "gint32":   return "int32";
            case "guint32":  return "uint32";
            case "gint64":   return "int64";
            case "guint64":  return "uint64";
            case "gfloat":   return "float";
            case "gdouble":  return "double";
            case "utf8":     return "string";
            case "filename": return "string";
            case "gsize":    return "size_t";
            case "gssize":   return "ssize_t";
            default:         return null;
        }
    }

    /* Check if this data type is a SimpleType (numeric, size or offset). */
    public bool is_simple_type () {
        return g_anytype is Gir.TypeRef && (to_builtin_type (g_anytype.name) ?? "string") != "string";
    }
    
    /* Generate a string representation for a Gir <type> or <array> so they
     * can be easily compared for equality. */
    public static string generate_string (Gir.AnyType? g_anytype) {
        return (g_anytype == null) ? "null" : new DataTypeBuilder (g_anytype).build ().to_string ();
    }

    /* Parse a Vala.Expression (of a type) into a Vala.DataType. */
    public static DataType? from_expression (string expression) {
        string expr = expression;
        
        /* Remove quotes */
        if (expr.length > 2 && expr.has_prefix ("\"") && expr.has_suffix ("\"")) {
            expr = expr.substring (1, expr.length - 2);
        }

        /* Setup a temporary code context */
        var context = new CodeContext ();
        CodeContext.push (context);
        context.report.enable_warnings = false;

        /* The Vala parser expects a SourceFile. Invent one in-memory. */
        var content = expr + " field;";
        var source_file = new SourceFile (context, SourceFileType.NONE, "temp.vala", content, false);
        context.add_source_file (source_file);

        /* Invoke the Vala parser */
        new Parser ().parse (context);
        CodeContext.pop();
        
        if (context.report.get_errors () > 0) {
            return null;
        }

        /* Get the datatype from the AST */
        var fields = context.root.get_fields ();
        return fields.size == 0 ? null : fields[0].variable_type;
    }

    /* Get the name of a Vala Datatype */
    public static string? vala_datatype_name (DataType v_datatype) {
        if (v_datatype is UnresolvedType) {
            var v_symbol = ((UnresolvedType) v_datatype).unresolved_symbol;
            return v_symbol?.to_string ();
        } else {
            return v_datatype.type_symbol?.to_string ();
        }
    }
}
