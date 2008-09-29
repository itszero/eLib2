class WelcomeController < ApplicationController
  layout 'service'
  before_filter :admin_required, :only => :admin
  
  def index
    @in_homepage_function = true
    @news = Blog.find(:all, :order => "created_at DESC", :limit => 5)
    @random_books = []
    maxid = Book.find(:first, :order => "id DESC").id
    until @random_books.size >= 6
      b = nil
      suppress(ActiveRecord::RecordNotFound) do
        b = Book.find(rand(maxid) + 1)
      end
      @random_books << b if b && !@random_books.include?(b)
    end
  end
  
  def admin
    @in_admin_function = true
  end
end
