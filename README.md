# Universal_Web_Parser
<p align="center">
 <img src="Universal_Web_Parser.png" alt="Universal_Web_Parser" width="800"/>
</p>
<p align="center">
 <a href="https://opensource.org/licenses/MIT">
   <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
 </a>

# Web Parser
Универсальный парсер веб-сайтов на Ruby с поддержкой JavaScript-рендеринга и обработкой пагинации.
## Возможности
Парсинг статических и динамических (JavaScript) веб-страниц

- Поддержка пагинации

- Сохранение результатов в CSV и JSON форматы
 
- Соблюдение robots.txt
 
- Обработка ошибок и повторные попытки
 
- Кэширование результатов
 
- Настраиваемые задержки между запросами
 
## Требования

- Ruby 3.0+
- Google Chrome (для JavaScript-рендеринга)
- Bundler
  
## Установка

1. Клонируйте репозиторий:

`git clone https://github.com/your-username/web_parser.git`

`cd web_parser`

2. Установите зависимости:

`bundle install`


## Использование

### Парсинг статей с Habr.com

`ruby examples/parse_habr.rb`


## Настройка парсера

Для создания нового парсера:

1. Создайте новый файл в директории `examples/`
2. Наследуйте базовый класс или используйте готовые парсеры как пример
3. Настройте селекторы под нужный сайт

Пример:

ruby

require_relative '../lib/parsers/news_parser'

class CustomParser

def initialize

@parser = NewsParser.new

setup_capybara

end
end


## Этичный парсинг

- Проверяйте robots.txt
- Используйте задержки между запросами
- Указывайте User-Agent
- Не перегружайте сервер
- Кэшируйте результаты

## Зависимости

- nokogiri
- httparty
- capybara
- selenium-webdriver
- webdrivers
- json

## Лицензия

MIT License. См. файл [LICENSE](LICENSE) для деталей.

## Автор

Mikhail Tarasov (Timcore)





