require_relative '../lib/web_parser'
require_relative '../lib/parsers/news_parser'
require_relative '../lib/pagination_handler'

# Пример использования для конкретного новостного сайта
url = 'https://example.com/news'
parser = WebParser::NewsParser.new(url)

# Парсинг с пагинацией
pagination = WebParser::PaginationHandler.new(url, max_pages: 5)
all_articles = []

pagination.each_page do |page_url|
  parser = WebParser::NewsParser.new(page_url)
  articles = parser.parse
  all_articles.concat(articles)
end

# Сохранение результатов
parser.save_to_csv('news_articles.csv', all_articles)
parser.save_to_json('news_articles.json', all_articles) 