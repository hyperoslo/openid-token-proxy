class HomeController < ApplicationController
  include OpenIDTokenProxy::Authentication

  def index
  end
end
