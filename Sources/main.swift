import TCP
import Venice

co {
    do {
        // create an echo server on localhost:8080
        let server = try TCPHost(host: "127.0.0.1", port: 8080)
            while true {
                // waits for an incoming connection, receives 1024 bytes, sends them back
                let connection = try server.accept(deadline: .never)
                print((connection as! TCPStream).ip.description)
                let data = try connection.read(upTo: 1024, deadline: .never)
                print(data)
                try connection.write(data, deadline: .never)
                try connection.flush(deadline: .never)
            }
    } catch {
        print(error)
    }
}

nap(for: 1000.milliseconds)

    // create a connection to server at localhost:8080
    let x = try TCPStream(host: "0.0.0.0", port: 8080, deadline: .never)
    // opens the connection, sends "hello"
    try x.open(deadline: .never)
    try x.write("hello", deadline: .never)
    try x.flush(deadline: .never)
    // waits for a message, prints it out
    let data =  try x.read(upTo: 1024, deadline: .never)
    print(data)
