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

public class Gir.Context : Object {
    internal Gee.Map<string, Gir.Repository> repositories { get; set; }
    internal Gee.List<string> parser_queue { get; set; }
    public string[] gir_directories { get; set; }
    public Gir.Xml.Report report { get; set; }

    private static Gee.Queue<Context> context_queue;

    static construct {
        context_queue = new Gee.ArrayQueue<Context> ();
    }

    construct {
        this.repositories = new Gee.HashMap<string, Gir.Repository> ();
        this.parser_queue = new Gee.ArrayList<string> ();
        this.report = new Gir.Xml.Report ();
    }

    public Context (string[] gir_directories) {
        this.gir_directories = gir_directories;
    }

    public static void push (Context context) {
        context_queue.offer (context);
    }

    public new static Context get () {
        return context_queue.peek ();
    }

    public new static Context pop () {
        return context_queue.poll ();
    }

    /**
     * Queue a repository to be parsed, for example "Gtk-4.0".
     */
    public void queue_repository (string name_and_version) {
        parser_queue.add (name_and_version);
    }

    /**
     * Add a parsed repository
     */
    internal void add_repository (string name_and_version, Gir.Repository repository) {
        repositories[name_and_version] = repository;
    }

    /**
     * Get a Gir repository from the context, for example "Gtk-4.0". Returns
     * null when the repository is not found.
     */
    public Gir.Repository? get_repository (string name_and_version) {
        return repositories[name_and_version];
    }

    /**
     * Check whether a Gir repository is in the context, for example "Gtk-4.0".
     */
     public bool contains_repository (string name_and_version) {
        return repositories.has_key (name_and_version);
    }
}
