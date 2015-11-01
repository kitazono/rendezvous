class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  add_breadcrumb('Rendezvous', '/')

  before_action :authenticate_user!

  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    render text: "Required parameter missing: #{parameter_missing_exception.param}", status: :bad_request
  end
end
