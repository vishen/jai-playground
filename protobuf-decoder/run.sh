#!/bin/bash
set -e

go generate ./...
go run ./cmd/protobuf-encoder
jai-macos first.jai && ./first
