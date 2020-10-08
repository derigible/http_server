require 'socket'
require 'byebug'

server = TCPServer.new 2000
loop do
  Thread.start(server.accept) do |client|
    client.puts <<~RESPONSE
      HTTP/1.1 200 OK
      Date: Mon, 23 May 2005 22:38:34 GMT
      Content-Type: text/html; charset=UTF-8
      Content-Length: 155
      Last-Modified: Wed, 08 Jan 2003 23:11:55 GMT
      Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
      ETag: "3f80f-1b6-3e1cb03b"
      Accept-Ranges: bytes
      Connection: close

            <html>
        <head>
          <title>An Example Page</title>
        </head>
        <body>
          <p>Hello World, this is a very simple HTML document.</p>
        </body>
      </html>
    RESPONSE
    client.close
  end
end
