class HomeController < ApplicationController
  include OpenIDTokenProxy::Token::Authentication
  include OpenIDTokenProxy::Token::Refresh

  def index
  end
end
