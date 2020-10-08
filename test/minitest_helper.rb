# frozen_string_literal: true

require 'bundler/setup'
require_relative '../app/server'

Bundler.require(:default)

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/hooks/test'

class HttpServerTest < Minitest::Test
  include Minitest::Hooks

  def before_all
    @server = Server.new
    @server.run_server
  end

  def make_tcp_socket_connection
    @socket = TCPSocket.new 'localhost', 2000
  end
end
