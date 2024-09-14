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

public class Builders.DataTypeBuilder {

    private Gir.AnyType g_anytype;

    public DataTypeBuilder (Gir.AnyType g_anytype) {
        this.g_anytype = g_anytype;
    }

    /* Create Vala.DataType from a Gir AnyType, which is either 
     * an <array> or <type> element. */
    public Vala.DataType build () {
        if (g_anytype == null) {
            Report.error (null, "expected <array> or <type>");
            return new VoidType ();
        }
        
        if (g_anytype is Gir.TypeRef) {
            return build_type ((Gir.TypeRef) g_anytype);
        } else if (g_anytype is Gir.Array) {
            var size = g_anytype.anytype?.size ?? 0;
            if (size == 1) {
                var inner = g_anytype.anytype[0];
                DataType v_type = new DataTypeBuilder (inner).build ();
                return new ArrayType (v_type, 1, g_anytype.source_reference);
            }
        }

        return new VoidType (g_anytype.source_reference);
    }

    /* Create Vala.DataType from a Gir <type> element. */
    private Vala.DataType build_type (Gir.TypeRef g_type) {
        string? builtin = to_builtin_type (g_type.name);
        if (builtin != null) {
            var sym = new UnresolvedSymbol (null, builtin, g_type.source_reference);
            return new UnresolvedType.from_symbol (sym, g_type.source_reference);
        }

        var v_type = from_name (g_type.name, g_type.source_reference);

        foreach (var g_type_arg in g_type.anytype) {
            var v_type_arg = new DataTypeBuilder (g_type_arg).build ();
            v_type.add_type_argument (v_type_arg);
        }

        return v_type;
    }
    
    /* Create Vala.DataType from a string (for example "Gio.File"). */
    public static Vala.DataType from_name (string name,
                                           SourceReference? source = null) {
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

    /* Generate a string representation for a Gir <type> or <array> so they
     * can be easily compared for equality. */
    public static string generate_string (Gir.AnyType? g_anytype) {
        return (g_anytype == null) ? "null"
                : new DataTypeBuilder (g_anytype).build ().to_string ();
    }
}
