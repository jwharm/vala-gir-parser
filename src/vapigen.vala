/* valavapigen.vala
 *
 * Copyright (C) 2006-2010  Jürg Billeter
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
 *  Jürg Billeter <j@bitron.ch>
 */

/* Copied from Vala 0.56 */

using GLib;
using Vala;

class VAPIGen {
    static string directory;
    static bool version;
    static bool quiet_mode;
    static bool disable_warnings;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] sources;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] vapi_directories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] gir_directories;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] metadata_directories;
    static string library;
    [CCode (array_length = false, array_null_terminated = true)]
    static string[] packages;
    static bool nostdpkg;

    CodeContext context;

    const OptionEntry[] options = {
        { "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref vapi_directories, "Look for package bindings in DIRECTORY", "DIRECTORY..." },
        { "girdir", 0, 0, OptionArg.FILENAME_ARRAY, ref gir_directories, "Look for GIR bindings in DIRECTORY", "DIRECTORY..." },
        { "metadatadir", 0, 0, OptionArg.FILENAME_ARRAY, ref metadata_directories, "Look for GIR .metadata files in DIRECTORY", "DIRECTORY..." },
        { "nostdpkg", 0, 0, OptionArg.NONE, ref nostdpkg, "Do not include standard packages", null },
        { "pkg", 0, 0, OptionArg.STRING_ARRAY, ref packages, "Include binding for PACKAGE", "PACKAGE..." },
        { "library", 0, 0, OptionArg.STRING, ref library, "Library name", "NAME" },
        { "directory", 'd', 0, OptionArg.FILENAME, ref directory, "Output directory", "DIRECTORY" },
        { "disable-warnings", 0, 0, OptionArg.NONE, ref disable_warnings, "Disable warnings", null },
        { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
        { "quiet", 'q', 0, OptionArg.NONE, ref quiet_mode, "Do not print messages to the console", null },
        { OPTION_REMAINING, 0, 0, OptionArg.FILENAME_ARRAY, ref sources, null, "FILE..." },
        { null }
    };
    
    private int quit () {
        if (context.report.get_errors () == 0) {
            if (!quiet_mode) {
                print ("Generation succeeded - %d warning(s)\n", context.report.get_warnings ());
            }
            CodeContext.pop ();
            return 0;
        } else {
            if (!quiet_mode) {
                print ("Generation failed: %d error(s), %d warning(s)\n", context.report.get_errors (), context.report.get_warnings ());
            }
            CodeContext.pop ();
            return 1;
        }
    }
    
    private int run () {
        context = new CodeContext ();
        context.vapi_directories = vapi_directories;
        context.gir_directories = gir_directories;
        context.metadata_directories = metadata_directories;
        context.report.enable_warnings = !disable_warnings;
        context.report.set_verbose_errors (!quiet_mode);
        CodeContext.push (context);
        context.set_target_profile (Profile.GOBJECT, !nostdpkg);

        if (context.report.get_errors () > 0) {
            return quit ();
        }

        /* load packages from .deps file */
        foreach (string source in sources) {
            if (!source.has_suffix (".gi")) {
                continue;
            }

            var depsfile = source.substring (0, source.length - "gi".length) + "deps";
            context.add_packages_from_file (depsfile);
        }

        if (context.report.get_errors () > 0) {
            return quit ();
        }

        // depsfile for gir case
        if (library != null) {
            var depsfile = library + ".deps";
            context.add_packages_from_file (depsfile);
        } else {
            Report.error (null, "--library option must be specified");
        }

        if (context.report.get_errors () > 0) {
            return quit ();
        }

        if (packages != null) {
            foreach (string package in packages) {
                context.add_external_package (package);
            }
            packages = null;
        }
        
        if (context.report.get_errors () > 0) {
            return quit ();
        }

        foreach (string source in sources) {
            if (FileUtils.test (source, FileTest.EXISTS)) {
                var source_file = new SourceFile (context, SourceFileType.PACKAGE, source);
                source_file.from_commandline = true;
                context.add_source_file (source_file);
            } else {
                Report.error (null, "%s not found", source);
            }
        }
        
        if (context.report.get_errors () > 0) {
            return quit ();
        }
        
        var parser = new Parser ();
        parser.parse (context);
        
        if (context.report.get_errors () > 0) {
            return quit ();
        }
        
        var girparser = new GirParser2 ();
        girparser.parse (context);
        
        if (context.report.get_errors () > 0) {
            return quit ();
        }
        
        context.check ();

        if (context.report.get_errors () > 0) {
            return quit ();
        }

        // candidates to match library against
        string[] package_names = {};

        // interface writer ignores external packages
        foreach (SourceFile file in context.get_source_files ()) {
            if (file.filename.has_suffix (".vapi")) {
                continue;
            }
            if (file.filename in sources) {
                file.file_type = SourceFileType.SOURCE;
                if (file.filename.has_suffix (".gir")) {
                    // mark relative metadata as source
                    string? metadata_filename = context.get_metadata_path (file.filename);
                    if (metadata_filename != null) {
                        unowned SourceFile? metadata_file = context.get_source_file (metadata_filename);
                        if (metadata_file != null) {
                            metadata_file.file_type = SourceFileType.SOURCE;
                        }
                    }
                    if (file.from_commandline && file.package_name != null) {
                        package_names += file.package_name;
                    }
                }
            }
        }

        var library_name = Path.get_basename (library);
        if (package_names.length > 0 && !(library_name in package_names)) {
            Report.warning (null, "Given library name `%s' does not match pkg-config name `%s'", library_name, string.join ("', `", package_names));
        }

        var interface_writer = new CodeWriter (CodeWriterType.VAPIGEN);
        var vapi_filename = "%s.vapi".printf (library);
        if (directory != null) {
            vapi_filename = Path.build_path ("/", directory, vapi_filename);
        }

        interface_writer.write_file (context, vapi_filename);
            
        library = null;
        
        return quit ();
    }
    
    static int main (string[] args) {
        Intl.setlocale (LocaleCategory.ALL, "");

        if (Vala.get_build_version () != Vala.BUILD_VERSION) {
            printerr ("Integrity check failed (libvala %s doesn't match vapigen %s)\n", Vala.get_build_version (), Vala.BUILD_VERSION);
            return 1;
        }

        try {
            var opt_context = new OptionContext ("- Vala API Generator");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            opt_context.parse (ref args);
        } catch (OptionError e) {
            print ("%s\n", e.message);
            print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 1;
        }

        if (version) {
            print ("Vala API Generator %s\n", Vala.BUILD_VERSION);
            return 0;
        }

        if (sources == null) {
            printerr ("No source file specified.\n");
            return 1;
        }
        
        var vapigen = new VAPIGen ();
        return vapigen.run ();
    }
}
