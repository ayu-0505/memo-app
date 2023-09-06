# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'cgi'

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

  def self.delete(id)
    all_memos = Memo.read_all
    all_memos.delete_if { |memo| memo.memo_id == id }
    Memo.update_all(all_memos)
  end

  def self.update_all(all_memos)
    File.open('db.json', 'w') { |file| file << JSON.pretty_generate(all_memos.map(&:convert_to_json)) }
  end

  def convert_to_json
    new_memo_to_list = {}
    new_memo_to_list[:memo_id] = memo_id
    new_memo_to_list[:title] = title
    new_memo_to_list[:content] = content
    new_memo_to_list
  end
end

helpers do
  def escape(text)
    CGI.escapeHTML(text)
  end
end

get '/' do
  all_memos = []
  Memo.read_all.each do |memo|
    all_memos << memo
  end
  @memo_table = '<ul>'
  all_memos.each { |memo| @memo_table += "<li><a href=\"/memos/#{memo.memo_id}\">#{memo.title}</a></li>" }
  @memo_table += '</ul>'

  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos/new' do
  if params[:title] != ''
    new_memo = Memo.new(SecureRandom.uuid, escape(params[:title]), escape(params[:content]))
    Memo.insert(new_memo)
  end

  redirect '/'
end

get '/memos/:id' do
  @memo = Memo.read_by_id(params[:id])

  erb :display_memo
end

delete '/memos/del' do
  Memo.delete(params[:id])

  redirect '/'
end

get '/memos/:id/edit' do
  @memo = Memo.read_by_id(params[:id])

  erb :memo_edit
end

patch '/memos/:id' do
  edit_memo = Memo.new(params[:id], params[:title], params[:content])
  Memo.delete(edit_memo.memo_id)
  Memo.insert(edit_memo)

  redirect '/'
end

not_found do
  '指定されたページは存在しません。<a href="/">トップページ</a>にアクセスしてください。'
end
