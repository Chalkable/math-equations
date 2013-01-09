class ApplicationController < ActionController::Base
  protect_from_forgery


  protected

  def rescue_action_in_public(exception)
    @error = exception
    render "home/error"
  end
end
