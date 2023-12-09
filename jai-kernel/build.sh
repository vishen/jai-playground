#!/bin/bash

docker build -t kernel-builder -f Dockerfile.kernel-builder .
id=$(docker create kernel-builder)
mkdir builds
docker cp $id:/kernel/kernel.iso builds/kernel.iso
docker cp $id:/kernel/isofiles/boot/kernel.bin builds/kernel.bin
docker rm -v $id
