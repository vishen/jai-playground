Basic :: #import "Basic"()(MEMORY_DEBUGGER=true);
Socket :: #import "Socket";
System :: #import "System";
Posix :: #import "Posix";

main :: () {
	defer Basic.report_memory_leaks();

	client, success := http_client("google.com", 80);
	Basic.assert(success);

	http_get(client, "/");

}

HTTP_Client :: struct {
	host: string;
	port: int;
	socket: Socket.Socket;
}

http_get :: (c: HTTP_Client, path: string) {
	GET_REQUEST := #string DONE
GET % HTTP/1.0
Host: %


DONE
	request := Basic.tprint(GET_REQUEST, path, c.host);
	result := Socket.send(c.socket, xx request.data, xx request.count, 0);
	if result == -1 {
		Basic.print("unable to send request: % %", result, System.get_error_string(xx result));
		error := Socket.get_last_socket_error();
		Basic.print("unable to send request: % %", error, System.get_error_string(xx error));
		return;
	}

	buf: [1024]u8;
	result = Socket.recv(c.socket, xx buf.data, xx buf.count, 0);
	if result < 0 {
			Basic.print("error=%, error_string=%\n", Socket.get_last_socket_error(), System.get_error_string(xx result));
			return;
	}

	s: string;
	s.data = buf.data;
	s.count = result;
	Basic.print("%\n", s);
}

http_client :: (hostname: string, port: int) -> HTTP_Client, success: bool {
	hostname_c_string := Basic.to_c_string(hostname);
	defer Basic.free(hostname_c_string);

	addresses: *Socket.addrinfo;
	hints: Socket.addrinfo;
	hints.ai_family = Socket.AF_INET;
	hints.ai_socktype = .STREAM;
	hints.ai_protocol = .TCP;

	result := Socket.getaddrinfo(hostname_c_string, null, *hints, *addresses);
	if result != 0 {
		Basic.print("unable to look up %: % %", hostname, result, System.get_error_string(xx result));
		return .{}, false;
	}
	defer Socket.freeaddrinfo(addresses);

	address := addresses[0].ai_addr;
	address_len := addresses[0].ai_addrlen;
	address_v4 := cast(*Socket.sockaddr_in) address;
	address_v4.sin_port = Posix.htons(xx port);

	sock := Socket.socket(Socket.AF_INET, .STREAM, .TCP);
	if sock == Socket.INVALID_SOCKET  {
		error := Socket.get_last_socket_error();
		Basic.print("unable tp create socket: % %", error, System.get_error_string(xx error));
		return .{}, false;
	}

	success := Socket.set_keepalive(sock, true, idle_seconds_before_keepalive = 10, keepalive_interval_seconds = 5, num_keepalive_attempts = 4);
	if !success {
		return .{}, false;
	}

	result = Socket.connect(sock, address, xx address_len);
	if result != 0 {
		error := Socket.get_last_socket_error();
		Basic.print("unable to connect to %:%: error % %", hostname, port, error, System.get_error_string(error));
		Socket.close_and_reset(*sock);
		return .{}, false;
	}
	return HTTP_Client.{host=hostname, port=port, socket=sock}, true;
}
