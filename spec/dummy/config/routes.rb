Rails.application.routes.draw do
  mount OpenIDTokenProxy::Engine, at: '/auth'
end
