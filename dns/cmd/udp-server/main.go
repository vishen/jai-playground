package main

import (
	"flag"
	"fmt"
	"log"
	"net"
)

var flagPort = flag.Int("port", 8053, "port to run on")

func main() {
	flag.Parse()

	log.Printf("listening on udp :%d", *flagPort)
	// listen to incoming udp packets
	pc, err := net.ListenPacket("udp", fmt.Sprintf(":%d", *flagPort))
	if err != nil {
		log.Fatal(err)
	}
	defer pc.Close()

	for {
		buf := make([]byte, 1024)
		n, addr, err := pc.ReadFrom(buf)
		if err != nil {
			log.Printf("err: %v", err)
			continue
		}
		go serve(pc, addr, buf[:n])
	}

}

func serve(pc net.PacketConn, addr net.Addr, buf []byte) {
	// 0 - 1: ID
	// 2: QR(1): Opcode(4)
	// buf[2] |= 0x80 // Set QR bit
	log.Printf("buf: %v", buf)

	pc.WriteTo(buf, addr)
}
