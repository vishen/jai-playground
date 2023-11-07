Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG);
Compiler :: #import "Compiler";
// String :: #import "String";


// jai-macos first.jai - <compile time arguments>...
comp_time_args :: #run () -> []string {
	options := Compiler.get_build_options();
	return options.compile_time_command_line;
}();

DEBUG :: #run () -> bool {
	has_prefix :: (value: string, prefix: string) -> bool {
		// return String.slice(value, 0, prefix.count) == prefix;
		if prefix.count > value.count return false;

		c: string = ---;
		c.data  = value.data;
		c.count = prefix.count;

		return c == prefix;
	}

	for arg: comp_time_args {
		if has_prefix(arg, "debug") {
			return true;
		}
	}
	return false;
}();

debug_macro :: () #expand {
	#if DEBUG {
		`defer Basic.report_memory_leaks();
		`Basic.print("We were compiled with: %\n", comp_time_args);
	}
}

main :: () {
	
	debug_macro();

	new_context := context;
	new_context.allocator = Basic.temp;
	push_context new_context {
		Basic.print("json data: %\n", TEST_JSON_DATA);

		success, json_tokens := json_parse(TEST_JSON_DATA);
		if !success {
			Basic.assert(false);
		}

		for json_tokens  Basic.print("%\n", it);
	}
}

Json_Token :: struct {
	type: Json_Token_Type;
	value: string;

	line: int;
	character: int;
}

Json_Token_Type :: enum {
	UNKNOWN;
	OPEN_OBJECT;
	CLOSE_OBJECT;
	OPEN_LIST;
	CLOSE_LIST;
	COLON;
	COMMA;
	KEY;
	STRING;
	NUMBER;
	TRUE;
	FALSE;
	NULL;
}

Json_Parser :: struct {
	i: int;
	line, ch: int;

	json_data: string;
}

is_done :: (p: *Json_Parser) -> done: bool {
	return p.i >= p.json_data.count;
}

eat_until :: (p: *Json_Parser, ch: u8) -> success: bool {
	while !is_done(p) {
		if p.json_data[p.i] == ch {
			return true;
		}
		p.i += 1;
		p.ch += 1;
	}
	return false;
}

eat_number :: (p: *Json_Parser) -> success: bool {
	while !is_done(p) {
		ch := p.json_data[p.i];
		if (ch >= #char "0" && ch <= #char "9") || ch == #char "." {
			// expected
		} else {
			return true;
		}
		p.i += 1;
		p.ch += 1;
	}
	return false;
}

string_equals :: (p: *Json_Parser, s: string) -> success: bool {
	s_: string = ---;
	s_.data = p.json_data.data + p.i;
	s_.count = s.count;
	return s == s_;
}


json_parse :: (json_data: string) -> success: bool, [..] Json_Token {
	parser := Json_Parser.{json_data=json_data, line=1};

	add_json_tokens_macro :: ($type: Json_Token_Type) #expand {
		`Basic.array_add(*`json_tokens, Json_Token.{
			type=type,
			line=`parser.line, character=`parser.ch, 
		});
	}

	json_tokens: [..] Json_Token;
	while !is_done(*parser) {
		defer {
			parser.i += 1;
			parser.ch += 1;
		}

		c := json_data[parser.i];
		if c == {
		case #char "\n";
			parser.line += 1;
			parser.ch = -1; // TODO: stupid, but because of defer...
		case #char "{";
			add_json_tokens_macro(.OPEN_OBJECT);
		case #char "}";
			add_json_tokens_macro(.CLOSE_OBJECT);
		case #char "[";
			add_json_tokens_macro(.OPEN_LIST);
		case #char "]";
			add_json_tokens_macro(.CLOSE_LIST);
		case #char ":";
			add_json_tokens_macro(.COLON);
		case #char ",";
			add_json_tokens_macro(.COMMA);
		case #char "f";
			expected := "false";
			if !string_equals(*parser, expected) {
				Basic.log("line: %, character: %) expected %", parser.line, parser.ch, expected);
				return false, json_tokens;
			}
			add_json_tokens_macro(.FALSE);
		case #char "t";
			expected := "true";
			if !string_equals(*parser, expected) {
				Basic.log("line: %, character: %) expected %", parser.line, parser.ch, expected);
				return false, json_tokens;
			}
			add_json_tokens_macro(.TRUE);
		case #char "n";
			expected := "null";
			if !string_equals(*parser, expected) {
				Basic.log("line: %, character: %) expected %", parser.line, parser.ch, expected);
				return false, json_tokens;
			}
			add_json_tokens_macro(.NULL);
		case #char "\"";
			parser.i += 1;
			parser.ch += 1;
			start := parser.i;
			success := eat_until(*parser, #char "\"");
			if !success {
				Basic.log("line: %, character: %) unable to find matching \"", parser.line, parser.ch);
				return false, json_tokens;
			}
			s: string = ---;
			s.data = parser.json_data.data + start;
			s.count = parser.i - start;

			token_type: Json_Token_Type = ---;
			if json_tokens[json_tokens.count - 1].type == .OPEN_OBJECT {
				token_type = .KEY;
			} else {
				token_type = .STRING;
			}

			Basic.array_add(*json_tokens, Json_Token.{
				type=token_type,
				value=s,
				line=parser.line, character=parser.ch, 
			});
		case;
			if c >= #char "0" && c <= #char "9" {
				start := parser.i;
				success := eat_number(*parser);
				if !success {
					Basic.log("line: %, character: %) unexpected number format", parser.line, parser.ch);
					return false, json_tokens;
				}
				s: string = ---;
				s.data = parser.json_data.data + start;
				s.count = parser.i - start;
				Basic.array_add(*json_tokens, Json_Token.{
					type=.NUMBER,
					value=s,
					line=parser.line, character=parser.ch, 
				});
			}
		}
	}
	return true, json_tokens;
}

to_string :: (c: u8) -> string {
	_c := c;
	s: string; // = ---;
	s.data = *_c;
	s.count = 1;
	return s;
}

struct_formatter :: (value: Any) -> Basic.FormatStruct {
	return .{
		value=value,
		draw_type_name=true,
		use_long_form_if_more_than_this_many_members=-1,
	};
};

TEST_JSON_DATA :: #string DONE
{
	"key1": "value1",
	"key2": [1, "2", 3.0, true, false, null],
	"key3": { "key3_1": { "key3_1_1": "abcdef", "key3_1_2": 123} },
}

DONE
