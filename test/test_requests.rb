require 'minitest_helper'
require 'net/http'

class TestRequests < HttpServerTest
  def test_body_read_correctly
    uri = URI('http://localhost:2000')
    resp = Net::HTTP.get_response(uri)
    assert resp.is_a?(Net::HTTPSuccess)
  end
end
