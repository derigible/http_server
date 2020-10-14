require 'minitest_helper'

class TestFileRequested < HttpServerTest
  def test_file_accepted
    fr = FileRequested.new('/test.html')
    assert fr.accept_request?
  end

  def test_file_accepted_rejected_if_not_in_files_dir
    fr = FileRequested.new('/../../test.html')
    assert_not fr.accept_request?
    fr = FileRequested.new('/fles/../../test.html')
    assert_not fr.accept_request?
    fr = FileRequested.new('/etc/psswd/fles/../../test.html')
    assert_not fr.accept_request?
  end

  def test_content_type_html
    fr = FileRequested.new('/test.html')
    assert fr.content_type == FileRequested::HTML_RESPONSE
  end

  def test_content_type_other
    fr = FileRequested.new('/test.xhtml')
    assert fr.content_type == FileRequested::OTHER_RESPONSE
  end

  def test_content_disposition_nil_if_html
    fr = FileRequested.new('/test.html')
    assert_nil fr.content_disposition
  end

  def test_content_disposition_present_if_not_html
    fr = FileRequested.new('/test.xhtml')
    assert fr.content_disposition == 'attachment; filename="test.xhtml"'
  end
end
