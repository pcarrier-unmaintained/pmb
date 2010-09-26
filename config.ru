#!/usr/bin/env rackup

require 'rubygems'
require 'sinatra'

set :root, File.dirname(__FILE__)
require File.dirname(__FILE__) + '/src/mb.rb'

run MicroBlog.new
