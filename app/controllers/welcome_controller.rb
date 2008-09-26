class WelcomeController < ApplicationController
  layout 'service'
  before_filter :admin_required, :only => :admin
  
  def index
    @in_homepage_function = true
    @news = Blog.find(:all, :order => "created_at DESC", :limit => 5)
  end
  
  def admin
    @in_admin_function = true
  end
end
