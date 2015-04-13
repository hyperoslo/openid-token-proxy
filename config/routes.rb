OpenIDTokenProxy::Engine.routes.draw do
  get :callback, to: 'callback#handle'
end
