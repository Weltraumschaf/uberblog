#!/usr/bin/env ruby
# encoding: UTF-8

require 'pathname'
$baseDir = Pathname.new(File.dirname(__FILE__)) + '../..'

require "#{$baseDir}/lib/uberblog"
require 'uberblog/config'
require 'data_mapper'
require 'sinatra'
require 'sinatra/json'
require 'json'

$logger = Uberblog::CliLogger.new
$config = Uberblog::Config.new(File.open("#{$baseDir}/config/blog.yml") { |f| YAML.load(f) }, $baseDir.to_s)

DataMapper::Logger.new($logger.stdout, :debug)
DataMapper.setup(:default, "sqlite://#{$baseDir}/data/database.sqlite")
DataMapper::Model.raise_on_save_failure = true

require 'uberblog/model/rating'
require 'uberblog/model/comment'

DataMapper.finalize

def raise_error(code, message)
  halt(code, json(:error_code => code, :error_message => message))
end

def parse_json(str)
  begin
    return JSON.parse(str)
  rescue
    raise_error(500, %Q{Can't parse JSON! Given request body was '#{str}'.})
  end
end

def create_uri_list(list, prefix = '')
  uris = ''
  list.each { |uri| uris << "#{prefix}#{uri}\n"}
  uris
end

configure do
  mime_type :urilist, 'text/uri-list'
end

not_found do
  "Nothing here.\n"
end

get '/api' do
  redirect '/api/'
end

get '/api/' do
  content_type :urilist
  create_uri_list(['api/rating/', 'api/comment/'], $config.siteUrl)
end

get '/api/rating' do
  redirect '/api/rating/'
end

get '/api/rating/' do
  content_type :urilist
  uris = []
  Uberblog::Model::Rating.all.each { |rating| uris << rating.post }
  create_uri_list(uris, "#{$config.siteUrl}api/rating/")
end

get '/api/rating/:post' do
  rating = Uberblog::Model::Rating.get(params[:post])
  halt 404 if rating.nil?
  json rating.get_attributes
end

put '/api/rating/:post' do
  body = request.body.read
  raise_error 400, %q{Empty request body! Expects JSON like '{rate: 5}'.} if body.size == 0 or body.nil?

  rating = Uberblog::Model::Rating.first_or_create({ :post => params[:post] })
  data   = parse_json(body)
  raise_error 400, %q{Expected JSON key 'rate(Integer)' not present!.} if data['rate'].nil?

  rating.add(data['rate'].to_i)
  $logger.log("Saving rate with: #{data['rate'].to_i}")

  begin
    rating.save
  rescue
    $logger.error $!
    raise_error 500, "Can't save entity! Exception was: #{$!}"
  end

  json rating.get_attributes
end

get '/api/comment' do
  redirect '/api/comment/'
end

get '/api/comment/' do
  content_type :urilist
  uris = []
  Uberblog::Model::Comment.all.each { |comment| uris << comment.post }
  create_uri_list(uris, "#{$config.siteUrl}api/comment/")
end

get '/api/comment/:post' do
  comment = Uberblog::Model::Comment.get(params[:post])
  halt 404 if comment.nil?
  json comment.get_attributes
end

put '/api/comment/:post' do
  body = request.body.read
  raise_error 400, %q{Empty request body! Expects JSON like '{text: "..."}'.} if body.size == 0 or body.nil?

  data    = parse_json(body)
  raise_error 400, %q{Expected JSON key 'text(String)' not present!.} if data['text'].nil?
  raise_error 400, %q{Expected JSON key 'text(String)' is empty!.} if data['text'].empty?

  comment = Uberblog::Model::Comment.new
  comment.post = params[:post]
  comment.text = data[:text]
  comment.name = data['name'] unless data['name'].nil? or data['name'].empty?
  comment.url  = data['url']  unless data['url'].nil? or data['url'].empty?

  begin
    comment.save
  rescue
    $logger.error $!
    raise_error 500, "Can't save entity! Exception was: #{$!}"
  end

  json comment.get_attributes
end