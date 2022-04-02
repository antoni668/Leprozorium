#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db

	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		Id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
		)'

		@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		Id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id INTEGER
		)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by Id desc'
	erb :index
end

get '/newpost' do
	erb :newpost
 end

 post '/newpost' do
	content = params[:content]

	if content.length <= 0
		@error = 'Type text'
		return erb :newpost
	end

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', content

	redirect to '/'
 end

 get '/details/:post_id' do
	post_id = params[:post_id]

	@results = @db.execute 'select * from Posts where Id = ?', [post_id]
	@row = @results[0]

	erb :details
 end

 post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	@db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]

	redirect to('/details/' + post_id)
 end