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

public class Builders.DelegateBuilder {

    private Gir.Callable callable;

    public DelegateBuilder (Gir.Callback callable) {
        this.callable = callable;
    }

    public Vala.Delegate build_callback () {
        var callback = (Gir.Callback) callable;
        
        /* return type */
        var return_value = callback.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* create the delegate */
        var vdelegate = new Delegate (callback.name, return_type, callback.source_reference);
        vdelegate.access = SymbolAccessibility.PUBLIC;

        /* c_name */
        vdelegate.set_attribute_string ("CCode", "cname", callback.c_type);

        /* version */
        vdelegate.set_attribute_string ("Version", "since", callable.version);

        /* parameters */
        new ParametersBuilder (callable, vdelegate).build_parameters ();

        /* throws */
        if (callback.throws) {
            vdelegate.add_error_type (new Vala.ErrorType (null, null));
        }

        return vdelegate;
    }

    public Vala.Signal build_signal () {
        var sig = (Gir.Signal) callable;
        
        /* return type */
        var return_value = sig.return_value;
        var return_type = new DataTypeBuilder (return_value.anytype).build ();

        /* create the signal */
        var vsignal = new Vala.Signal (sig.name, return_type, sig.source_reference);
        vsignal.access = SymbolAccessibility.PUBLIC;

        /* c name */
        vsignal.set_attribute_string ("CCode", "cname", sig.name);

        /* parameters */
        new ParametersBuilder (callable, vsignal).build_parameters ();

        return vsignal;
    }
}
