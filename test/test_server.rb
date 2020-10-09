# frozen_string_literal: true

require 'minitest_helper'

class TestServer < HttpServerTest
  def setup
    make_tcp_socket_connection
  end

  def teardown
    @socket.close
  end

  def make_request(request)
    @response = nil
    response = Thread.new do
      @socket.puts request
      @response = @socket.gets
    end
    response.join
    @response
  end

  def test_server_responds_to_http_11_call
    response = make_request "GET / HTTP/1.1\n\n"
    assert response == "HTTP/1.1 200 OK\n"
  end

  def test_server_rejects_bad_http_11_call
    response = make_request "GET / a HTTP/1.1\n\n"
    assert response == "HTTP/1.1 400 BadRequest\n"
  end
end
