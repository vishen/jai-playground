Basic :: #import "Basic"()(MEMORY_DEBUGGER=true);
Socket :: #import "Socket";
System :: #import "System";
Posix :: #import "Posix";

RESPONSE_SIZE :: 1024;

main :: () {
	defer Basic.report_memory_leaks();

	host := "httpbin.org";

	client, success := http_client(host, 80);
	Basic.assert(success);

	headers: HTTP_Headers;
	add_header(*headers, "My-Dynamic-Header", "12345");

	http_request(client, "POST", "/anything?key=value1&key=value2&other_key=value", headers);
}

HTTP_Client :: struct {
	host: string;
	port: int;
	socket: Socket.Socket;
}

HTTP_Headers :: struct {
	keys: [..] string;
	keys.allocator = Basic.temp;

	values: [..] string;
	values.allocator = Basic.temp;
}

add_header :: (headers: *HTTP_Headers, key: string, value: string) {
	Basic.array_add(*headers.keys, key);
	Basic.array_add(*headers.values, value);
}

to_string :: (headers: HTTP_Headers) -> string {
	 Basic.assert(headers.keys.count == headers.values.count);

	 builder: Basic.String_Builder;
	 Basic.init_string_builder(*builder);

	for 0..headers.keys.count-1 {
		Basic.print_to_builder(*builder, "%: %\n", headers.keys[it], headers.values[it]);
	}
	s := Basic.builder_to_string(*builder);
	s.count -=1;
	return s;
}

http_request :: (c: HTTP_Client, http_method: string, path: string, headers := HTTP_Headers.{}) {
	REQUEST := #string DONE
% % HTTP/1.0
Host: %
%


DONE

	headers_string := to_string(headers);
	defer Basic.free(headers_string.data);

	request := Basic.tprint(REQUEST, http_method, path, c.host, headers_string);
	result := Socket.send(c.socket, xx request.data, xx request.count, 0);
	if result == -1 {
		Basic.print("unable to send request: % %", result, System.get_error_string(xx result));
		error := Socket.get_last_socket_error();
		Basic.print("unable to send request: % %", error, System.get_error_string(xx error));
		return;
	}

	buf: [RESPONSE_SIZE]u8;
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


/*
HTTP_Headers :: struct(Key_Type: Type, Value_Type: Type) {
	keys: [..] Key_Type;
	keys.allocator = Basic.temp;

	values: [..] Value_Type;
	values.allocator = Basic.temp;
}

add_header :: (headers: *HTTP_Headers, key: headers.Key_Type, value: headers.Value_Type) {
	Basic.array_add(*headers.keys, key);
	Basic.array_add(*headers.values, value);
}
*/
