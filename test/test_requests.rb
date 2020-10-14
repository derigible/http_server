require 'minitest_helper'
require 'net/http'

class TestRequests < HttpServerTest
  def test_body_read_correctly
    uri = URI("http://localhost:#{PORT}/")
    resp = Net::HTTP.get_response(uri)
    assert resp.is_a?(Net::HTTPSuccess)
    assert resp.body .start_with? '<html>'
  end

  def test_not_found
    uri = URI("http://localhost:#{PORT}/a")
    resp = Net::HTTP.get_response(uri)
    assert resp.is_a?(Net::HTTPNotFound)
  end

  def test_nethod_not_supported
    uri = URI("http://localhost:#{PORT}/")
    req = Net::HTTP::Post.new(uri)
    req.set_form_data('from' => '2005-01-01', 'to' => '2005-03-31')
    resp = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    assert resp.is_a?(Net::HTTPMethodNotAllowed)
  end
end
