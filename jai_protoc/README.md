# Protoc generator for Jai

## Running
    $ jai-macos first.jai
    $ protoc --jai_out=paths=source_relative:. -I. --plugin=protoc-gen-jai=./first  example.proto

## Resources

- https://protobuf.dev/programming-guides/encoding/
