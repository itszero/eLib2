class WelcomeController < ApplicationController
  layout 'service'
  
  def index
    @in_homepage_function = true
  end
  
  def admin
    @in_admin_function = true
  end
end
