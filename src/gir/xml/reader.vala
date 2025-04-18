/* vala-gir-parser
 * Copyright (C) 2024-2025 Jan-Willem Harmannij
 * 
 * Parts of this file were copied and adapted from Vala 0.56:
 * Copyright (C) 2008-2009  Jürg Billeter
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

using GLib;
using Gee;

/**
 * Simple reader for a subset of XML.
 */
public class Gir.Xml.Reader {
	public Gir.Context context { get; private set; }
	public string filename { get; private set; }
	public string name { get; private set; }
	public string content { get; private set; }

	MappedFile mapped_file;

	char* begin;
	char* current;
	char* end;

	int line;
	int column;

	Map<string,string> attributes = new HashMap<string,string> ();
	bool empty_element;

	public Reader (Gir.Context context, string filename) {
		this.context = context;
		this.filename = filename;

		try {
			mapped_file = new MappedFile (filename, false);
			begin = mapped_file.get_contents ();
			end = begin + mapped_file.get_length ();

			current = begin;

			line = 1;
			column = 1;
		} catch (FileError e) {
			context.report.error (null, "Unable to map file `%s': %s", filename, e.message);
		}
	}

	public Reader.from_string (string filename, string content) {
		this.filename = filename;

		begin = content;
		end = begin + content.length;

		current = begin;

		line = 1;
		column = 1;
	}

	public bool has_attribute (string attr) {
		return attributes.has_key (attr);
	}

	public string? get_attribute (string attr) {
		return attributes[attr];
	}

	/*
	 * Returns a copy of the current attributes.
	 *
	 * @return map of current attributes
	 */
	public Map<string,string> get_attributes () {
		var result = new HashMap<string,string> ();
		foreach (var key in attributes.keys) {
			result.set (key, attributes.get (key));
		}
		return result;
	}

	string read_name () {
		char* begin = current;
		while (current < end) {
			if (current[0] == ' ' || current[0] == '\t' || current[0] == '>'
			    || current[0] == '/' || current[0] == '=' || current[0] == '\n') {
				break;
			}
			unichar u = ((string) current).get_char_validated ((long) (end - current));
			if (u != (unichar) (-1)) {
				current += u.to_utf8 (null);
			} else {
				context.report.error (null, "invalid UTF-8 character");
			}
		}
		if (current == begin) {
			// syntax error: invalid name
		}
		column += (int) (current - begin);
		return ((string) begin).substring (0, (int) (current - begin));
	}

	public XmlTokenType read_token (out SourceLocation token_begin, out SourceLocation token_end) {
		attributes.clear ();

		if (empty_element) {
			empty_element = false;
			token_begin = SourceLocation (begin, line, column);
			token_end = SourceLocation (begin, line, column);
			return XmlTokenType.END_ELEMENT;
		}

		content = null;
		name = null;

		space ();

		XmlTokenType type = XmlTokenType.NONE;
		char* begin = current;
		token_begin = SourceLocation (begin, line, column);

		if (current >= end) {
			type = XmlTokenType.EOF;
		} else if (current[0] == '<') {
			current++;
			column++;
			if (current >= end) {
				// error
			} else if (current[0] == '?') {
				// processing instruction
			} else if (current[0] == '!') {
				// comment or doctype
				current++;
				if (current < end - 1 && current[0] == '-' && current[1] == '-') {
					// comment
					current += 2;
					while (current < end - 2) {
						if (current[0] == '-' && current[1] == '-' && current[2] == '>') {
							// end of comment
							current += 3;
							break;
						} else if (current[0] == '\n') {
							line++;
							column = 0;
						}
						current++;
						column++;
					}

					// ignore comment, read next token
					return read_token (out token_begin, out token_end);
				}
			} else if (current[0] == '/') {
				type = XmlTokenType.END_ELEMENT;
				current++;
				column++;
				name = read_name ();
				if (current >= end || current[0] != '>') {
					// error
				}
				current++;
				column++;
			} else {
				type = XmlTokenType.START_ELEMENT;
				name = read_name ();
				space ();
				while (current < end && current[0] != '>' && current[0] != '/') {
					string attr_name = read_name ();
					space ();
					if (current >= end || current[0] != '=') {
						// error
					}
					current++;
					column++;
					space ();
					if (current >= end || current[0] != '"' || current[0] != '\'') {
						// error
					}
					char quote = current[0];
					current++;
					column++;

					string attr_value = text (quote, false);

					if (current >= end || current[0] != quote) {
						// error
					}
					current++;
					column++;
					attributes.set (attr_name, attr_value);
					space ();
				}
				if (current[0] == '/') {
					empty_element = true;
					current++;
					column++;
					space ();
				} else {
					empty_element = false;
				}
				if (current >= end || current[0] != '>') {
					// error
				}
				current++;
				column++;
			}
		} else {
			space ();

			if (current[0] != '<') {
				content = text ('<', true);
			} else {
				// no text
				// read next token
				return read_token (out token_begin, out token_end);
			}

			type = XmlTokenType.TEXT;
		}

		token_end = SourceLocation (current, line, column - 1);

		return type;
	}

	string text (char end_char, bool rm_trailing_whitespace) {
		StringBuilder content = new StringBuilder ();
		char* text_begin = current;
		char* last_linebreak = current;

		while (current < end && current[0] != end_char) {
			unichar u = ((string) current).get_char_validated ((long) (end - current));
			if (u == (unichar) (-1)) {
				context.report.error (null, "invalid UTF-8 character");
			} else if (u == '&') {
				char* next_pos = current + u.to_utf8 (null);
				char buffer[16];
				Memory.copy (buffer, next_pos, (end - next_pos >= buffer.length ? buffer.length - 1 : end - next_pos));
				if (((string) buffer).has_prefix ("amp;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('&');
					current += 5;
					text_begin = current;
				} else if (((string) buffer).has_prefix ("quot;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('"');
					current += 6;
					text_begin = current;
				} else if (((string) buffer).has_prefix ("apos;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('\'');
					current += 6;
					text_begin = current;
				} else if (((string) buffer).has_prefix ("lt;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('<');
					current += 4;
					text_begin = current;
				} else if (((string) buffer).has_prefix ("gt;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('>');
					current += 4;
					text_begin = current;
				} else if (((string) buffer).has_prefix ("percnt;")) {
					content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
					content.append_c ('%');
					current += 8;
					text_begin = current;
				} else {
					current += u.to_utf8 (null);
				}
			} else {
				if (u == '\n') {
					line++;
					column = 0;
					last_linebreak = current;
				}

				current += u.to_utf8 (null);
				column++;
			}
		}

		if (text_begin != current) {
			content.append (((string) text_begin).substring (0, (int) (current - text_begin)));
		}

		column += (int) (current - last_linebreak);

		// Removes trailing whitespace
		if (rm_trailing_whitespace) {
			char* str_pos = ((char*)content.str) + content.len;
			for (str_pos--; str_pos > ((char*)content.str) && str_pos[0].isspace(); str_pos--);
			content.erase ((ssize_t) (str_pos-((char*) content.str) + 1), -1);
		}

		return content.str;
	}

	void space () {
		while (current < end && current[0].isspace ()) {
			if (current[0] == '\n') {
				line++;
				column = 0;
			}
			current++;
			column++;
		}
	}
}

public enum Gir.Xml.XmlTokenType {
	NONE,
	START_ELEMENT,
	END_ELEMENT,
	TEXT,
	EOF;

	public unowned string to_string () {
		switch (this) {
		case START_ELEMENT: return "start element";
		case END_ELEMENT: return "end element";
		case TEXT: return "text";
		case EOF: return "end of file";
		default: return "unknown token type";
		}
	}
}