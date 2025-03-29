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

public class Gir.Context {
    internal Vala.List<Gir.Repository> repositories { get; set; }
    internal Vala.List<string> parser_queue { get; set; }
    public string[] gir_directories { get; set; }

    public Context (string[] gir_directories) {
        this.repositories = new Vala.ArrayList<Gir.Repository> ();
        this.parser_queue = new Vala.ArrayList<string> ();
        this.gir_directories = gir_directories;
    }

    /**
     * Add a repository to be parsed, for example "Gtk-4.0".
     */
    public void add_repository (string name_and_version) {
        parser_queue.add (name_and_version);
    }

    /**
     * Get a Gir repository from the context, for example "Gtk-4.0". Returns
     * null when the repository is not found.
     */
    public Gir.Repository? get_repository (string name_and_version) {
        foreach (var repository in repositories) {
            foreach (var ns in repository.namespaces) {
                if (name_and_version == (ns.name + "-" + ns.version)) {
                    return repository;
                }
            }
        }

        return null;
    }

    /**
     * Check whether a Gir repository is in the context, for example "Gtk-4.0".
     */
     public bool contains_repository (string name_and_version) {
        foreach (var repository in repositories) {
            foreach (var ns in repository.namespaces) {
                if (name_and_version == (ns.name + "-" + ns.version)) {
                    return true;
                }
            }
        }

        return false;
    }
}
