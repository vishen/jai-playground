# Protobuf Deserialize

A basic protobuf deserializer. Very very basic work in progress.

```
message Message_1 {
  int32 some_int32 = 1;
  fixed32 some_fixed32 = 2;
  fixed64 some_fixed64 = 3;
  string some_string = 4;
}
```

With this as the data:

```
m := Message_1{
    SomeInt32:   150,
    SomeFixed32: 2,
    SomeFixed64: 1025,
    SomeString:       "Hello, world!",
}
```

We can parse it into this Jai struct:

```
Message_1 :: struct {
	some_int32: u64; @proto(field_number=1,type=varint)
	some_fixed32: u32; @proto(field_number=2,type=fixed32)
	some_fixed64: u64; @proto(field_number=3,type=fixed64)
	some_string: string; @proto(field_number=4,type=len)
}
```

```
$ jai-macos first.jai && ./first
decoded: Message_1{some_int32 = 150; some_fixed32 = 2; some_fixed64 = 1025; some_string = ""; }
```

## Resources

- https://protobuf.dev/programming-guides/encoding/
- https://dev.to/xpepermint/deep-dive-into-the-binary-algorithm-of-protocol-buffers-7j2
- https://github.com/protocolbuffers/protobuf-go/blob/v1.31.0/encoding/protowire/wire.go#L388
- https://www.protobufpal.com/
