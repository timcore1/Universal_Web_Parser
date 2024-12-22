require_relative '../lib/parsers/news_parser'
require 'capybara'
require 'selenium-webdriver'
require 'webdrivers/chromedriver'

class TimcoreParser
  def initialize
    @parser = NewsParser.new
    setup_capybara
  end

  def parse
    data = []
    url = "https://timcore.ru/"
    
    puts "Обработка страницы: #{url}"
    if @parser.allowed_to_parse?(url)
      page_data = parse_page(url)
      data.concat(page_data) if page_data.any?
      puts "Найдено статей: #{page_data.size}"
      
      if data.any?
        @parser.save_to_csv(data, 'timcore_articles.csv')
        @parser.save_to_json(data, 'timcore_articles.json')
        puts "Данные сохранены в файлы timcore_articles.csv и timcore_articles.json"
      else
        puts "Не удалось получить данные"
      end
    else
      puts "Парсинг сайта запрещен в robots.txt"
    end
  end

  private

  def setup_capybara
    Capybara.register_driver :selenium_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless=new')
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--window-size=1920,1080')
      options.add_argument('--disable-extensions')
      options.add_argument('--user-agent="TimcoreBot/1.0 (educational_purposes)"')
      
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
      
      # Ждем загрузки контента
      sleep rand(3..5)

      # Собираем все статьи на странице
      articles = session.all('.post')  # Обновленный селектор для статей
      
      articles.map do |article|
        {
          title: article.find('h2 a')&.text&.strip,
          date: article.find('.post-meta time')&.text&.strip,
          description: article.find('.post-excerpt')&.text&.strip,
          url: article.find('h2 a')[:href],
          author: article.find('.post-meta .author')&.text&.strip
        }
      rescue => e
        puts "Ошибка при парсинге статьи: #{e.message}"
        puts "HTML статьи: #{article.native.inner_html}" # Добавим для отладки
        nil
      end.compact
    rescue => e
      retries += 1
      if retries < 3
        sleep 10 * retries
        retry
      else
        puts "Не удалось загрузить страницу #{url}: #{e.message}"
        # Добавим вывод HTML страницы для отладки
        puts "HTML страницы: #{session.html}"
        return []
      end
    end
  end
end

parser = TimcoreParser.new
parser.parse 