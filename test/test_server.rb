# frozen_string_literal: true

require 'minitest_helper'

class TestServer < HttpServerTest
  def make_request(request)
    socket = make_tcp_socket_connection
    response = nil
    r = Thread.new do
      socket.puts request
      response = socket.gets
    end
    r.join
    socket.close
    response
  end

  def test_server_responds_to_http_11_call
    response = make_request "GET / HTTP/1.1\n\n"
    assert response == "HTTP/1.1 200 OK\n"
  end

  def test_server_rejects_bad_http_11_call
    response = make_request "GET / a HTTP/1.1\n\n"
    assert response == "#{BadRequestError::MESSAGE}\n"
  end

  def test_server_rejects_non_get_calls
    %w[PUT POST HEAD DELETE CONNECT OPTIONS TRACE OTHER].each do |type|
      response = make_request "#{type} / HTTP/1.1\n\n"
      assert response == "#{MethodNotAllowedError::MESSAGE}\n"
    end
  end
end
