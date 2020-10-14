# frozen_string_literal: true

require 'minitest_helper'

class TestResponse < HttpServerTest
  def test_response_start_line_correct
    response = Response.new.message
    assert response.split("\n").first == 'HTTP/1.1 200 OK'
  end

  def test_response_correct_with_body
    response = Response.new.message
    assert response.split("\n").first == 'HTTP/1.1 200 OK'
  end
end
