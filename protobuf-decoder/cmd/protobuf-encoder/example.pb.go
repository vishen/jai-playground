// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.31.0
// 	protoc        v4.25.1
// source: example.proto

package main

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Outer_Message struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Message_1 []*Message_1 `protobuf:"bytes,1,rep,name=message_1,json=message1,proto3" json:"message_1,omitempty"`
}

func (x *Outer_Message) Reset() {
	*x = Outer_Message{}
	if protoimpl.UnsafeEnabled {
		mi := &file_example_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Outer_Message) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Outer_Message) ProtoMessage() {}

func (x *Outer_Message) ProtoReflect() protoreflect.Message {
	mi := &file_example_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Outer_Message.ProtoReflect.Descriptor instead.
func (*Outer_Message) Descriptor() ([]byte, []int) {
	return file_example_proto_rawDescGZIP(), []int{0}
}

func (x *Outer_Message) GetMessage_1() []*Message_1 {
	if x != nil {
		return x.Message_1
	}
	return nil
}

type Message_1 struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	SomeInt32   int32  `protobuf:"varint,1,opt,name=some_int32,json=someInt32,proto3" json:"some_int32,omitempty"`
	SomeFixed32 uint32 `protobuf:"fixed32,2,opt,name=some_fixed32,json=someFixed32,proto3" json:"some_fixed32,omitempty"`
	SomeFixed64 uint64 `protobuf:"fixed64,3,opt,name=some_fixed64,json=someFixed64,proto3" json:"some_fixed64,omitempty"`
	Query       string `protobuf:"bytes,4,opt,name=query,proto3" json:"query,omitempty"`
}

func (x *Message_1) Reset() {
	*x = Message_1{}
	if protoimpl.UnsafeEnabled {
		mi := &file_example_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Message_1) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Message_1) ProtoMessage() {}

func (x *Message_1) ProtoReflect() protoreflect.Message {
	mi := &file_example_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Message_1.ProtoReflect.Descriptor instead.
func (*Message_1) Descriptor() ([]byte, []int) {
	return file_example_proto_rawDescGZIP(), []int{1}
}

func (x *Message_1) GetSomeInt32() int32 {
	if x != nil {
		return x.SomeInt32
	}
	return 0
}

func (x *Message_1) GetSomeFixed32() uint32 {
	if x != nil {
		return x.SomeFixed32
	}
	return 0
}

func (x *Message_1) GetSomeFixed64() uint64 {
	if x != nil {
		return x.SomeFixed64
	}
	return 0
}

func (x *Message_1) GetQuery() string {
	if x != nil {
		return x.Query
	}
	return ""
}

var File_example_proto protoreflect.FileDescriptor

var file_example_proto_rawDesc = []byte{
	0x0a, 0x0d, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x22,
	0x38, 0x0a, 0x0d, 0x4f, 0x75, 0x74, 0x65, 0x72, 0x5f, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
	0x12, 0x27, 0x0a, 0x09, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x5f, 0x31, 0x18, 0x01, 0x20,
	0x03, 0x28, 0x0b, 0x32, 0x0a, 0x2e, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x5f, 0x31, 0x52,
	0x08, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x31, 0x22, 0x86, 0x01, 0x0a, 0x09, 0x4d, 0x65,
	0x73, 0x73, 0x61, 0x67, 0x65, 0x5f, 0x31, 0x12, 0x1d, 0x0a, 0x0a, 0x73, 0x6f, 0x6d, 0x65, 0x5f,
	0x69, 0x6e, 0x74, 0x33, 0x32, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x09, 0x73, 0x6f, 0x6d,
	0x65, 0x49, 0x6e, 0x74, 0x33, 0x32, 0x12, 0x21, 0x0a, 0x0c, 0x73, 0x6f, 0x6d, 0x65, 0x5f, 0x66,
	0x69, 0x78, 0x65, 0x64, 0x33, 0x32, 0x18, 0x02, 0x20, 0x01, 0x28, 0x07, 0x52, 0x0b, 0x73, 0x6f,
	0x6d, 0x65, 0x46, 0x69, 0x78, 0x65, 0x64, 0x33, 0x32, 0x12, 0x21, 0x0a, 0x0c, 0x73, 0x6f, 0x6d,
	0x65, 0x5f, 0x66, 0x69, 0x78, 0x65, 0x64, 0x36, 0x34, 0x18, 0x03, 0x20, 0x01, 0x28, 0x06, 0x52,
	0x0b, 0x73, 0x6f, 0x6d, 0x65, 0x46, 0x69, 0x78, 0x65, 0x64, 0x36, 0x34, 0x12, 0x14, 0x0a, 0x05,
	0x71, 0x75, 0x65, 0x72, 0x79, 0x18, 0x04, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x71, 0x75, 0x65,
	0x72, 0x79, 0x42, 0x08, 0x5a, 0x06, 0x2e, 0x3b, 0x6d, 0x61, 0x69, 0x6e, 0x62, 0x06, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_example_proto_rawDescOnce sync.Once
	file_example_proto_rawDescData = file_example_proto_rawDesc
)

func file_example_proto_rawDescGZIP() []byte {
	file_example_proto_rawDescOnce.Do(func() {
		file_example_proto_rawDescData = protoimpl.X.CompressGZIP(file_example_proto_rawDescData)
	})
	return file_example_proto_rawDescData
}

var file_example_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_example_proto_goTypes = []interface{}{
	(*Outer_Message)(nil), // 0: Outer_Message
	(*Message_1)(nil),     // 1: Message_1
}
var file_example_proto_depIdxs = []int32{
	1, // 0: Outer_Message.message_1:type_name -> Message_1
	1, // [1:1] is the sub-list for method output_type
	1, // [1:1] is the sub-list for method input_type
	1, // [1:1] is the sub-list for extension type_name
	1, // [1:1] is the sub-list for extension extendee
	0, // [0:1] is the sub-list for field type_name
}

func init() { file_example_proto_init() }
func file_example_proto_init() {
	if File_example_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_example_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Outer_Message); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_example_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Message_1); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_example_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_example_proto_goTypes,
		DependencyIndexes: file_example_proto_depIdxs,
		MessageInfos:      file_example_proto_msgTypes,
	}.Build()
	File_example_proto = out.File
	file_example_proto_rawDesc = nil
	file_example_proto_goTypes = nil
	file_example_proto_depIdxs = nil
}
