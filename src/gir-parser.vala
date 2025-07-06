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

using Gir;
using Vala;

/**
 * This class replaces the existing GirParser class. It is named "GirParser2"
 * to avoid naming conflicts (because the original GirParser is imported from
 * libvala).
 *
 * The GirParser class is a CodeVisitor that implements `visit_source_file` for
 * files with a ".gir" extension. It will parse the gir file, apply metadata,
 * and generate the VAPI AST in the current CodeContext.
 */
public class GirParser2 : CodeVisitor {

    public Gir.Context gir_context { get; set; }

    public void parse (CodeContext context, Gir.Context gir_context) {
        this.gir_context = gir_context;
        context.accept (this);
    }

    public override void visit_source_file (SourceFile source_file) {
        if (! source_file.filename.has_suffix (".gir")) {
            return;
        }

        if (! source_file.from_commandline) {
            return;
        }

        var code_context = CodeContext.get ();

        /* Repository name and version = filename without the ".gir" extension */
        string name_and_version = Path.get_basename (source_file.filename)[:-4];

        gir_context.report.set_verbose_errors (true);
        gir_context.queue_repository (name_and_version);
        var parser = new Gir.Parser (gir_context);
        parser.parse ();
        var repository = gir_context.get_repository (name_and_version);

        if (repository != null) {
            /* set package name */
            foreach (var pkg in repository.packages) {
                source_file.package_name = pkg.name;
                if (code_context.has_package (pkg.name)) {
                    /* package already provided elsewhere, stop parsing this GIR
                     * if it was not passed explicitly */
                    if (! source_file.from_commandline) {
                        return;
                    }
                } else {
                    code_context.add_package (pkg.name);
                }
            }

            /* add dependency packages */
            foreach (var include in repository.includes) {
                string dep = include.name;
                if (include.version != null) {
                    dep += "-" + include.version;
                }

                code_context.add_external_package (dep);
            }

            /* add metadata */
            string metadata_filename = get_metadata_path (code_context.metadata_directories,
                                                          Path.get_dirname (source_file.filename),
                                                          name_and_version);
            if (metadata_filename != null) {
                var metadata_parser = new Gir.Metadata.Parser (gir_context);
                metadata_parser.parse (metadata_filename, name_and_version);
            }

            /* resolve Gir references */
            repository.accept (new Gir.Resolver (gir_context));

            /* build the namespace(s) and everything in it */
            repository.accept (new VapiBuilder ());
        }
    }

    /* Find a metadata file for the gir file. */
    private string? get_metadata_path (string[] metadata_directories, string base_dir, string name_and_version) {
        /* Find the metadata file in one of the metadata directories */
        foreach (string dir in metadata_directories) {
            if (FileUtils.test (dir, IS_DIR)) {
                string path = Path.build_filename (dir, name_and_version + ".metadata", null);
                if (FileUtils.test (path, EXISTS)) {
                    return path;
                }
            }
        }

        /* Find the metadata file in the directory of the gir file */
        string path = Path.build_filename (base_dir, name_and_version + ".metadata", null);
        if (FileUtils.test (path, EXISTS)) {
            return path;
        }

        /* If the metadata file is not found anywhere, return null */
        return null;
    }
}
