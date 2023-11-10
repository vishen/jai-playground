Basic :: #import "Basic";
Socket :: #import "Socket";
System :: #import "System";
Posix :: #import "Posix";

// https://www.ibm.com/docs/en/zos/2.3.0?topic=programs-c-socket-udp-client
// https://w3.cs.jmu.edu/kirkpams/OpenCSF/Books/csf/html/UDPSockets.html
// https://github.com/vishen/go-dnsquery/blob/master/main.go


main :: () {
	Basic.print("DNS query...\n");

	hostname := "127.0.0.1";
	hostname_c_string := Basic.to_c_string(hostname);
    defer Basic.free(hostname_c_string);

    addresses: *Socket.addrinfo;
    hints: Socket.addrinfo;
    hints.ai_family = Socket.AF_INET;
    hints.ai_socktype = .DGRAM;
    // hints.ai_protocol = .UDP;
    hints.ai_flags = Socket.AI.V4MAPPED_CFG | .ADDRCONFIG;
    result := Socket.getaddrinfo(hostname_c_string, null, *hints, *addresses);
    if result != 0 {
         Basic.log_error("Could not look up \"%\": % %", hostname, result, System.get_error_string(xx result));
		 Basic.assert(false);
    }
	Basic.print("result: %, addresses:%, ai_add=%\n", result, addresses.*, addresses[0].ai_addr.*);
    defer Socket.freeaddrinfo(addresses);

	address := addresses[0].ai_addr;
    address_len := addresses[0].ai_addrlen;
	address_v4 := cast(*Socket.sockaddr_in) address;
	address_v4.sin_port = Posix.htons(8053);


	// Socket.send(1, cast(*void) 1, xx 1, 1);
	// https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/socket.2.html
	//  socket(int domain, int type, int protocol);
	// socket :: (unknown0: s32, unknown1: SOCK, unknown2: IPPROTO) -> s32 #foreign libc;
	s := Socket.socket(Socket.AF_INET, .DGRAM, 0);
	if s < 0 {
		error := Socket.get_last_socket_error();
		Basic.print("error=%\n", error);
		Basic.assert(false);
	}
	Basic.print("Socket: %\n", s);

	data := "Hello";
	// sendto :: (unknown0: s32, unknown1: *void, unknown2: u64, unknown3: MSG, unknown4: *sockaddr, unknown5: socklen_t) -> ssize_t #foreign libc;
	// sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);

	r := Socket.sendto(s, xx data.data, xx data.count, 0, address, xx address_len);
	if r < 0 {
		Basic.print("error=%, error_string=%\n", Socket.get_last_socket_error(),System.get_error_string(xx r));
		Basic.assert(false);
	}
	Basic.print("r=%\n", r);

	// ssize_t recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len)
	// recvfrom :: (unknown0: s32, unknown1: *void, unknown2: u64, unknown3: MSG, unknown4: *sockaddr, unknown5: *socklen_t) -> ssize_t #foreign libc;
	BUFLEN :: 128;
	client: Socket.sockaddr_in;
    client_size := size_of(type_of(client));
    buf: [BUFLEN]u8;
	r = Socket.recvfrom(s, xx buf.data, xx buf.count, 0, xx *client, xx *client_size);
	if r < 0 {
		Basic.print("error=%, error_string=%\n", Socket.get_last_socket_error(),System.get_error_string(xx r));
		Basic.assert(false);
	}
	Basic.print("r=%\n", r);
	Basic.print("buf: %\n", buf);
	Basic.print("client: %\n", client);
}
