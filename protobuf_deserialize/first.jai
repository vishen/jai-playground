Basic :: #import "Basic";
String :: #import "String";
File :: #import "File";

main :: () {
	file, success := File.file_open("example-proto");
	Basic.assert(success);

	length := File.file_length(file);
	buffer := cast(*u8) Basic.alloc(length);

	success = File.file_read(file, buffer, length);
	Basic.assert(success);

/*
	encoded: []u8;
	encoded.data = buffer;
	encoded.count = length;

	Basic.print("(%) encoded: %\n", length, encoded);
*/
	decoded := parse(buffer);
	Basic.print("decoded: %\n", struct_formatter(decoded));
}

Message_1 :: struct {
	some_int32: u64; @proto(field_number=1,type=varint)
	some_fixed32: u32; @proto(field_number=2,type=fixed32)
	some_fixed64: u64; @proto(field_number=3,type=fixed64)
	some_string: string; @proto(field_number=4,type=len)
}

// 0	VARINT	int32, int64, uint32, uint64, sint32, sint64, bool, enum
// 1	I64	fixed64, sfixed64, double
// 2	LEN	string, bytes, embedded messages, packed repeated fields
// 5	I32	fixed32, sfixed32, float
Proto_Type :: enum {
	VARINT :: 0;
	FIXED64 :: 1;
	LEN :: 2;
	FIXED32 :: 5;
}

PROTO_NOTES_PREFIX :: "proto(";

Proto_Opts :: struct {
	field_number: int;
	type: Proto_Type;
}

add_field_number :: (o: *Proto_Opts, n: string) {
	result, success, remainder := Basic.string_to_int(n);
	if !success {
		Basic.assert(false);
	}
	o.field_number = result;
}

add_type :: (o: *Proto_Opts, t: string) {
	if t == {
	case "varint"; o.type = .VARINT;
	case "fixed32"; o.type = .FIXED32;
	case "fixed64"; o.type = .FIXED64;
	case "len"; o.type = .LEN;
	case;
		Basic.assert(false);
	}

}

parse_notes :: (notes: []string) -> Proto_Opts {
	if notes.count == 0  return .{};
	
	opts: Proto_Opts;
	for *note: notes {
		s: string;
		s.data = note.data;
		s.count = PROTO_NOTES_PREFIX.count; if s != PROTO_NOTES_PREFIX  continue;

		note.data += PROTO_NOTES_PREFIX.count;
		note.count -= PROTO_NOTES_PREFIX.count;
		if note.data[note.count-1] == #char ")"  note.count -= 1; // TODO: Assert that this is expected

		for part: String.split(<< note, ",") {
			key_and_value := String.split(part, "=");
			if key_and_value[0] == {
			case "field_number"; add_field_number(*opts, key_and_value[1]);
			case "type"; add_type(*opts, key_and_value[1]);
			}
		}
	}
	return opts;
}

Parser :: struct {
	data: *u8;
}

parse :: (data: *u8) -> Message_1 {
	return parse(*Parser.{data=data});
}

parse :: (p: *Parser) -> Message_1 {
	m: Message_1;
	ti := cast(*Type_Info_Struct) type_of(m);

	Proto_Member :: struct {
		opts: Proto_Opts;
		member: Type_Info_Struct_Member;
	}

	proto_members: [..]Proto_Member;

	find_member :: (proto_members: [..]Proto_Member, field_number: int) -> Proto_Member {
		for proto_members {
			if it.opts.field_number == field_number {
				return it;
			}
		}
		Basic.assert(false);
	}

	for member: ti.members {
		opts := parse_notes(member.notes);
		if member.type.type == {
		case;
			Basic.print("unhandled member type %\n", member.type.type);
			Basic.assert(false);
		case .INTEGER; #through;
		case .STRING;
			/*
			tii := cast(*Type_Info_Integer) member.type;
			signed := tii.signed;
			size := tii.runtime_size;
			*/
			Basic.array_add(*proto_members, .{
				opts=opts,
				member=member,
			});
		}
	}
	while true {
		varint := parse_varint(p);
		field_number, type := metadata(varint);
		member := find_member(proto_members, xx field_number);

		if type == {
		case .VARINT;
			varint := parse_varint(p);
			// Basic.print("> varint: %\n", varint);
			{
				#import "Basic";
				memcpy( (cast(*u8)*m) + member.member.offset_in_bytes, cast(*u8) *varint, 8);
			}
		case .FIXED32;
			fixed32: u32 = 0;
			for 0..3 {
				value := cast(u32) (<< p.data);
				p.data += 1;
				fixed32 |= (value << (it * 8));
			}
			{
				#import "Basic";
				memcpy( (cast(*u8)*m) + member.member.offset_in_bytes, cast(*u8) *fixed32, 4);
			}
		case .FIXED64;
			fixed64: u64 = 0;
			for 0..7 {
				value := cast(u32) (<< p.data);
				p.data += 1;
				fixed64 |= (value << (it * 8));
			}
			{
				#import "Basic";
				memcpy( (cast(*u8)*m) + member.member.offset_in_bytes, cast(*u8) *fixed64, 8);
			}
			break;
		}
	}

	return m;
}

metadata :: (varint: u64) -> (field_number: u64, type: Proto_Type) { // TODO: Change return sizes, they don't need to be this big.
	field_number := (varint >> 3) & 0b1111;
	type := varint & 0b111;
	return field_number, cast(Proto_Type) type;
}

parse_varint :: (p: *Parser) -> (varint: u64) {
/*
Variable-width integers, or varints, are at the core of the wire format. They allow encoding unsigned 64-bit integers using anywhere between one and ten bytes, with small values using fewer bytes.

Each byte in the varint has a continuation bit that indicates if the byte that follows it is part of the varint. This is the most significant bit (MSB) of the byte (sometimes also called the sign bit). The lower 7 bits are a payload; the resulting integer is built by appending together the 7-bit payloads of its constituent bytes.
*/

	count := 0;

	varint: u64;
	while true {
		data := << p.data;
		value := cast(u64) data;

		// advance(p);
		p.data += 1;
		defer count += 1;

		varint += (value & 0b0111_1111) << (7 * count);

		// Basic.print("varint=%, value=%, data=%\n", varint, value, data);

		msb := value >> 7;
		if msb == 0 {
			return varint;
		}
	}
}

struct_formatter :: (value: Any) -> Basic.FormatStruct {
	return .{
		value=value,
		draw_type_name=true,
		use_long_form_if_more_than_this_many_members=-1,
	};
};
