module OpenIDTokenProxy
  class CallbackController < ApplicationController
    include OpenIDTokenProxy::Concerns::CallbackController
  end
end
