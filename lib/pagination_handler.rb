module WebParser
  class PaginationHandler
    def initialize(base_url, options = {})
      @base_url = base_url
      @page_param = options[:page_param] || 'page'
      @max_pages = options[:max_pages]
    end

    def each_page
      page = 1
      loop do
        current_url = build_url(page)
        yield(current_url)
        
        break if @max_pages && page >= @max_pages
        sleep(2)
        page += 1
      end
    end

    private

    def build_url(page)
      uri = URI(@base_url)
      params = URI.decode_www_form(uri.query || '') << [@page_param, page.to_s]
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end
  end
end 