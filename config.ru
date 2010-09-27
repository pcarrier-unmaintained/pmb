#!/usr/bin/env rackup

require 'rubygems'
require 'sinatra'

set :root, File.dirname(__FILE__)
require File.dirname(__FILE__) + '/src/pmb.rb'

use Rack::Auth::Basic do |username, password|
  [username, password] == ['user','pass']
end

set :haml, { :ugly => true }

run PrivateMicroBlog.new
