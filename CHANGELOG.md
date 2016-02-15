# Changelog

### v0.1.7 - February 15, 2016

- Allow passing tokens from cookies.
- Allowing hooking into token refreshment.

### v0.1.6 - October 13, 2015

- Update openid_connect to latest version.


### v0.1.5 - September 3, 2015

- Exposes `Config#end_session_endpoint` for logging out.


### v0.1.4 - June 29, 2015

- Adds `Token#valid?`.
- `Client#retrieve_token!` now supports retrieving token via username/password.


### v0.1.3 - May 21, 2015

- Temporary workaround for OpenSSL error queue corruption.


### v0.1.2 - May 18, 2015

- Allow overriding `CallbackController`.


### v0.1.1 - May 12, 2015

- Token expiry time is exposed through `X-Token-Expiry-Time` header.
- Adds `Token#expiry_time`.


### v0.1.0 - May 6, 2015

- Initial release.
