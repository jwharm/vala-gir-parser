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
using Builders;
using GirMetadata;

public class GirParser2 : CodeVisitor {

    public void parse(CodeContext context) {
        context.accept (this);
    }

    public override void visit_source_file (SourceFile source_file) {
        if (! source_file.filename.has_suffix (".gir")) {
            return;
        }

        var context = CodeContext.get ();
        var parser = new Gir.Parser (source_file);
        var repository = parser.parse ();

        if (repository != null) {
            /* set package name */
            string? pkg = repository.package?.name;
            source_file.package_name = pkg;
            if (context.has_package (pkg)) {
                /* package already provided elsewhere, stop parsing this GIR
                 * if it was not passed explicitly */
                if (! source_file.from_commandline) {
                    return;
                }
            } else {
                context.add_package (pkg);
            }

            /* add dependency packages */
            foreach (var include in repository.includes) {
                string dep = include.name;
                if (include.version != null) {
                    dep += "-" + include.version;
                }

                context.add_external_package (dep);
            }

            /* build the namespace and everything in it */
            var builder = new NamespaceBuilder (repository.namespace,
                                                repository.c_includes);
            context.root.add_namespace (builder.build ());

            /* apply metadata */
            var metadata = load_metadata (context, source_file);
            if (metadata != Metadata.empty) {
                var name = repository.namespace.name;
                var metadata_processor = new MetadataProcessor (metadata, name);
                metadata_processor.apply (context);
            }
        }
    }

    /* Load metadata, first look into metadata directories then in the same
     * directory of the .gir. */
    private Metadata load_metadata (CodeContext context, SourceFile gir_file) {
		string? filename = context.get_metadata_path (gir_file.filename);
		if (filename != null && FileUtils.test (filename, EXISTS)) {
			var parser = new MetadataParser ();
			var file = new SourceFile (context, gir_file.file_type, filename);
			context.add_source_file (file);
			return parser.parse_metadata (file);
		} else {
            return Metadata.empty;
        }
    }
}
