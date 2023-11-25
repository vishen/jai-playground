package main

import (
	"fmt"
	"log"
	"os"

	"google.golang.org/protobuf/proto"
)

//go:generate protoc -I=. --go_out=. example.proto

func main() {
	m := Message_1{
		SomeInt32:   150,
		SomeFixed32: 2,
		SomeFixed64: 1025,
		Query:       "Hello, world!",
	}

	outer := Outer_Message{
		Message_1: []*Message_1{&m, &m},
	}

	out, err := proto.Marshal(&outer)
	if err != nil {
		log.Fatal(err)
	}

	if err := os.WriteFile("example-proto", out, 0644); err != nil {
		log.Fatal(err)
	}
	fmt.Println("Wrote protobuf encoded message to 'example-proto")
}
