Basic :: #import "Basic";
File :: #import "File";

main :: () {
	data, success := File.read_entire_file("example_proto3.proto");
	Basic.assert(success);

	protobuf_file := parse_protobuf_file(data);
	Basic.print("protobuf_file=%\n", protobuf_file);
}

tokenize :: (data: string) -> [..]string {
	tokens: [..]string;

	t := Tokenizer.{data=data};
	while t.cur < t.data.count-1 {
		ch := current(*t);
		// Ignore comments
		if ch == #char "/" && peek(*t) == #char "/" {
			eat_until(*t, #char "\n");
			continue;
		} 

		if is_alpha(ch) {
			Basic.array_add(*tokens, eat_ident(*t));
		} else if is_numeric(ch) {
			Basic.array_add(*tokens, eat_until(*t, is_numeric));
		} else if is_allowed_special(ch) {
			s := string_at(*t, 1);
			Basic.array_add(*tokens, s);
			advance(*t);
		} else if ch == #char "\"" {
			advance(*t);
			Basic.array_add(*tokens, eat_until(*t, #char "\""));
			advance(*t);
		} else {
			// Otherwise ignore anything we don't recognise
			advance(*t);
		}
	}
	return tokens;
}


Tokenizer :: struct {
	data: string;
	cur: int;
}

string_at :: (t: *Tokenizer, count: int) -> string {
	return string_at(t, t.cur, count);
}

string_at :: (t: *Tokenizer, start: int, count: int) -> string {
	s: string = ---;
	s.data = t.data.data + start;
	s.count = count;
	return s;
}

advance :: (t: *Tokenizer, amount := 1) {
	t.cur += amount;
}

current :: (t: *Tokenizer) -> u8 {
	return t.data[t.cur];
}

peek :: (t: *Tokenizer, amount := 1) -> u8 {
	return t.data[t.cur + amount];
}

eat_until :: (t: *Tokenizer, until: u8) -> string {
	start := t.cur;
	while true {
		ch := current(t);
		if ch != until {
			advance(t);
			continue;
		}
		break;
	}
	return string_at(t, start, t.cur-start);
}

eat_until :: (t: *Tokenizer, should_eat_func: (u8) -> bool) -> string {
	start := t.cur;
	while true {
		ch := current(t);
		if should_eat_func(ch) {
			advance(t);
			continue;
		}
		break;
	}
	return string_at(t, start, t.cur-start);
}

eat_ident :: (t: *Tokenizer) -> string {
	return eat_until(t, (ch: u8) -> bool {
		// TODO: Alternatively we could just eat until " "?
		return is_alpha(ch) || is_numeric(ch) || ch == #char "_";
	});
}

is_alpha :: (ch: u8) -> bool {
	return (ch >= #char "a" && ch <= #char "z") || (ch >= #char "A" && ch <= #char "Z");
}

is_numeric :: (ch: u8) -> bool {
	return ch >= #char "0" && ch <= #char "9";
}

is_allowed_special :: (ch: u8) -> bool {
	if ch == {
	case #char "="; #through;
	case #char ";"; #through;
	case #char "<"; #through;
	case #char ">"; #through;
	case #char "{"; #through;
	case #char "}"; #through;
	case #char "("; #through;
	case #char ")"; #through;
	case #char "["; #through;
	case #char "]"; #through;
	case #char "."; #through;
	case #char ","; 
		return true;
	}
	return false;
}

parse_protobuf_file :: (file_contents: string) -> Protobuf_File {
	protobuf_file: Protobuf_File;

	tokens := tokenize(file_contents);
	Basic.print("tokens=%\n", tokens);
	
	cur := 0;
	while cur < tokens.count {
		token := tokens[cur];

		if token == {
		case "syntax";
			// parse syntax"
			expect(tokens[cur + 1], "=");
			protobuf_file.syntax_version = tokens[cur + 2];
			expect(tokens[cur + 3], ";");
			cur += 4;
		case "import";
			import: Protobuf_Import;
			next := tokens[cur + 1];
			cur += 1;
			if next == "weak" {
				import.weak = true;
				cur += 1;
			} else if next == "public" {
				import.public = true;
				cur += 1;
			}
			import.name = tokens[cur];
			cur += 1;
			Basic.array_add(*protobuf_file.imports, import);
		case;
			cur += 1;
		}
	}

	return protobuf_file;
}

expect :: (token: string, expected: string) {
	if token != expected {
		Basic.print("expected %, got %\n", expected, token);
		Basic.assert(false);
	}
}

//
// https://protobuf.dev/reference/protobuf/proto2-spec/
// https://protobuf.dev/reference/protobuf/proto3-spec/
//

Protobuf_File :: struct {
	syntax_version: string;
	package: string;
	imports: [..] Protobuf_Import;
	options: [..] Protobuf_Option;
	messages: [..] Protobuf_Message;
}

Protobuf_Import :: struct {
	weak: bool;
	public: bool;
	name: string;
}

Protobuf_Option :: struct {
	name: string;
	value: string;
}

Protobuf_Message :: struct {
	name: string;
	fields: [..] Protobuf_Field;
	messages: [..] Protobuf_Message;
}

Protobuf_Field :: struct {
	// TODO: turn these into bitflags...
	repeated: bool;
	optional: bool;

	type: string;
	name: string;
	number: string;
}
