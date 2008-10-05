require 'csv'

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'service'
  before_filter :super_required, :only => [:staff, :demote, :promote]
  before_filter :admin_required, :except => [:index, :edit, :bulk_add, :demote, :promote]
  before_filter :login_required, :only => [:edit]

  def index
    redirect_to '/'
  end

  def admin
    @in_admin_function = true
    if !params[:id]
      @user = User.paginate :page => params[:page]
    else
      @u = User.find(params[:id])
      render :partial => 'user_list_item'
    end
  end
  
  def details
    @u = User.find(params[:id])
    @r = RentLog.find(:all, :conditions => ['user_id = ?', params[:id]]).paginate :page => params[:page]
  end
  
  def staff
    @in_admin_function = true
    @user = User.find(:all, :conditions => 'permission > 0', :order => 'permission DESC, id ASC')
  end

  def promote
    @user = User.find(params[:id])
    
    if !@user
      error_stickie "找不到使用者 ##{params[:id]}"
      redirect_to :action => :staff
      return
    end
    
    @user.permission+=1 if @user.permission < 2
    @user.save
    
    notice_stickie "使用者 「#{@user.name}」 已提昇權限"
    redirect_to :action => :staff
  end
  
  def demote
    @user = User.find(params[:id])
    
    if !@user
      error_stickie "找不到使用者 ##{params[:id]}"
      redirect_to :action => :staff
      return
    end
    
    @user.permission-=1 if @user.permission > 1
    @user.save
    
    notice_stickie "使用者 「#{@user.name}」 已降低權限"
    redirect_to :action => :staff    
  end

  def set_permission
    suppress(ActiveRecord::RecordNotFound) do
      @user = User.find(params[:id])
    end

    suppress(ActiveRecord::RecordNotFound) do
      @user = User.find_by_login(params[:id]) if !@user
    end
    
    if !@user
      error_stickie "找不到使用者 ##{params[:id]}"
      redirect_to :action => :staff
      return
    end
    
    @user.permission = params[:permission]
    if params[:permission].to_i == 0
      notice_stickie "使用者 「#{@user.name}」 的權限已取消。"
    elsif params[:permission].to_i > 0
        notice_stickie "使用者 「#{@user.name}」 已經設定為工作人員。"    
    end
    @user.save
    
    redirect_to :action => :staff    
  end
  
  def uid_autocomplete
    @users = User.find(:all, :conditions => "login LIKE '%#{params[:q]}%'")

    render :text => (@users.map &:login).join("\n")
  end

  def bulk_add
    @in_admin_function = true
    
    if request.post?
      csv = CSV.parse(params[:csv].read)
      header = csv.shift
      
      # check reader
      expect_header = ['login', 'email', 'password', 'name', 'student_id', 'student_class']
      pass = true
      expect_header.each do |h|
        pass = false if !header.include? h
      end
      
      if !pass
        error_stickie "匯入的欄位有缺失，請檢查CSV檔案！"
        redirect_to :action => :bulk_add
        return
      end
      
      # read it
      result = []
      csv.each do |row|
        result << Hash[*header.zip(row.to_a).flatten]
      end
      
      errors = []
      # add it
      result.each do |r|
        u = User.new(r)
        u.password_confirmation = u.password
	u.permission = 0
        if !u.save
          errors << "使用者 #{r["login"]} 無法新增，請檢查資料。"
        end
      end
      
      if errors != []
        error_stickie errors.join("<br/>")
      end
      notice_stickie("收到 #{result.size} 筆資料，成功新增 #{result.size - errors.size} 筆，失敗 #{errors.size} 筆。")
      
      redirect_to :action => :bulk_add
    end
  end
 
  def create
    @user = User.new
    @user.login = params[:login]
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.student_id = params[:student_id]
    @user.student_class = params[:student_class]
    @user.name = params[:name]
    @user.email = params[:email]
    @user.nickname = params[:nickname] if params[:nickname]
    @user.permission = 0
    if @user.save
      notice_stickie "使用者 #{params[:login]} 建立成功"
    else
      error_stickie "無法建立使用者 #{params[:login]}<br/>#{@user.errors.inspect}"
    end
    
    redirect_to :action => 'admin'    
  end
  
  def delete
    User.find(params[:id]).destroy
    redirect_to :action => 'admin'
  end
  
  def edit
    if request.post?
      if @current_user.permission == 2 || @current_user.id == params[:id]
        @user = User.find(params[:id])
        @user.student_id = params[:student_id]
        @user.student_class = params[:student_class]
        @user.name = params[:name]
        @user.email = params[:email]
        @user.nickname = params[:nickname] if params[:nickname]
        @user.password = @user.password_confirmation = params[:password] if params[:password] && params[:password] != ''
        @user.save
      end
      
      if @current_user.permission > 0
        redirect_to '/users/admin'        
      else
        redirect_to '/users/edit'
      end
    else
      if @current_user.permission == 0
        @u = User.find(@current_user.id)
      else
        @u = User.find(params[:id])
        render :layout => false
      end
    end
  end
  
  def get_reader_status_by_student_id
    @u = User.find_by_student_id(params[:id])
    
    if !@u
      render :text => 'fail:noid'
      return
    end
    
    render :text => @u.name
  end
end
