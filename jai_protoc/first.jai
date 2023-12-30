Basic :: #import "Basic";
Posix :: #import "Posix";

main :: () {
	File :: #import "File";
	file, success := File.file_open("input");
	Basic.assert(success);

	length := File.file_length(file);
	buffer := cast(*u8) Basic.alloc(length);
	/*
	// crashes.
	length :: 4000;
	buffer: [length]u8;
	*/

	success2, read := File.file_read(file, buffer, length);
	Basic.assert(success2);

	/*
	data : []u8;
	data.data = buffer;
	data.count = read;
	Basic.print("%\n", data);
	*/
	parse(buffer);
}

metadata :: (data: *u8) -> (msb := 0, field_number := 0, type := 0) {
	md := cast(s64) (<< data);

	msb := md >> 7;
	Basic.assert(msb == 0); // TODO: Handle variable width encoding
	
	field_number := (md >> 3) & 0b1111;
	type := md & 0b111;

	return msb, field_number, type;
}

print_indent :: (indent: int){
	for 0..indent  Basic.print(">");
	if indent > 0 Basic.print(" ");
}

parse :: (data: *u8, indent := 0) {

	msb, field_number, type := metadata(data);
	cur_data := data;
	print_indent(indent);
	Basic.print("msb=%, field_number=%, type=%\n", msb, field_number, type);
	data += 1;

	if field_number == 0 { // This is the length for an array of structs.
		parse(data, indent);
		return;
	}

	// 0	VARINT	int32, int64, uint32, uint64, sint32, sint64, bool, enum
	// 1	I64	fixed64, sfixed64, double
	// 2	LEN	string, bytes, embedded messages, packed repeated fields
	// 5	I32	fixed32, sfixed32, float
	if type == {
	case;
		Basic.print("unexpected type % for field_number % (data=%)\n", type, field_number, cast(s64) (<< cur_data));
		// Basic.assert(false);
		return;
	case 0;
		varint: u64;
		while true {
			value := cast(u64) (<< data);
			
			varint << 8;
			varint |= value;
			data += 1;

			msb := value >> 7;
			if msb == 0 {
				print_indent(indent);
				Basic.print("%\n", value);
				break;
			}
		}
		parse(data, indent);
	case 2;
		length := cast(s64) (<< data);
		data += 1;
		if cast(s64) (<< data) >= 32 {
			// Likely string / bytes
			s: string;
			s.count = length;
			s.data = data;
			data += length;
			print_indent(indent);
			Basic.print("%\n", s);
			parse(data, indent);
		} else {
			// Likely message
			parse(data, indent + 1);
		}
	}
}

// https://ngtzeyang94.medium.com/go-with-examples-protobuf-encoding-mechanics-54ceff48ebaa
// https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/compiler/plugin.proto
// https://pkg.go.dev/google.golang.org/protobuf/types/pluginpb#CodeGeneratorRequest

Code_Generator_Request :: struct {
	file_to_generate: [..]string; @Proto_1
	parameter: string; @Proto_2
	// file_to_generate: [..]string; // FileToGenerate []string `protobuf:"bytes,1,rep,name=file_to_generate,json=fileToGenerate" json:"file_to_generate,omitempty"`
	// parameter: string; // Parameter *string `protobuf:"bytes,2,opt,name=parameter" json:"parameter,omitempty"`
	// https://pkg.go.dev/google.golang.org/protobuf@v1.31.0/types/descriptorpb#FileDescriptorProto
	// ProtoFile []*descriptorpb.FileDescriptorProto // `protobuf:"bytes,15,rep,name=proto_file,json=protoFile" json:"proto_file,omitempty"` 
	// CompilerVersion *Version `protobuf:"bytes,3,opt,name=compiler_version,json=compilerVersion" json:"compiler_version,omitempty"`
}

/*
type FileDescriptorProto struct {
	Name    *string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`       // file name, relative to root of source tree
	Package *string `protobuf:"bytes,2,opt,name=package" json:"package,omitempty"` // e.g. "foo", "foo.bar", etc.
	...
}

type Version struct {
	Major *int32 `protobuf:"varint,1,opt,name=major" json:"major,omitempty"`
	Minor *int32 `protobuf:"varint,2,opt,name=minor" json:"minor,omitempty"`
	Patch *int32 `protobuf:"varint,3,opt,name=patch" json:"patch,omitempty"`
	// A suffix for alpha, beta or rc release, e.g., "alpha-1", "rc2". It should
	// be empty for mainline stable releases.
	Suffix *string `protobuf:"bytes,4,opt,name=suffix" json:"suffix,omitempty"`
	// contains filtered or unexported fields
}
*/

main_old :: () {
	// Basic.print("protoc compiler for Jai\n");

	/*
	SIZE :: 8192;
	buf: [SIZE]u8;
	// https://stackoverflow.com/questions/15883568/reading-from-stdin
	// TODO: while(read(STDIN_FILENO, &ch, 1) > 0)
	r := Posix.read(Posix.STDIN_FILENO, xx buf.data, xx buf.count);
	*/

	/*
	File :: #import "File";
	File.write_entire_file("input", buf.data, r);
	*/
	// Basic.print("r=%\n", r);
	// data := buf.data;
	/*
	Basic.print("%: %\n", type_of(data), data[0]);
	msb, field_number, type := metadata(data);
	Basic.print("%, %, %\n", msb, field_number, type);
	*/
	// parse(data);
	// Basic.print("r=%\n", r);
	// Basic.print("%\n", buf);
	
	/*
	for 0..2 {
		metadata := cast(s64) (<< data);
		msb := metadata >> 7;
		Basic.assert(msb == 0); // TODO: Handle variable width encoding
		
		field_number := (metadata >> 3) & 0b1111;
		type := metadata & 0b111;
		Basic.print("%, %, %\n", msb, field_number, type);

		data += 1;

		Basic.assert(type == 2);

		count := cast(s64) (<< data);
		data += 1;
		s: string;
		s.data = data;
		s.count = count;
		Basic.print("%\n", s);
		data += count;
	}
	*/
}

