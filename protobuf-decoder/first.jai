Basic :: #import "Basic";
File :: #import "File";

main :: () {
	file, success := File.file_open("example-proto");
	Basic.assert(success);

	length := File.file_length(file);
	buffer := cast(*u8) Basic.alloc(length);

	success = File.file_read(file, buffer, length);
	Basic.assert(success);

	encoded: []u8;
	encoded.data = buffer;
	encoded.count = length;

	Basic.print("encoded: %\n", encoded);

	p := Parser.{data=buffer, length=length};
	parse(*p);
}

// 0	VARINT	int32, int64, uint32, uint64, sint32, sint64, bool, enum
// 1	I64	fixed64, sfixed64, double
// 2	LEN	string, bytes, embedded messages, packed repeated fields
// 5	I32	fixed32, sfixed32, float
Proto_Type :: enum {
	VARINT :: 0;
	I64 :: 1;
	LEN :: 2;
	I32 :: 5;
}

Parser :: struct {
	data: *u8;
	length: int;
}

advance :: (p: *Parser, count := 1) {
	p.data += count;
	p.length -= count;
}

parse :: (p: *Parser, length: u64 = 0, indent := 0) {
	varint := parse_varint(p);
	field_number, type := metadata(varint);
	for 0..indent Basic.print(">");
	Basic.print("field_number=%, type=%: ", field_number, type);

	if type == {
	case;
		Basic.assert(false);
	case .I32;
		fixed32: u32 = 0;
		for 0..3 {
			value := cast(u32) (<< p.data);
			advance(p);
			fixed32 |= (value << (it * 8));
		}
		Basic.print("i32= %\n", fixed32);
	case .I64;
		fixed64: u64 = 0;
		for 0..7 {
			value := cast(u32) (<< p.data);
			advance(p);
			fixed64 |= (value << (it * 8));
		}
		Basic.print("i64= %\n", fixed64);
	case .VARINT;
		varint := parse_varint(p);
		Basic.print("varint= %\n", varint);
	case .LEN;
		length := parse_varint(p);
		if looks_like_string(p, length) {
			s: string;
			s.data = p.data;
			s.count = xx length;
			Basic.print("len of % (likely string)= %\n", length, s);
		} else if looks_like_message(p, length) {
			Basic.print("len of % (likely message)\n", length);
			parse(p, length, indent + 1);
			return;
		} else {
			b: []u8;
			b.data = p.data;
			b.count = xx length;
			Basic.print("len of %= %\n", length, b);
		}
		advance(p, xx length);
	}

	if p.length <= 0 {
		return;
	}

	parse(p, indent=indent);
}

MIN_FIELD_NUMBER :: 1;
MAX_FIELD_NUMBER :: ((1<<29) - 1);

// TODO: Get these from type enum??
MIN_TYPE :: 0;
MAX_TYPE :: 5;

looks_like_message :: (p: Parser, length: u64) -> bool {
	v := << p.data;
	field_number, type := metadata(xx v);
	return (v >> 7 == 0) && field_number >= MIN_FIELD_NUMBER && field_number <= MAX_FIELD_NUMBER && type >= MIN_TYPE && type <= MAX_TYPE;
}

looks_like_string :: (p: Parser, length: u64) -> bool {
	for 0..length-1 {
		v := (<< (p.data + it));
		if v >= 32 && v <= 127 continue;
		return false;
	}
	return true;
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

		advance(p);
		defer count += 1;

		varint += (value & 0b0111_1111) << (7 * count);

		// Basic.print("varint=%, value=%, data=%\n", varint, value, data);

		msb := value >> 7;
		if msb == 0 {
			return varint;
		}
	}
}

