Basic :: #import "Basic"()(MEMORY_DEBUGGER=true);
Socket :: #import "Socket";
System :: #import "System";
Posix :: #import "Posix";
String :: #import "String";

// https://www.ibm.com/docs/en/zos/2.3.0?topic=programs-c-socket-udp-client
// https://w3.cs.jmu.edu/kirkpams/OpenCSF/Books/csf/html/UDPSockets.html
// https://github.com/vishen/go-dnsquery/blob/master/main.go

SIZE :: 128;

main :: () {
        defer Basic.report_memory_leaks();

        domain  := "example.com";

        Basic.print("DNS A record query for %...\n", domain);

        dns_questions: [..]DNS_Question;
        defer Basic.free(dns_questions.data);

        Basic.array_add(*dns_questions, .{
                domain=domain, 
                type=0x1,  // A record
                class=0x1, // Internet
        });
        dns_query := DNS_Query.{
                id=0xAAAA,
                rd=true,
                questions=dns_questions,
        };
        encoded := encode(dns_query);
        defer Basic.free(encoded.data);


        hostname := "8.8.8.8";
        port := 53;
        hostname_c_string := Basic.to_c_string(hostname);
        defer Basic.free(hostname_c_string);

        addresses: *Socket.addrinfo;
        hints: Socket.addrinfo;
        hints.ai_family = Socket.AF_INET;
        hints.ai_socktype = .DGRAM;
        result := Socket.getaddrinfo(hostname_c_string, null, *hints, *addresses);
        if result != 0 {
                Basic.log_error("Could not look up \"%\": % %", hostname, result, System.get_error_string(xx result));
                Basic.assert(false);
        }
        defer Socket.freeaddrinfo(addresses);

        address := addresses[0].ai_addr;
        address_len := addresses[0].ai_addrlen;
        address_v4 := cast(*Socket.sockaddr_in) address;
        address_v4.sin_port = Posix.htons(xx port);


        // https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/socket.2.html
        // socket(int domain, int type, int protocol);
        // socket :: (unknown0: s32, unknown1: SOCK, unknown2: IPPROTO) -> s32 #foreign libc;
        s := Socket.socket(Socket.AF_INET, .DGRAM, 0);
        if s < 0 {
                error := Socket.get_last_socket_error();
                Basic.print("error=%\n", error);
                Basic.assert(false);
        }

        // sendto :: (unknown0: s32, unknown1: *void, unknown2: u64, unknown3: MSG, unknown4: *sockaddr, unknown5: socklen_t) -> ssize_t #foreign libc;
        // sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
        r := Socket.sendto(s, xx encoded.data, xx encoded.count, 0, address, xx address_len);
        if r < 0 {
                Basic.print("error=%, error_string=%\n", Socket.get_last_socket_error(),System.get_error_string(xx r));
                Basic.assert(false);
        }

        // ssize_t recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len)
        // recvfrom :: (unknown0: s32, unknown1: *void, unknown2: u64, unknown3: MSG, unknown4: *sockaddr, unknown5: *socklen_t) -> ssize_t #foreign libc;
        client: Socket.sockaddr_in;
        client_size := size_of(type_of(client));
        buf: [SIZE]u8;
        r = Socket.recvfrom(s, xx buf.data, xx buf.count, 0, xx *client, xx *client_size);
        if r < 0 {
                Basic.print("error=%, error_string=%\n", Socket.get_last_socket_error(), System.get_error_string(xx r));
                Basic.assert(false);
        }

        rc :=  buf[3] & 0xf;
        if rc == {
        case 0; Basic.print("Domain exists\n");
        case 1; Basic.print("Format error\n");
        case 3; Basic.print("Non-existent domain\n");
        case 9; Basic.print("Server not authorative for zone\n");
        case 10; Basic.print("Name not in zone\n");
        case; Basic.print("Unmapped response for %\n", rc);
        }

}

encode :: (q: DNS_Query) -> []u8 {
        e: [SIZE]u8;
        b := Binary_Encoder.{data=e.data};
        encode_u16(*b, q.id);
        encode_u8(*b, cast(u8) ((cast(int) q.qr) << 7 | (cast(int) q.opcode) << 3 | (cast(int) q.aa) << 1 | (cast(int) q.rd)));
        encode_u8(*b, cast(u8) ((cast(int)q.ra) << 7 | (cast(int)q.z) << 4));
        encode_u16(*b, ifx q.qd_count then q.qd_count else cast(u16) q.questions.count);
        encode_u16(*b, q.an_count);
        encode_u16(*b, q.ns_count);
        encode_u16(*b, q.ar_count);

        for q: q.questions {
                for d: String.split(q.domain, ".") {
                        if !d continue;
                        encode_u8(*b, xx d.count);
                        encode_string(*b, d);
                }
                encode_u8(*b, 0);
                encode_u16(*b, q.type);
                encode_u16(*b, q.class);
        }

        _e: []u8;
        _e.data = e.data;
        _e.count = b.index;
        return Basic.array_copy(_e);
}

/*
        Example header:

        AA AA - ID
        01 00 - Query parameters (QR | Opcode | AA | TC | RD | RA | Z | ResponseCode)
        00 01 - Number of questions
        00 00 - Number of answers
        00 00 - Number of authority records
        00 00 - Number of additional records
*/

DNS_Query :: struct {
        id:     u16; // An arbitary 16 bit request identifier (same id is used in the response)
        qr:     bool;   // A 1 bit flat specifying whether this message is a query (0) or a response (1)
        opcode: u8;  // A 4 bit fields that specifies the query type; 0 (standard), 1 (inverse), 2 (status), 4 (notify), 5 (update)

        aa:           bool;  // Authoriative answer
        tc:          bool;  // 1 bit flag specifying if the message has been truncated
        rd:           bool;  // 1 bit flag to specify if recursion is desired (if the DNS server we secnd out request to doesn't know the answer to our query, it can recursively ask other DNS servers)
        ra:           bool;  // Recursive available
        z:           u8; // Reserved for future use
        response_code: u8;

        qd_count: u16; // Number of entries in the question section
        an_count: u16; // Number of answers
        ns_count: u16; // Number of authorities
        ar_count: u16; // Number of additional records

        questions: [..]DNS_Question;
}

/*
        Example Question:

        07 65 - 'example' has length 7, e
        78 61 - x, a
        6D 70 - m, p
        6C 65 - l, e
        03 63 - 'com' has length 3, c
        6F 6D - o, m
        00    - zero byte to end the QNAME
        00 01 - QTYPE
        00 01 - QCLASS

        76578616d706c6503636f6d0000010001
*/

DNS_Question :: struct {
        domain: string;
        type:   u16; // DNS Record type we are looking up; 1 (A record)
        class:  u16; // 1 (internet)
}


// NOTE: Big endian encoding
Binary_Encoder :: struct {
        data: *u8;
        index: int;
}

set_next :: (e: *Binary_Encoder, data: u8) {
        << (e.data + e.index) = data;
        e.index += 1;
}

encode_u8 :: (e: *Binary_Encoder, data: u8) {
        set_next(e, data);
}

encode_u16 :: (e: *Binary_Encoder, data: u16) {
        set_next(e, xx data >> 8);
        set_next(e, xx data & 0xff);
}

encode_string :: (e: *Binary_Encoder, data: string) {
        d: []u8;
        d.data = data.data;
        d.count = data.count;

        for d encode_u8(e, it);
}

