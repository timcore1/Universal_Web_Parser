require 'csv'
require 'json'
require 'uri'
require 'fileutils'
require 'net/http'

class NewsParser
  def initialize
    @data = []
    @user_agent = 'MyBot/1.0'
  end

  def allowed_to_parse?(url)
    uri = URI.parse(url)
    robots_url = "#{uri.scheme}://#{uri.host}/robots.txt"
    path = uri.path.empty? ? '/' : uri.path
    
    begin
      robots_content = Net::HTTP.get(URI(robots_url))
      
      # Простая проверка на запрещающие правила
      disallow_rules = robots_content.scan(/Disallow: (.+)/).flatten
      
      # Проверяем, не попадает ли путь под запрещающие правила
      disallow_rules.none? do |rule|
        rule = rule.strip
        path.start_with?(rule) || path == rule
      end
    rescue => e
      puts "Ошибка при проверке robots.txt: #{e.message}"
      true # В случае ошибки разрешаем парсинг (можно изменить на false для большей безопасности)
    end
  end

  def save_to_csv(data, filename)
    return puts "Нет данных для сохранения" if data.nil? || data.empty?
    
    CSV.open(filename, "w", encoding: "UTF-8") do |csv|
      csv << data.first.keys
      data.each do |row|
        csv << row.values
      end
    end
  end

  def save_to_json(data, filename)
    return puts "Нет данных для сохранения" if data.nil? || data.empty?
    
    File.write(filename, JSON.pretty_generate(data))
    puts "Данные сохранены в JSON: #{filename}"
  end

  def cache_response(url, content)
    FileUtils.mkdir_p('cache')
    File.write("cache/#{url.gsub(/[^\w]/, '_')}", content)
  end
end 