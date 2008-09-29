class BooksController < ApplicationController
  layout 'service'
  before_filter :admin_required, :except => [:index, :show]
  
  def index
  end
  
  def latest_xml
    @books = Book.find(:all, :order => "created_at DESC", :limit => 20)
    
    render :layout => false
  end
  
  def admin
    @in_admin_function = true
    if params[:filter]
      @books = Book.filter(params[:filter]).paginate :page => params[:page]
    else
      @books = Book.paginate :page => params[:page]
    end
  end
  
  def new
    @in_admin_function = true
    if request.post?
      @b = Book.new(params[:book])
      
      if @b.save
        notice_stickie "館藏 #{params[:book][:title]} 新增成功！"
      else
        error_stickie '館藏無法新增，請檢查資料。 #{@b.errors.inspect}'
      end
      redirect_to :action => 'admin'
    end
    
    @b = Book.new
  end
  
  def edit
    @in_admin_function = true
    if request.post?
      @b = Book.find(params[:id])
      @b.update_attributes params[:book]
      @b.save

      redirect_to :action => 'admin'
      return
    end
    
    @is_edit = true
    
    @b = Book.find(params[:id])
    if !@b
      redirect_to :action => 'admin'
      return
    end
    
    render :action => 'new'
  end
  
  def delete
    Book.find(params[:id]).destroy
    redirect_to :action => 'admin'
  end
  
  def show
    @b = Book.find(params[:id])
  end
end
