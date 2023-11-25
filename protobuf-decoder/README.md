# Protobuf Decoder

A very basic and still work-in-progress protobuf decoder that doesn't use the protobuf 
definition to parse but currently attempts to "guess" whether the next entry is a "message", 
and if so attempt to decode that.

This can be improved to backtrack if we can't parse a message correctly. But currently
it doesn't do any of that and just gives the best approximation.

This handles all protobuf types correctly, but currently prints out repeated nested
messages depth slightly incorrectly.

```
message Outer_Message {
  repeated Message_1 message_1 = 1;
}

message Message_1 {
  int32 some_int32 = 1;
  fixed32 some_fixed32 = 2;
  fixed64 some_fixed64 = 3;
  string query = 4;
}
```

With this as the data:

```
m := Message_1{
    SomeInt32:   150,
    SomeFixed32: 2,
    SomeFixed64: 1025,
    Query:       "Hello, world!",
}

outer := Outer_Message{
    Message_1: []*Message_1{&m, &m},
}
```

This would result in:

```
$ jai-macos first.jai && ./first
>field_number=1, type=LEN: len of 32 (likely message)
>>field_number=1, type=VARINT: varint= 150
>>field_number=2, type=I32: i32= 2
>>field_number=3, type=I64: i64= 1025
>>field_number=4, type=LEN: len of 13 (likely string)= Hello, world!
>>field_number=1, type=LEN: len of 32 (likely message)
>>>field_number=1, type=VARINT: varint= 150
>>>field_number=2, type=I32: i32= 2
>>>field_number=3, type=I64: i64= 1025
>>>field_number=4, type=LEN: len of 13 (likely string)= Hello, world!
```
