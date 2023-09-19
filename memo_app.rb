# frozen_string_literal: true

require 'pg'
require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'cgi/escape'

class Memo
  attr_accessor :memo_id, :title, :content

  @conn = PG::Connection.open(dbname: 'memo_app_db')
  @conn.prepare('read_by_id', 'SELECT * FROM memos WHERE memo_id = $1')
  @conn.prepare('insert', 'INSERT INTO memos VALUES ($1, $2, $3)') # $1 = memo_id, $2 = title, $3 = content
  @conn.prepare('delete', 'DELETE FROM memos WHERE memo_id = $1')
  @conn.prepare('update', 'UPDATE memos SET title = $1, content = $2 WHERE memo_id = $3')

  def initialize(memo_id, title, content)
    @memo_id = memo_id
    @title = title
    @content = content
  end

  def self.read_by_id(id)
    @conn.exec_prepared('read_by_id', [id]) { |memo| Memo.new(memo[0]['memo_id'], memo[0]['title'], memo[0]['content']) }
  end

  def self.read_all
    get_all = @@conn.exec('SELECT * FROM memos')
    if get_all.count.zero?
      []
    else
      get_all.map { |memo| Memo.new(memo['memo_id'], memo['title'], memo['content']) }
    end
  end

  def self.insert(new_memo)
    @conn.exec_prepared('insert', [new_memo.memo_id, new_memo.title, new_memo.content])
  end

  def self.delete_by_id(id)
    @conn.exec_prepared('delete', [id])
  end

  def self.update(edit_memo)
    @conn.exec_prepared('update', [edit_memo.title, edit_memo.content, edit_memo.memo_id])
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
  if params[:title] != ''
    edit_memo = Memo.new(params[:id], params[:title], params[:content])
    Memo.update(edit_memo)
  end

  redirect '/memos'
end

not_found do
  '指定されたページは存在しません。こちらの<a href="/memos">トップページ</a>にアクセスしてください。'
end
