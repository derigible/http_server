require 'socket'
require 'byebug'

class RequestError < StandardError
end

class BadRequestError < RequestError
  MESSAGE = 'HTTP/1.1 400 Bad Request'.freeze
  def message
    MESSAGE
  end
end

class MethodNotAllowedError < RequestError
  MESSAGE = 'HTTP/1.1 405 Method Not Allowed'.freeze
  def message
    MESSAGE
  end
end

class Response
  START_LINE = 'HTTP/1.1 200 OK'.freeze

  def initialize(headers: {}, body: nil)
    @headers = headers
    @body = body
  end

  def message
    "#{START_LINE}\n#{message_headers}#{message_body}"
  end

  private

  def message_headers
    @headers.keys.each_with_object([]) do |header, memo|
      memo << "#{header}: #{@headers[header]}"
    end.join("\n")
  end

  def message_body
    @body.nil? ? '' : "\n#{@body}"
  end
end

class Server
  def initialize(port = 2000)
    @server = TCPServer.new port
  end

  def handle_request(client)
    parse_request(client)
    good_request_response(client)
  rescue RequestError => e
    bad_request_response(client, e.message)
  ensure
    client.close
  end

  def good_request_response(client)
    headers = {
      'Server' => 'Mphillips/0.0.0.0 (Unix) (Ubuntu/Linux)',
      'Connection' => 'close',
      'Content-Type' => 'text/html; charset=UTF-8',
      'Content-Length' => 155,
      'Accept-Ranges' => 'bytes'

    }
    body = <<~BODY
      <html>
        <head>
          <title>An Example Page</title>
        </head>
        <body>
          <p>Hello World, this is a very simple HTML document.</p>
        </body>
      </html>
    BODY
    resp = Response.new headers: headers, body: body
    client.puts resp.message
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

  private

  def bad_request_response(client, message)
    client.puts message
  end

  def parse_request(client)
    http_head_parts = client.gets.split(' ')
    raise BadRequestError if invalid_http_request? http_head_parts
    raise MethodNotAllowedError if invalid_http_method? http_head_parts
  end

  def invalid_http_request?(request_head)
    request_head.size != 3
  end

  def invalid_http_method?(request_head)
    request_head.first != 'GET'
  end
end
