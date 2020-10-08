require 'socket'
require 'byebug'

class BadRequestError < StandardError; end

class Server
  def initialize(port = 2000)
    @server = TCPServer.new port
  end

  def handle_request(client)
    parse_request(client)
    good_request_response(client)
  rescue BadRequestError
    bad_request_response(client)
  ensure
    client.close
  end

  def parse_request(client)
    raise BadRequestError unless accept_request? client.gets
  end

  def accept_request?(request_head)
    request_head.split(' ').size == 3
  end

  def good_request_response(client)
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
  end

  def bad_request_response(client)
    client.puts 'HTTP/1.1 400 BadRequest'
  end

  def run_server
    @server_thread = Thread.new do
      loop do
        Thread.start(@server.accept) do |client|
          handle_request(client)
        end
      end
    end
  end

  def run_server_blocking
    run_server
    @server_thread.join
  end

  def stop_server
    @server.close
  end
end
