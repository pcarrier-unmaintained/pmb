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

DB[:posts].insert(:title => "mb created", :date => DateTime.now, :parent_id => nil) unless DB[:posts].count > 0

class MicroBlog < Sinatra::Base
  helpers do
    def display(post)
      haml :post, :locals => {
        :post => post,
        :children => DB[:posts].where(:parent_id => post[:id]).order(:date.desc)
      }
    end
    def current(post)
      params[:rt] == post[:id].to_s
    end
  end
  get '/' do
    redirect '/?rt=1' unless params[:rt]
    haml :base, :locals => {
      :root => DB[:posts].where(:parent_id => nil).first
    }
  end
  post '/' do
    DB[:posts].insert(:title => params[:title],
                      :date => DateTime.now,
                      :parent_id => params[:parent_id])
    redirect back
  end
  get '/del/:id' do |id|
    id = id.to_i
    if id == 1
      "Cannot delete root"
    else
      post = DB[:posts].where(:id => id).first
      if post
        DB[:posts].filter('parent_id = ?', id).update(:parent_id => post[:parent_id])
        DB[:posts].filter('id = ?', id).delete
        redirect back
      end
      "No such post"
    end
  end
end
