Basic :: #import "Basic";

My_Struct :: struct {
	key_string: string = "abc";
	key_int: int = 1;
	key_int32: int = 2;
	key_int64: int = 3;
	key_float32: float32 = 22.2; @json(name=key_float_renamed)
	key_float64: float64 = 33.3;
	key_struct: My_Other_Struct;
}

My_Other_Struct :: struct {
	key_int: int = 10;
	key_bool_true: bool = true;
	key_bool_false: bool = false;
}

serialise :: (t: $T) 
#modify{
	ti := cast(*Type_Info) T;
	return ti.type == .STRUCT;
}
{
	Basic.print("Got % of type %\n", t, T);

	builder: Basic.String_Builder;
	Basic.init_string_builder(*builder);
	
	serialise(*builder, cast(*void) *t, cast(*Type_Info_Struct) T);

	s := Basic.builder_to_string(*builder);
	defer Basic.free(s.data);

	Basic.print("json: %\n", s);
}

serialise :: (builder: *Basic.String_Builder, data: *void, ti: *Type_Info_Struct){
	Basic.append(builder, #char "{");
	for member, index: ti.members {
		Basic.print_to_builder(builder, "\"%\":", member.name);
		
		if member.type.type == {
		case;
			Basic.print("unexpected type %\n", member.type.type);
			Basic.assert(false);
		case .BOOL;
			Basic.append(builder, ifx <<(cast(*bool) data) "true" else "false");
		case .STRING; #through;
		case .INTEGER; #through;
		case .FLOAT; 
			to_json_value(builder, data + member.offset_in_bytes, member.type);
		case .STRUCT;
			struct_info := cast(*Type_Info_Struct) member.type;
			serialise(builder, data + member.offset_in_bytes, struct_info);
		}

		if index < ti.members.count-1  Basic.append(builder, #char ",");
	}

	Basic.append(builder, #char "}");
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

main :: () {
	m: My_Struct;
	serialise(m);
}
