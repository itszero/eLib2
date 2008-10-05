class ReaderController < ApplicationController
  before_filter :admin_required, :only => [:rate, :admin]
  before_filter :login_required, :except => [:rate, :admin]
  layout 'service'
  
  def index
    @in_reader_function = true
    @u = current_user
    @r = RentLog.find(:all, :conditions => ['user_id = ?', @current_user.id], :limit => 5, :order => 'created_at DESC')
    @c = Comment.find(:all, :conditions => ['user_id = ?', @current_user.id], :order => 'created_at DESC')
  end

  def rentlogs
    @r = RentLog.find(:all, :conditions => ['user_id = ?', @current_user.id], :order => 'created_at DESC').paginate :page => params[:page]
  end
  
  def list
    @c = Comment.find(:all, :conditions => ['user_id = ?', @current_user.id], :order => 'created_at DESC').paginate :page => params[:page]
  end
  
  def admin
    @c = Comment
    
    if params[:isbn] && params[:isbn] != ''
      @b = Book.find_by_isbn(params[:isbn])
      if @b
        @c = @c.book_is(@b.id)
      else
        warning_stickie "找不到指定的ISBN號碼。"
        params[:isbn] = nil
      end
    end

    if params[:sid] && params[:sid] != ''
      @u = User.find_by_student_id(params[:sid])
      if @u
        @c = @c.user_is(@u.id)
      else
        warning_stickie "找不到指定的學號。"
        params[:sid] = nil
      end
    end
   
    @c1 = @c.find(:all, :order => 'created_at DESC', :conditions => 'score IS NULL')
    @c2 = @c.find(:all, :order => 'created_at DESC', :conditions => 'score IS NOT NULL')
    @c = (@c1 + @c2).paginate :page => params[:page]
  end
  
  def write
    @book = Book.find(params[:id])
    
    if request.post?
      @comment = Comment.new
      @comment.comment = params[:content]
      @comment.user_id = @current_user.id
      @book.comments << @comment
      
      notice_stickie '心得已經儲存成功囉。'
      redirect_to "/reader/read/#{@comment.id}"
      return
    end
  end
  
  def read
    @comment = Comment.find(params[:id])
    if @comment.user_id != @current_user.id && @current_user.permission < 1
      redirect_to '/reader'
      return
    end
    @book = @comment.commentable
  end
  
  def load_text
    render :text => Comment.find(params[:id]).comment
  end
  
  def edit
    @comment = Comment.find(params[:id])
    if @comment.user_id != @current_user.id && @current_user.permission < 1
      redirect_to '/reader'
      return
    end

    @comment.comment = params[:value]
    @comment.save
    
    render :nothing => true
  end
  
  def delete
    @comment = Comment.find(params[:id])
    if @comment.user_id != @current_user.id && @current_user.permission < 1
      redirect_to '/reader'
      return
    end

    @comment.destroy
    notice_stickie "您的心得已經刪除。"
    redirect_to '/reader'
  end
  
  def rate
    @comment = Comment.find(params[:id])
    if @current_user.permission < 1
      redirect_to '/reader'
      return
    end
    
    notice_stickie "給分成功！"
    @comment.score = params[:score]
    @comment.save
    redirect_to "/reader/read/#{@comment.id}"
  end
end
