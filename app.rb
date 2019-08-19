#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'\

# функция инициализации БД
def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
	@db.results_as_hash = true
end

# before вызывается каждый раз, кроме configure
before do
	# инициализация БД
	init_db 
end

# configure вызывается каждый раз, при конфигурации приложения:
# когда изменился код программы и перезагрузилась страница  
configure do
	# инициализация БД
	init_db
	# создает таблицу если она не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
		id           INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content      TEXT
	)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/main' do
	erb :main
end

# обработчик get-запроса для /new
# (браузер получает страницу с сервера)
get '/new' do
	erb :new
end

# обработчик post-запроса для /new
# (браузер отправляет данные на сервер)
post '/new' do
	# получаем переменную из post-запроса
	@textarea = params[:textarea]
	erb "<i>You typed:</i> #{@textarea}"
end