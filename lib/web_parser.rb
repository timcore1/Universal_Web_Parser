require 'nokogiri'
require 'httparty'
require 'logger'
require 'csv'
require 'json'

module WebParser
  class Base
    attr_reader :url, :logger

    def initialize(url, options = {})
      @url = url
      @logger = setup_logger(options[:log_file] || 'parser.log')
      @headers = options[:headers] || default_headers
    end

    private

    def fetch_page
      response = HTTParty.get(@url, headers: @headers)
      if response.success?
        Nokogiri::HTML(response.body)
      else
        logger.error("Ошибка при загрузке страницы: #{response.code}")
        nil
      end
    rescue StandardError => e
      logger.error("Произошла ошибка: #{e.message}")
      nil
    end

    def setup_logger(log_file)
      logger = Logger.new(log_file)
      logger.level = Logger::INFO
      logger
    end

    def default_headers
      {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      }
    end
  end
end 