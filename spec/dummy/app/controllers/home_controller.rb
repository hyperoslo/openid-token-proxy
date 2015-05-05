class HomeController < ApplicationController
  include OpenIDTokenProxy::Token::Authentication

  def index
  end
end
