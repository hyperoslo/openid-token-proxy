class AccountsController < ApplicationController
  include OpenIDTokenProxy::Token::Authentication

  require_valid_token

  def show
    render json: current_token, status: :ok
  end
end
