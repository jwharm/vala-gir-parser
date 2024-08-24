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
            var builder = new NamespaceBuilder (repository.namespace);
            context.root.add_namespace( builder.build ());
        }
    }
}
