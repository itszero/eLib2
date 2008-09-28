class NewsController < ApplicationController
  layout 'service'
  before_filter :admin_required, :except => [:index, :show]
  
  def index
    @in_reader_function = true
    @news = Blog.find(:all, :order => "created_at DESC")    
  end
  
  def admin
    @in_admin_function = true
    
    if !params[:id]
      @news = Blog.paginate :page => params[:page], :order => 'created_at DESC'
    else
      @n = Blog.find(params[:id])
      render :partial => 'news_list_item'
    end
  end
  
  def show
    @in_reader_function = true
    @news = Blog.find(params[:id])
    warning_stickie "找不到您指定的新聞。" if !@news
    redirect_to '/news' if !@news
  end
  
  def new
    @news = Blog.new
    @news.title = params[:title]
    @news.content = params[:content]
    @news.save
    
    redirect_to :action => 'admin'
  end
  
  def delete
    Blog.find(params[:id]).destroy
    redirect_to :action => 'admin'
  end
  
  def edit
    if request.post?
      @news = Blog.find(params[:id])
      @news.title = params[:title]
      @news.content = params[:content]
      @news.created_at = params[:date]
      @news.save
      redirect_to '/news/admin'
    else  
      @news = Blog.find(params[:id])
      render :layout => false
    end
  end
end