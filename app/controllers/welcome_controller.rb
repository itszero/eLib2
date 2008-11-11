class WelcomeController < ApplicationController
  layout 'service'
  before_filter :admin_required, :only => :admin
  
  def index
    @in_homepage_function = true
    @news = Blog.find(:all, :order => "created_at DESC", :limit => 5)
    
    if !@current_user
      @random_books = []
      maxid = Book.find(:first, :order => "id DESC")
      if maxid != nil
        maxid = maxid.id
      	until @random_books.size >= 6
          b = nil
          suppress(ActiveRecord::RecordNotFound) do
            b = Book.find(rand(maxid) + 1)
          end
          @random_books << b if b && !@random_books.include?(b)
        end
      end
    else
      @rentlog_size = RentLog.find(:all, :conditions => ['user_id = ?', @current_user.id]).size
      @needreturn_size = RentLog.find(:all, :conditions => ['start_date > ? AND start_date < ?', 1.weeks.ago, 2.weeks.ago]).size
      @comments_size = Comment.find(:all, :conditions => ['user_id = ?', @current_user.id]).size
    end
  end
  
  def admin
    @in_admin_function = true
  end
  
  def books
    @books = Book.find(:all, :order => "created_at DESC", :limit => 20)
    headers["Content-Type"] = "application/xml; charset=utf-8"
    render :layout => false
  end
  
  def contact
    if request.post?
      if params[:name] != "" && params[:phone] != "" && params[:email] != "" && params[:content] != ""
        Notifier.deliver_contact params[:name], params[:email], params[:phone], params[:content]
        notice_stickie "您的意見我們已經收到了，我們會儘快改善並且與您聯絡。"
      else
        error_stickie "請先填滿所有資訊再送出。"
      end
    end
  end
end
