class FileRequested
  HTML_RESPONSE = 'text/html; charset=UTF-8'.freeze
  OTHER_RESPONSE = 'application/octet-stream'.freeze

  def initialize(path)
    @path = path
  end

  def accept_request?
    File.exist?(normalized_path)
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
    "attachment; filename=\"#{file_name}\"" unless normalized_path.end_with?('.html')
  end

  private

  def file_name
    @normalized_path.split('/').last
  end

  def normalized_path
    @normalized_path ||= @path == '/' ? 'files/index.html' : "files/#{@path.delete_prefix('/')}"
  end
end
