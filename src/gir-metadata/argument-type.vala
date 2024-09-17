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
