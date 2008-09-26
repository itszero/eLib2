# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FaceboxRender
  include AuthenticatedSystem
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ce44bb469671dfe6809abe1eb0fe97bd'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :get_sessions
  after_filter :set_sessions
  
  private
  def get_sessions
    @current_user = session[:current_user]
  end
  
  def set_sessions
    session[:current_user] = @current_user
  end
end
