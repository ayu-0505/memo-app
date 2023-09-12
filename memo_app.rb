# frozen_string_literal: true

require 'pg'
require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'cgi/escape'

# host = '{127.0.0.1}'
# port = '{5432}'
# db = '{memo_app_db}'
# user = '{user}'
# password = '{パスワード}'
# connection = PG::Connection.new(host: host, port: port, dbname: db, user: user, password: password)


class Memo
  attr_accessor :memo_id, :title, :content
  @@conn = PG::Connection.open(:dbname => 'memo_app_db')

  def initialize(memo_id, title, content)
    @memo_id = memo_id
    @title = title
    @content = content
  end

  def self.read_by_id(id)
     @@conn.exec( "SELECT * FROM memo WHERE memo_id = '#{id}'" ) do |memo|
       Memo.new(memo[0]['memo_id'],memo[0]['title'], memo[0]['content'])
     end
  end

  def self.read_all
    get_all = @@conn.exec( "SELECT * FROM memo" )
    if get_all.count == 0
      []
    else
       get_all.map do |memo|
        Memo.new(memo['memo_id'],memo['title'], memo['content'])
      end
    end
  end

  def self.insert(new_memo)
    @@conn.exec("INSERT INTO memo VALUES ('#{new_memo.memo_id}', '#{new_memo.title}', '#{new_memo.content}')")
  end

  def self.delete_by_id(id)
    @@conn.exec("DELETE FROM memo WHERE memo_id = '#{id}'" )
  end

  def self.update(edit_memo)
    @@conn.exec("UPDATE memo SET title = '#{edit_memo.title}', content = '#{edit_memo.content}' WHERE memo_id = '#{edit_memo.memo_id}'")
  end
end

helpers do
  def escape_with_converting_line_breaks(text)
    CGI.escapeHTML(text).gsub(/\r\n|\r|\n/, '<br>')
  end
end

get '/memos' do
  @all_memos = []
  Memo.read_all.each do |memo|
    @all_memos << memo
  end

  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  if params[:title] != ''
    new_memo = Memo.new(SecureRandom.uuid, params[:title], params[:content])
    Memo.insert(new_memo)
  end

  redirect '/memos'
end

get '/memos/:id' do
  @memo = Memo.read_by_id(params[:id])

  erb :display_memo
end

delete '/memos/:id' do
  Memo.delete_by_id(params[:del_id])

  redirect '/memos'
end

get '/memos/:id/edit' do
  @memo = Memo.read_by_id(params[:id])

  erb :memo_edit
end

patch '/memos/:id' do
  if params[:title] !=''
    edit_memo = Memo.new(params[:id], params[:title], params[:content])
    Memo.update(edit_memo)
  end

  redirect '/memos'
end

not_found do
  '指定されたページは存在しません。<a href="/memos">トップページ</a>にアクセスしてください。'
end
