Basic :: #import "Basic";
String :: #import "String";

My_Enum :: enum {
	Value_1;
	Value_2;
	Value_3;
	Value_4;
}

My_Struct :: struct {
	key_string: string = "abc";
	
	key_int: int = 1;
	key_int32: int = 2;
	key_int64: int = 3;
	key_u64: int = 4;
	
	key_float32: float32 = 22.2; @json(name=key_float32_renamed) @OtherTag
	key_float64: float64 = 33.3; @OtherTag
	
	key_struct: My_Other_Struct;

	key_enum: My_Enum = .Value_3;

	key_array_fixed_string: [3] string = .["one", "two", "three"]; 
	key_array_fixed_struct: [3] My_Other_Struct; 

	key_array_fixed_int: [2] int = .[1, 2]; // Type_Info_Array{info = {ARRAY, 16}; element_type = 1_012b_1000; array_type = FIXED; array_count = 2; }
	key_array_resizable_int: [..]int; // Type_Info_Array{info = {ARRAY, 40}; element_type = 1_012b_1000; array_type = RESIZABLE; array_count = -1; }
	key_array_view_int: []int; // Type_Info_Array{info = {ARRAY, 16}; element_type = 1_012b_1000; array_type = VIEW; array_count = -1; }
}

My_Other_Struct :: struct {
	key_int: int = 10;
	key_bool_true: bool = true;
	key_bool_false: bool = false;
}

serialize :: (t: $T) 
#modify{
	ti := cast(*Type_Info) T;
	return ti.type == .STRUCT;
}
{
	Basic.print("Got % of type %\n", t, T);

	builder: Basic.String_Builder;
	Basic.init_string_builder(*builder);
	
	serialize(*builder, cast(*void) *t, cast(*Type_Info_Struct) T);

	s := Basic.builder_to_string(*builder);
	defer Basic.free(s.data);

	Basic.print("json: %\n", s);
}

serialize :: (builder: *Basic.String_Builder, data: *void, ti: *Type_Info_Struct){
	Basic.append(builder, #char "{");

	for member, index: ti.members {
		opts := parse_notes(member.notes);

		name := member.name;
		if opts.rename_to {
			name = opts.rename_to;
		}
		Basic.print_to_builder(builder, "\"%\":", name);
		if member.type.type == {
		case;
			serialize(builder, data + member.offset_in_bytes, member.type);
		case .ARRAY;
			Basic.append(builder, #char "[");

			array_info := cast(*Type_Info_Array) member.type;
			array_data: *void = ---;
			array_count: s64 = ---;
			if array_info.array_type == .FIXED {
				array_data = data + member.offset_in_bytes;
				array_count = array_info.array_count;
			} else {
				// For .RESIZABLE and .VIEW arrays
				// The runtime representation of an array view is just an s64 indicating
				// the number of elements, and a data pointer indicating the base of the array.
				array_count = << cast(*s64) (data + member.offset_in_bytes);

				array_dest: **void = data + member.offset_in_bytes + 8;
				array_data = << array_dest;
			}

			element_size := array_info.element_type.runtime_size;
			for 0..array_count-1 {
				serialize(builder, array_data, array_info.element_type);
				array_data += element_size;
				if it < array_count-1  Basic.append(builder, #char ",");
			}

			Basic.append(builder, #char "]");
		}
		if index < ti.members.count-1  Basic.append(builder, #char ",");
	}

	Basic.append(builder, #char "}");
}

serialize :: (builder: *Basic.String_Builder, data: *void, info: *Type_Info) {
	Basic.assert(info != null);
	Basic.assert(data != null);

	if info.type == {
	case;
		Basic.print("unexpected type %\n", info.type);
		Basic.assert(false);
	case .BOOL;
		Basic.append(builder, ifx <<(cast(*bool) data ) "true" else "false");
	case .STRING; #through;
	case .INTEGER; #through;
	case .FLOAT; 
		to_json_value(builder, data, info);
	case .STRUCT;
		struct_info := cast(*Type_Info_Struct) info;
		Basic.assert(struct_info != null);
		serialize(builder, data, struct_info);
	case .ENUM;
		enum_info := cast(*Type_Info_Enum) info;

		// Taken from modules/Basic/Print.jai
		info_int  := cast(*Type_Info_Integer) enum_info.internal_type;
		Basic.assert(info_int.type == .INTEGER);

		size := info_int.runtime_size;

		target_value_s64 := Basic.get_s64_from_void_pointer(data, size);
		if info_int.signed {
			for enum_info.values  if target_value_s64 == it {
				Basic.print_to_builder(builder, "\"%\"", enum_info.names[it_index]);
				break;
			}
		} else {
			target_value_u64 := Basic.get_u64_from_void_pointer(data, size);
			for enum_info.values  if target_value_u64 == cast,no_check(u64) it {
				Basic.print_to_builder(builder, "\"%\"", enum_info.names[it_index]);
				break;
			}
		}
	}
}

to_json_value :: (builder: *Basic.String_Builder, value: *void, type: *Type_Info) {
	value_: Any;
	value_.value_pointer = value;
	value_.type = type;
	// Basic.print("to_json_value: %\n", value_);
	
	if type.type == .STRING {
		Basic.append(builder, #char "\"");
	}
	Basic.print_to_builder(builder, "%", value_);
	if type.type == .STRING {
		Basic.append(builder, #char "\"");
	}
}

JSON_NOTES_PREFIX :: "json(";

JSON_Options :: struct {
	rename_to: string;
}

parse_notes :: (notes: []string) -> JSON_Options {
	if notes.count == 0  return .{};
	opts: JSON_Options;

	for *note: notes {
		s: string;
		s.data = note.data;
		s.count = JSON_NOTES_PREFIX.count;
		if s != JSON_NOTES_PREFIX  continue;

		note.data += JSON_NOTES_PREFIX.count;
		note.count -= JSON_NOTES_PREFIX.count;
		if note.data[note.count-1] == #char ")"  note.count -= 1; // TODO: Assert that this is expected

		for part: String.split(<< note, ",") {
			key_and_value := String.split(part, "=");
			if key_and_value[0] == {
			case "name"; opts.rename_to = key_and_value[1];
			}
		}
	}

	return opts;
}

main :: () {
	m: My_Struct;
	Basic.array_add(*m.key_array_resizable_int, 10, 11, 12);
	m.key_array_view_int = m.key_array_fixed_int;

	serialize(m);
}

struct_formatter :: (value: Any) -> Basic.FormatStruct {
	return .{
		value=value,
		draw_type_name=true,
		use_long_form_if_more_than_this_many_members=-1,
	};
};
