class BooksController < ApplicationController
  layout 'service'
  before_filter :admin_required, :except => [:index, :show, :latest_xml, :search]
  
  def index
  end
  
  def latest_xml
    @books = Book.find(:all, :order => "created_at DESC", :limit => 20)
    
    render :layout => false
  end
  
  def circulation
    @in_admin_function = true
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
    @in_books_function = true
    
    @b = Book.find(params[:id])
  end
  
  def get_book_status_by_isbn
    @b = Book.find_by_isbn(params[:isbn])
    if !@b
      render :text => 'fail:isbn'
      return
    end
    
    if @b.rentout?
      render :text => 'fail:rent'
      return
    end
    
    render :text => @b.title
  end
  
  def rent_book
    @b = Book.find_by_isbn(params[:isbn])
    
    if !@b
      render :text => 'fail'
      return
    end
    
    @u = User.find_by_student_id(params[:stuid])
    
    if !@u
      render :text => 'fail'
      return
    end
    
    @b.rent_to(@u)
    render :text => 'ok'
  end
  
  def return_book
    @b = Book.find_by_isbn(params[:isbn])
    
    @b.return_book
    
    render :text => 'ok'
  end
  
  def overdue
   @r = RentLog.find(:all, :conditions => ['start_date <= ? AND end_date IS NULL', 1.week.ago])
  end
  
  def search
    @in_books_function = true
    @books = Book.filter(params[:keyword]).paginate :page => params[:page], :per_page => 10
  end
  
  def suggests
    if params[:do]
      case params[:do]
      when "accept" then
        Suggest.find(params[:id]).accept!
        notice_stickie "圖書推薦已經同意。"
      when "reject" then
        Suggest.find(params[:id]).reject!
        warning_stickie "圖書推薦退件完成。"
      when "reset" then
        Suggest.find(params[:id]).reset!
        notice_stickie "圖書推薦重新設定為審查中。"
      when "delete" then
        Suggest.find(params[:id]).destroy
        notice_stickie "圖書推薦資料已經刪除。"
      end
      
      redirect_to :back
    end
    
    @suggests = Suggest.find(:all, :order => 'created_at DESC').paginate :page => params[:page], :per_page => 20
  end
end
