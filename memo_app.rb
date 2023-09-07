# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'cgi/escape'

class Memo
  attr_accessor :memo_id, :title, :content

  def initialize(memo_id, title, content)
    @memo_id = memo_id
    @title = title
    @content = content
  end

  def self.read_by_id(id)
    Memo.read_all.find { |memo| memo.memo_id == id }
  end

  def self.read_all
    if File.empty?('db.json')
      []
    else
      File.open('db.json', 'r') do |file|
        all_memos_in_db_file = JSON.parse(file.read)
        all_memos_in_db_file.map do |memo|
          memo = memo.transform_keys(&:to_sym)
          Memo.new(memo[:memo_id], memo[:title], memo[:content])
        end
      end
    end
  end

  def self.insert(new_memo)
    all_memos = Memo.read_all
    all_memos.push(new_memo)
    Memo.update_all(all_memos)
  end

  def self.delete_by_id(id)
    all_memos = Memo.read_all
    all_memos.delete_if { |memo| memo.memo_id == id }
    Memo.update_all(all_memos)
  end

  def self.update_all(all_memos)
    File.open('db.json', 'w') { |file| file << JSON.pretty_generate(all_memos.map(&:convert_to_json)) }
  end

  def convert_to_json
    memo_in_json_form = {}
    memo_in_json_form[:memo_id] = memo_id
    memo_in_json_form[:title] = title
    memo_in_json_form[:content] = content
    memo_in_json_form
  end
end

helpers do
  def escape_with_converting_line_breaks(text)
    CGI.escapeHTML(text).gsub(/\r\n|\r|\n/, '<br>')
  end
end

get '/' do
  @all_memos = []
  Memo.read_all.each do |memo|
    @all_memos << memo
  end

  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos/new' do
  if params[:title] != ''
    new_memo = Memo.new(SecureRandom.uuid, params[:title], params[:content])
    Memo.insert(new_memo)
  end

  redirect '/'
end

get '/memos/:id' do
  @memo = Memo.read_by_id(params[:id])

  erb :display_memo
end

delete '/memos/del' do
  Memo.delete_by_id(params[:id])

  redirect '/'
end

get '/memos/:id/edit' do
  @memo = Memo.read_by_id(params[:id])

  erb :memo_edit
end

patch '/memos/:id' do
  edit_memo = Memo.new(params[:id], params[:title], params[:content])
  Memo.delete_by_id(edit_memo.memo_id)
  Memo.insert(edit_memo)

  redirect '/'
end

get '/test' do
  erb :test
end

not_found do
  '指定されたページは存在しません。<a href="/">トップページ</a>にアクセスしてください。'
end
