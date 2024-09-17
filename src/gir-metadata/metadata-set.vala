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

public class GirMetadata.MetadataSet : Metadata {
    public MetadataSet (string? selector = null) {
        base ("", selector);
    }

    public void add_sibling (Metadata metadata) {
        foreach (var child in metadata.children) {
            add_child (child);
        }
        // merge arguments and take precedence
        foreach (var key in metadata.args.get_keys ()) {
            args[key] = metadata.args[key];
        }
    }
}
