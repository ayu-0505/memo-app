# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'cgi'

class Memo
  attr_accessor :memo_id, :title, :content, :h

  def initialize(memo_id, title, content)
    @memo_id = memo_id
    @title = title
    @content = content
    @h = {}
    @h[:memo_id] = @memo_id
    @h[:title] = @title
    @h[:content] = @content
  end

  def self.open_json
    File.open('db.json', 'r') do |file|
      open_json_file = JSON.load(file, symbolize_names: true)
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

get '/memo-top' do
  json = Memo.open_json
  memos = []
  json.each do |memo|
    memos << Memo.new(memo[:memo_id], memo[:title], memo[:content])
  end
  @memo_table = '<ul>'
  memos.each do |memo|
    @memo_table += "<p><a href =\"/memos/#{memo.memo_id}\"><li>#{memo.title}</a></p>"
  end
  @memo_table += '<ul>'

  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos/new' do
  unless params[:title] == ''
    id = SecureRandom.uuid
    title = escape(params[:title])
    content = escape(params[:content])
    new_memo = Memo.new(id, title, content)
    json = Memo.open_json
    json.push(new_memo.h)
    Memo.updata_json(json)
  end
  redirect '/memo-top'
end

get '/memos/:id' do
  @url_id = params[:id]
  @json = Memo.open_json
  erb :display_memo
end

delete '/memos/del' do
  json = Memo.open_json
  json.delete_if { |memo| memo[:memo_id] == params[:id] }
  Memo.updata_json(json)
  redirect '/memo-top'
end

get '/memos/:id/edit' do
  @memo = Memo.open_json.find { |memo| memo[:memo_id] == escape(params[:id]) }

  erb :memo_edit
end

patch '/memos/:id' do
  json = Memo.open_json
  index_num = json.find_index { |memo| memo[:memo_id] == params[:id] }
  json[index_num][:title] = escape(params[:title])
  json[index_num][:content] = escape(params[:content])
  Memo.updata_json(json)

  redirect '/memo-top'
end
