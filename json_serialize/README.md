# JSON Serialize

Serialize a Jai struct into JSON. Can only serialize the following types:

- integers
- floats
- strings
- bool
- enum
- struct (with only types in this list)
- array; fixed, resizable and view (with only types in this list)

```
$ jai-macos first.jai && ./first
Got {key_string = "abc"; key_int = 1; key_int32 = 2; key_int64 = 3; key_u64 = 4; key_float32 = 22.200001; key_float64 = 33.3; key_struct = {10, true, false}; key_enum = Value_3; key_array_fixed_string = ["one", "two", "three"]; key_array_fixed_struct = [{10, true, false}, {10, true, false}, {10, true, false}]; key_array_fixed_int = [1, 2]; key_array_resizable_int = [10, 11, 12]; key_array_view_int = [1, 2]; } of type My_Struct
json: {"key_string":"abc","key_int":1,"key_int32":2,"key_int64":3,"key_u64":4,"key_float32":22.200001,"key_float64":33.3,"key_struct":{"key_int":10,"key_bool_true":true,"key_bool_false":false},"key_enum":"Value_3","key_array_fixed_string":["one","two","three"],"key_array_fixed_struct":[{"key_int":10,"key_bool_true":true,"key_bool_false":false},{"key_int":10,"key_bool_true":true,"key_bool_false":false},{"key_int":10,"key_bool_true":true,"key_bool_false":false}],"key_array_fixed_int":[1,2],"key_array_resizable_int":[10,11,12],"key_array_view_int":[1,2]}
```
