class FileRequested
  HTML_RESPONSE = 'text/html; charset=UTF-8'.freeze
  OTHER_RESPONSE = 'application/octet-stream'.freeze
  CONTENT_DISPOSITION = 'Content-Disposition: inline; filename="picture.png"'.freeze

  def initialize(path)
    @path = path
  end

  def accept_request?
    @path == '/' || @path.start_with?('/files') && File.exist?(@path.delete_prefix('/'))
  end

  def read
    File.open(normalized_path).read
  end

  def content_type
    if normalized_path.end_with?('.html')
      HTML_RESPONSE
    else
      OTHER_RESPONSE
    end
  end

  def content_disposition
    CONTENT_DISPOSITION unless normalized_path.end_with?('.html')
  end

  private

  def normalized_path
    @normalized_path ||= @path == '/' ? 'files/test.html' : @path.delete_prefix('/')
  end
end
