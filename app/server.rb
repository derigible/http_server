require 'socket'
require 'byebug'

require_relative 'file_requested'

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

class FourOhFourNotFoundError < RequestError
  MESSAGE = 'HTTP/1.1 404 Not Found'.freeze
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
    out = @headers.keys.each_with_object([]) do |header, memo|
      memo << "#{header}: #{@headers[header]}"
    end
    if @body.nil?
      out.join("\n")
    else
      out << "Content-Length: #{body_size}"
      out << 'Accept-Ranges: bytes'
    end
  end

  def message_body
    @body.nil? ? '' : "\n\n#{@body}"
  end

  def body_size
    @body.size
  end
end

class Server
  def initialize(port = 2000, verbose: true)
    @server = TCPServer.new port
    @verbose = verbose
  end

  def handle_request(client)
    file_requested = parse_request(client)
    good_request_response(
      client,
      file_requested.read,
      file_requested.content_type,
      file_requested.content_disposition
    )
  rescue RequestError => e
    bad_request_response(client, e.message)
  ensure
    client.close
  end

  def good_request_response(client, body, content_type = nil, content_disposition = nil)
    headers = {
      'Server' => 'Mphillips/0.0.0.0 (Unix) (Ubuntu/Linux)',
      'Connection' => 'close',
      'Content-Type' => content_type
    }
    headers['Content-Disposition'] = content_disposition if content_disposition
    resp = Response.new headers: headers, body: body
    client.puts resp.message
  end

  def run_server
    @server_thread ||= Thread.new do
      loop do
        Thread.start(@server.accept) do |client|
          puts 'Request received' if @verbose
          handle_request(client)
          puts 'Request delivered' if @verbose
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

    file_requested = FileRequested.new http_head_parts[1]
    raise FourOhFourNotFoundError unless file_requested.accept_request?

    file_requested
  end

  def invalid_http_request?(request_head)
    request_head.size != 3
  end

  def invalid_http_method?(request_head)
    request_head.first != 'GET'
  end
end
