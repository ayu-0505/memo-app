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

  def self.open_json
    File.open('db.json', 'r') do |file|
      open_json_file = JSON.load(file)
      if open_json_file.nil?
        []
      else
        open_json_file.map do |memo|
          memo.transform_keys(&:to_sym)
        end
      end
    end
  end

  def self.updata_json(json)
    File.open('db.json', 'w') { |file| file << JSON.pretty_generate(json) }
  end
end

helpers do
  def escape(text)
    CGI.escapeHTML(text)
  end
end

get '/' do
  all_memos = []
  Memo.open_json.each do |memo|
    all_memos << Memo.new(memo[:memo_id], memo[:title], memo[:content])
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
    new_memo_to_list = {}
    new_memo_to_list[:memo_id] = new_memo.memo_id
    new_memo_to_list[:title] = new_memo.title
    new_memo_to_list[:content] = new_memo.content
    all_memos = Memo.open_json
    all_memos.push(new_memo_to_list)
    Memo.updata_json(all_memos)
  end

  redirect '/'
end

get '/memos/:id' do
  display_memo = Memo.open_json.find { |memo| memo[:memo_id] == params[:id] }
  @memo_id = display_memo[:memo_id]
  @title = display_memo[:title]
  @content = display_memo[:content]

  erb :display_memo
end

delete '/memos/del' do
  all_memos = Memo.open_json
  all_memos.delete_if { |memo| memo[:memo_id] == params[:id] }
  Memo.updata_json(all_memos)

  redirect '/'
end

get '/memos/:id/edit' do
  @memo = Memo.open_json.find { |memo| memo[:memo_id] == params[:id] }

  erb :memo_edit
end

patch '/memos/:id' do
  all_memos = Memo.open_json
  index_num = all_memos.find_index { |memo| memo[:memo_id] == params[:id] }
  all_memos[index_num][:title] = escape(params[:title])
  all_memos[index_num][:content] = escape(params[:content])
  Memo.updata_json(all_memos)

  redirect '/'
end

not_found do
  '指定されたページは存在しません。<a href="/">トップページ</a>にアクセスしてください。'
end
