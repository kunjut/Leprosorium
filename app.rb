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
	
	# создает таблицу если она не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments (
		id           INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content      TEXT,
		post_id		 INTEGER
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
	content = params[:content]

	# проверка введенных параметров
	if content.length <= 0
		@error = 'Error. You need type text'
		return erb :new
	end		
	
	# Отдельно db инициализоровать не нужно, т.к. это сейчас выполняет метод before
	# Сохранение данных в БД
	@db.execute 'INSERT INTO Posts (content, created_date) VALUES (?, datetime())', [content]

	# Перенаправление на главную страницу
	redirect to '/'
	#erb "<i>You typed:</i> #{content}"
end

# вывод информации о посте, универсальным обрабочиком
get '/details/:post_id' do # синатра берет id не из БД
	
	# получаем динамическую переменную из url'a
	post_id = params[:post_id]
	
	# получяаем список постов (будет только один пост)
	posts = @db.execute 'select * from Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = posts[0] 

	# выбираем коментарии из БД для поста
	@comments = @db.execute 'SELECT * FROM Comments where post_id = ? ORDER BY id', [post_id]
	
	#возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса 
# браузер отправляет данные на сервер
# а мы их принимаем
post '/details/:post_id' do # синатра берет id не из БД

	# получаем динамическую переменную из url'a
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	posts = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = posts[0]
	@comments = @db.execute 'SELECT * FROM Comments where post_id = ? ORDER BY id', [post_id] 
	
	# валидация на пустой ввод
	if content.length <= 0
		@error = 'Try type text'
		return erb :details
	end

	# Сохранение данных в БД
	@db.execute 'INSERT INTO Comments 
	(
		content, 
		created_date, 
		post_id
	) 
		VALUES 
	(
		?, 
		datetime(), 
		?
	)', [content, post_id]

	# Перенаправление на страницу поста
	redirect to ('/details/' + post_id)

	#	erb "you typed comment #{content} for post #{post_id}"

end