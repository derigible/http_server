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
    unless @body.nil?
      out << "Content-Length: #{body_size}"
      out << 'Accept-Ranges: bytes'
    end
    out.join("\n")
  end

  def message_body
    @body.nil? ? '' : "\n\n#{@body}"
  end

  def body_size
    @body.size
  end
end

class RequestError < StandardError
end

class BadRequestError < RequestError
  MESSAGE = "HTTP/1.1 400 Bad Request\r\nStatus: 400 Bad Request\r\n".freeze
  def message
    MESSAGE
  end
end

class MethodNotAllowedError < RequestError
  MESSAGE = "HTTP/1.1 405 Method Not Allowed\r\nStatus: 405 Method Not Allowed\r\n".freeze
  def message
    MESSAGE
  end
end

class FourOhFourNotFoundError < RequestError
  MESSAGE = "HTTP/1.1 404 Not Found\r\nStatus: 404 Not Found\r\n".freeze
  def message
    MESSAGE
  end
end
