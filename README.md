# OpenID token proxy

[![Gem Version](https://img.shields.io/gem/v/openid-token-proxy.svg?style=flat)](https://rubygems.org/gems/openid-token-proxy)
[![Build Status](https://img.shields.io/travis/hyperoslo/openid-token-proxy.svg?style=flat)](https://travis-ci.org/hyperoslo/openid-token-proxy)
[![Dependency Status](https://img.shields.io/gemnasium/hyperoslo/openid-token-proxy.svg?style=flat)](https://gemnasium.com/hyperoslo/openid-token-proxy)
[![Code Climate](https://img.shields.io/codeclimate/github/hyperoslo/openid-token-proxy.svg?style=flat)](https://codeclimate.com/github/hyperoslo/openid-token-proxy)
[![Coverage Status](https://img.shields.io/coveralls/hyperoslo/openid-token-proxy.svg?style=flat)](https://coveralls.io/r/hyperoslo/openid-token-proxy)

Retrieves and refreshes OpenID tokens on behalf of a user when dealing with complex
authentication schemes, such as client-side certificates.

**Note: Under development, not for production usage just yet**

**Supported Ruby versions: 2.0.0 or higher**

Licensed under the **MIT** license, see LICENSE for more information.


## Background

Soon.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openid-token-proxy'
```

Or install it yourself:

    $ gem install openid-token-proxy


## Usage

### Configuration

```ruby
OpenIDTokenProxy.configure do |config|
  config.client_id = 'xxx'
  config.client_secret = 'xxx'
  config.issuer = 'https://login.windows.net/common'
  config.resource = 'https://graph.windows.net'

  # These endpoints may be omitted and will automatically be discovered by
  # contacting the given issuer
  config.authorization_endpoint = 'https://login.windows.net/common/oauth2/authorize'
  config.token_endpoint = 'https://login.windows.net/common/oauth2/token'
  config.userinfo_endpoint = 'https://login.windows.net/common/openid/userinfo'
end
```

Alternatively, these environment variables will be picked up automatically:

- `OPENID_CLIENT_ID`
- `OPENID_CLIENT_SECRET`
- `OPENID_ISSUER`
- `OPENID_RESOURCE`
- `OPENID_AUTHORIZATION_ENDPOINT`
- `OPENID_TOKEN_ENDPOINT`
- `OPENID_USERINFO_ENDPOINT`


### Token acquirement

Soon.


### Authentication

Soon.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a pull request


## Credits

Hyper made this. We're a digital communications agency with a passion for good code,
and if you're using this library we probably [want to hire you](http://hyper.no/jobs).
