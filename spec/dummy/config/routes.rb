Rails.application.routes.draw do
  root to: 'home#index'
  mount OpenIDTokenProxy::Engine, at: '/auth'
end
