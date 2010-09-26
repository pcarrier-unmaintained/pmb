#!/usr/bin/env ruby

require 'rubygems'
require 'sequel'
require 'sinatra/base'
require 'haml'

DB = Sequel.sqlite('db.sqlite3')
DB.create_table? :posts do
  primary_key :id
  String :title
  DateTime :date
  foreign_key :parent_id, :posts
  index :date
end

DB[:posts].insert(:title => "blog creation", :date => DateTime.now, :parent_id => nil) unless DB[:posts].count > 0

class MicroBlog < Sinatra::Base
  helpers do
    def display(post)
      haml :post, :locals => {
        :post => post,
        :children => DB[:posts].where(:parent_id => post[:id])
      }
    end
    def current(post)
      return (params[:rt] == post[:id])
    end
  end
  get '/' do
    haml :base, :locals => {
      :root => DB[:posts].where(:parent_id => nil).first
    }
  end
  post '/' do
    Post.new(:title => params[:title],
             :date => DateTime.now,
             :parent_id => params[:parent_id])
    redirect '/'
  end
end
