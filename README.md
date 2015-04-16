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

When using [OpenID](http://openid.net/specs/openid-connect-core-1_0.html) in
native applications, the most common approach is to open the identity provider's
authorization page in a web view, let the user authenticate and have the application
hold on to access, identity and refresh tokens.

![Regular OpenID flow](docs/regular-openid-flow.png?raw=1)

However, the above flow may be unusable if the identity provider provides complex
authentication schemes, such as client-side certificates.

On iOS, client-side certificates stored in the system keychain [cannot be obtained due to application sandboxing](http://stackoverflow.com/questions/7648487/how-to-list-certificates-from-the-iphone-keychain-inside-my-app).

On Android, one can obtain system certificates but these [can not be used within a web view](http://stackoverflow.com/questions/15588851/android-webview-with-client-certificate).

![OpenID token proxy flow](docs/openid-token-proxy-flow.png?raw=1)

When using OpenID token proxy, the application opens a web browser - which has
access to client-side certificates regardless of storage location - and lets the
user authenticate. The identity provider redirects to the OpenID token proxy,
which in turn passes along any obtained tokens to the application.


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
  config.redirect_uri = 'https://example.com/auth/callback'
  config.resource = 'https://graph.windows.net'

  # Indicates which domain users will presumably be signing in with
  config.domain_hint = 'example.com'

  # Whether to force authentication in case a session is already established
  config.prompt = 'login'

  # If these endpoints or public keys are not configured explicitly, they will be
  # discovered automatically by contacting the issuer (see above)
  config.authorization_endpoint = 'https://login.windows.net/common/oauth2/authorize'
  config.token_endpoint = 'https://login.windows.net/common/oauth2/token'
  config.userinfo_endpoint = 'https://login.windows.net/common/openid/userinfo'
  config.public_keys = [
    OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9...")
  ]

  # Alternatively, you can override the authorization URI in its entirety:
  config.authorization_uri = 'https://id.hyper.no/authorize?prompt=login'
end
```

Alternatively, these environment variables will be picked up automatically:

- `OPENID_AUTHORIZATION_ENDPOINT`
- `OPENID_AUTHORIZATION_URI`
- `OPENID_CLIENT_ID`
- `OPENID_CLIENT_SECRET`
- `OPENID_DOMAIN_HINT`
- `OPENID_ISSUER`
- `OPENID_PROMPT`
- `OPENID_REDIRECT_URI`
- `OPENID_RESOURCE`
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
