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

public class Builders.TypeBuilder {

    private Gir.TypeRef type;

    public TypeBuilder (Gir.TypeRef type) {
        this.type = type;
    }

    public Vala.DataType build () {
        if (type.name == "none") {
            return new VoidType (type.source_reference);
        }

        if (type.name == "gpointer") {
            var void_type = new VoidType (type.source_reference);
            return new PointerType (void_type, type.source_reference);
        }

        string? builtin = to_builtin_type ();
        if (builtin != null) {
            var sym = new UnresolvedSymbol (null, builtin, type.source_reference);
            return new UnresolvedType.from_symbol (sym, type.source_reference);
        }

        var sym = to_unresolved_symbol ();
        return new UnresolvedType.from_symbol (sym, type.source_reference);
    }
    
    private UnresolvedSymbol to_unresolved_symbol () {
        UnresolvedSymbol? sym = null;
        foreach (unowned string str in type.name.split (".")) {
            sym = new UnresolvedSymbol (sym, str, type.source_reference);
        }

        if (sym == null) {
            Report.error (type.source_reference, "a symbol must be specified");
        }

        return (!) sym;
    }

    private string? to_builtin_type () {
        switch (type.name) {
            case "utf8":
                return "string";
            case "gboolean":
                return "bool";
            case "gchar":
                return "char";
            case "gshort":
                return "short";
            case "gushort":
                return "ushort";
            case "gint":
                return "int";
            case "guint":
                return "uint";
            case "glong":
                return "long";
            case "gulong":
                return "ulong";
            case "gint8":
                return "int8";
            case "guint8":
                return "uint8";
            case "gint16":
                return "int16";
            case "guint16":
                return "uint16";
            case "gint32":
                return "int32";
            case "guint32":
                return "uint32";
            case "gint64":
                return "int64";
            case "guint64":
                return "uint64";
            case "gfloat":
                return "float";
            case "gdouble":
                return "double";
            case "filename":
                return "string";
            case "gsize":
                return "size_t";
            case "gssize":
                return "ssize_t";
            case "gunichar":
                return "unichar";
            default:
                return null;
        }
    }
}
