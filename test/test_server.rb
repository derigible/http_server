# frozen_string_literal: true

require 'minitest_helper'

class TestServer < HttpServerTest
  def make_request(request)
    socket = make_tcp_socket_connection
    response = nil
    r = Thread.new do
      socket.puts request
      rs = []
      while line = socket.gets
        rs << line
      end
      response = rs.join
    end
    r.join
    socket.close
    response
  end

  def test_server_responds_to_http_11_call
    response = make_request "GET / HTTP/1.1\r\n\r\n"
    assert response.split("\n").first == 'HTTP/1.1 200 OK'
  end

  def test_server_rejects_bad_http_11_call
    response = make_request "GET / a HTTP/1.1\r\n\r\n"
    assert response == "#{BadRequestError::MESSAGE}\n"
  end

  def test_server_rejects_non_http11_version
    response = make_request "GET / a HTTP/1.0\r\n\r\n"
    assert response == "#{BadRequestError::MESSAGE}\n"
  end

  def test_server_rejects_too_much_whitespace_in_start_line
    response = make_request "GET /  HTTP/1.1\r\n\r\n"
    assert response == "#{BadRequestError::MESSAGE}\n"
  end

  def test_server_rejects_invalid_headers
    response = make_request "GET / HTTP/1.1\nHEADER1 : BAD\r\n\r\n"
    assert response == "#{BadRequestError::MESSAGE}\n"
  end

  def test_server_accepts_valid_headers
    response = make_request "GET / HTTP/1.1\nHEADER1: GOOD\r\n\r\n"
    assert response.split("\n").first == 'HTTP/1.1 200 OK'
  end

  def test_server_rejects_non_get_calls
    %w[PUT POST HEAD DELETE CONNECT OPTIONS TRACE OTHER].each do |type|
      response = make_request "#{type} / HTTP/1.1\r\n\r\n"
      assert response == "#{MethodNotAllowedError::MESSAGE}\n"
    end
  end
end
