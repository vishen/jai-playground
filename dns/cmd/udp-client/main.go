package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

func main() {

	// Resolve the string address to a UDP address
	udpAddr, err := net.ResolveUDPAddr("udp", "0.0.0.0:8053")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Dial to the address with UDP
	conn, err := net.DialUDP("udp", nil, udpAddr)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Send a message to the server
	_, err = conn.Write([]byte("Hello UDP Server\n"))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Read from the connection untill a new line is send
	data, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		fmt.Println(err)
		return
	}

	// Print the data read from the connection to the terminal
	fmt.Print("> ", string(data))
}
