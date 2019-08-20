#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

# функция инициализации БД
def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
	@db.results_as_hash = true
#	return @db #и без этого работает вроде как надо
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
	# выбираем список постов из БД
	@posts = @db.execute 'select * from Posts ORDER BY id DESC'
	erb :index			
end

get '/posts' do
	erb :posts
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
	@content = params[:content]

	# проверка введенных параметров
	if @content.length <= 0
		@error = 'Error. You need type text'
		return erb :new
	end		
	
	# Отдельно db инициализоровать не нужно, т.к. это сейчас выполняет метод before
	# Сохранение данных в БД
	@db.execute 'INSERT INTO Posts (content, created_date) VALUES (?, datetime())', [@content]

	# Перенаправление на главную страницу
	redirect to '/'
	#erb "<i>You typed:</i> #{@content}"
end