require_relative '../lib/parsers/news_parser'
require 'capybara'
require 'selenium-webdriver'
require 'webdrivers/chromedriver'

class HabrParser
  def initialize
    @parser = NewsParser.new
    setup_capybara
  end

  def parse
    data = []
    max_concurrent_requests = 1  # Ограничиваем количество параллельных запросов
    
    (1..2).each do |page|
      url = "https://habr.com/ru/all/page#{page}/"
      puts "Обработка страницы: #{url}"
      
      page_data = parse_page(url)
      data.concat(page_data) if page_data.any?
      
      puts "Найдено статей на странице: #{page_data.size}"
    end
    
    if data.any?
      @parser.save_to_csv(data, 'habr_articles.csv')
      puts "Данные сохранены в файл habr_articles.csv"
    else
      puts "Не удалось получить данные"
    end
  end

  private

  def setup_capybara
    Capybara.register_driver :selenium_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless=new')  # Обновленный синтаксис для headless режима
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--remote-debugging-port=9222')
      
      # Добавляем дополнительные настройки для стабильности
      options.add_argument('--window-size=1920,1080')
      options.add_argument('--disable-extensions')
      options.add_argument('--user-agent="MyBot/1.0 (contact@example.com)"')
      
      Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        options: options,
        clear_local_storage: true,
        clear_session_storage: true
      )
    end
    
    Capybara.default_driver = :selenium_chrome
    Capybara.javascript_driver = :selenium_chrome
    Capybara.default_max_wait_time = 10
  end

  def parse_page(url)
    retries = 0
    begin
      session = Capybara.current_session
      session.visit(url)
    rescue => e
      retries += 1
      if retries < 3
        sleep 10 * retries  # Увеличиваем время ожидания при повторных попытках
        retry
      else
        puts "Не удалось загрузить страницу #{url}: #{e.message}"
        return []
      end
    end
    
    # Увеличиваем время ожидания
    sleep 5

    articles = session.all('.tm-articles-list__item')
    
    articles.map do |article|
      {
        title: article.find('.tm-article-snippet__title-link')&.text&.strip,
        url: article.find('.tm-article-snippet__title-link')[:href],
        author: article.find('.tm-user-info__username')&.text&.strip,
        published_at: article.find('.tm-article-snippet__datetime-published')&.text&.strip
      }
    rescue => e
      puts "Ошибка при парсинге статьи: #{e.message}"
      nil
    end.compact
  end
end

parser = HabrParser.new
parser.parse 