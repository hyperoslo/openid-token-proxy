Rails.application.routes.draw do
  root to: 'home#index'
  resource :account
  mount OpenIDTokenProxy::Engine, at: '/auth'
end
