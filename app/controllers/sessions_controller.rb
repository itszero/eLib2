# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    render_to_facebox
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      @current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      notice_stickie('登入完成，歡迎使用本系統！')
      redirect_back_or_default('/', true)
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render_to_facebox :action => 'new'
      @current_user = nil
    end
  end

  def destroy
    logout_killing_session!
    notice_stickie('登出完成，期待您的再度光臨。')
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    warning_stickie("登入失敗，請檢查您的帳號密碼。")
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
