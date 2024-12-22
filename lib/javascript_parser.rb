require 'capybara'
require 'capybara/dsl'

module WebParser
  class JavascriptParser < Base
    include Capybara::DSL

    def initialize(url, options = {})
      super
      setup_capybara
    end

    private

    def setup_capybara
      Capybara.default_driver = :selenium_chrome_headless
      Capybara.app_host = @url
    end

    def fetch_page
      page.visit(@url)
      Nokogiri::HTML(page.html)
    rescue StandardError => e
      logger.error("Ошибка при загрузке страницы с JavaScript: #{e.message}")
      nil
    end
  end
end 