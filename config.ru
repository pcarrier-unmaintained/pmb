#!/usr/bin/env rackup

require 'rubygems'
require 'sinatra'

set :root, File.dirname(__FILE__)
require File.dirname(__FILE__) + '/src/mb.rb'

use Rack::Auth::Basic do |username, password|
  [username, password] == ['user','pass']
end

run MicroBlog.new
