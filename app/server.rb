require 'socket'
require 'byebug'

require_relative 'file_requested'
require_relative 'response'

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
    start_line = client.gets
    http_head_parts = start_line.split(' ')
    raise BadRequestError if request_invalid? http_head_parts, client, start_line
    raise MethodNotAllowedError if invalid_http_method? http_head_parts

    file_requested = FileRequested.new http_head_parts[1]
    raise FourOhFourNotFoundError unless file_requested.accept_request?

    file_requested
  end

  def request_invalid?(http_head_parts, client, start_line)
    invalid_http_request?(http_head_parts, start_line) ||
      invalid_http_headers?(client) ||
      invalid_http_version?(http_head_parts)
  end

  def invalid_http_version?(request_head)
    request_head.last != 'HTTP/1.1'
  end

  def invalid_http_request?(request_head, start_line)
    request_head.size != 3 || start_line =~ /[ ]{2,}/
  end

  def invalid_http_method?(request_head)
    request_head.first != 'GET'
  end

  def invalid_http_headers?(client)
    lines = []
    while (line = client.readline) && line != "\r\n"
      lines << line
    end
    lines.any? { |l| invalid_header? l }
  end

  def invalid_header?(header)
    parts = header.split(':')
    return true if parts.first =~ /\s/

    false
  end
end
