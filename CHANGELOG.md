# Changelog

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
