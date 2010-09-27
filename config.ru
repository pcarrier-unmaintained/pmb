#!/usr/bin/env rackup

require 'rubygems'
require 'sinatra'
require 'sequel'
require 'haml'
require 'logger'

use Rack::Auth::Basic do |username, password|
  [username, password] == ['user','pass']
end

set :root, File.dirname(__FILE__)
set :haml, { :ugly => true }
enable :logging

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')
DB.loggers << Logger.new(STDERR)

require File.dirname(__FILE__) + '/src/pmb.rb'

run PrivateMicroBlog.new
