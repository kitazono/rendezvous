class User::BaseController < ApplicationController
  def top
    redirect_to flow_path, status: 301
  end
end
