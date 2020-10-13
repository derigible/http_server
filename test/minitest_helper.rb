# frozen_string_literal: true

require 'bundler/setup'
require_relative '../app/server'

Bundler.require(:default)

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/hooks/test'

class HttpServerTest < Minitest::Test
  include Minitest::Hooks
  PORT = 2001
  # include only one server to be run for all tests
  @@SERVER = Server.new PORT, verbose: false

  def before_all
    @@SERVER.run_server
  end

  def make_tcp_socket_connection
    @socket = TCPSocket.new 'localhost', PORT
  end

  def assert_not(assertion)
    assert !assertion
  end
end
