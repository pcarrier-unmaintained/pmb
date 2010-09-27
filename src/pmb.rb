DB.create_table? :blogs do
  primary_key :id
  String :name
  index :name
end

DB.create_table? :posts do
  primary_key :id
  String :title
  DateTime :date
  foreign_key :parent_id, :posts
  foreign_key :blog_id, :blogs
  TrueClass :deleted
  index :date
end

# posts.insert(:title => "mb created", :date => DateTime.now, :parent_id => nil) unless posts.count > 0 # TODO

Blogs = DB['blogs']
Posts = DB['posts']

class PrivateMicroBlog < Sinatra::Base
  helpers do
    def display(post)
      children = Posts.where(:parent_id => post[:id]).order(:date.desc)
      children = children.where(:deleted => false) unless params[:archives]
      haml :post, :locals => {
        :post => post,
        :children => children
      }
    end
    def current(post)
      params[:rt] == post[:id].to_s
    end
  end

  def get_root(blog)
    Posts[:blog_id => blog[:id]][:parent_id => nil]
  end

  get '/del/:id' do |id|
    post = Posts[:id => id.to_i]
    if post
      if post[:parent_id]
        Posts.filter('parent_id = ?', id).update(:parent_id => post[:parent_id])
        Posts.filter('id = ?', id).update(:deleted => true)
        redirect back
      else
        "Cannot delete root"
      end
    else
      "No such post"
    end
  end

  get '/:blog' do |name|
    blog = Blogs[:name => name]
    # if blog
    #  haml :base, :locals => {
    #    :root => get_root(blog),
    #    :blog => name
    #  }
    #else
    #  "No such blog" # Blog creation to do!
    #end
  end

  post '/:blog' do |name|
    blog = Blogs[:name => name]
    if blog
      Posts.insert(:blog_id => blog[:id],
                   :title => params[:title],
                   :date => DateTime.now,
                   :parent_id => params[:parent_id],
                   :deleted => false)
      else
        "No such blog"
      end
    redirect back
  end

end
