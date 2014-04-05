###Develop.re

Социальный агрегатор ссылок для программистов и гиков. Форк приложения https://github.com/jcs/lobsters/

####Установка

* Установите Ruby (поддерживаемые версии – 1.9.3, 2.0.0 and 2.1.0).

* Получите код

         $ git clone git@github.com:freetonik/develop.re.git
         $ cd develop.re
         develop.re$ 

* Запустите Bundler:

         develop.re$ bundle

* Создайте базу MySQL (другие базы с поддержкой ActiveRecord скорее всего будут работать, проверялись только MySQL и MariaDB), укажите данные доступа в`config/database.yml`:

          development:
            adapter: mysql2
            encoding: utf8mb4
            reconnect: false
            database: lobsters_dev
            socket: /tmp/mysql.sock
            username: *username*
            password: *password*
            
          test:
            adapter: sqlite3
            database: db/test.sqlite3
            pool: 5
            timeout: 5000

* Загрузите схему:

          develop.re$ rake db:schema:load

* Создайте файл `config/initializers/secret_token.rb` используя случайный вывод `rake secret`:

          Lobsters::Application.config.secret_token = 'your random secret here'

* (Опционально, если нужен поиск) Установите Sphinx. Соберите конфиг и запустите сервер:

          develop.re$ rake ts:rebuild

* Укажите домен в `config/initializers/production.rb` или другом файле окружения:

          class << Rails.application
            def domain
              "example.com"
            end
          
            def name
              "Example News"
            end
          end
          
          Rails.application.routes.default_url_options[:host] = Rails.application.domain

* Создайте учетную запись администратора и хотя бы один тег:

          develop.re$ rails console
          Loading development environment (Rails 3.2.6)
          irb(main):001:0> u = User.new(:username => "test", :email => "test@example.com", :password => "test", :password_confirmation => "test")
          irb(main):002:0> u.is_admin = true
          irb(main):003:0> u.is_moderator = true
          irb(main):004:0> u.save

          irb(main):005:0> t = Tag.new
          irb(main):006:0> t.tag = "test"
          irb(main):007:0> t.save

* Запустите сервер. Он будет доступен по адресу `http://localhost:3000` с пользователем `test`:

          lobsters$ rails server
