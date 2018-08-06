Unreleased

* [#147](https://github.com/will-in-wi/letsencrypt-webfaction/pull/147) - Changed `RENEWAL_DELTA` to 30 days per LetsEncrypt's recommendation. (@shannonturner)
* Your change here!

v3.1.1

* Fixed a missing require when fetching version. Fixes [#146](https://github.com/will-in-wi/letsencrypt-webfaction/issues/146)

v3.1.0

* Set config file permissions to 600 on creation.
* Output version number with `--version` flag. Fixes [#139](https://github.com/will-in-wi/letsencrypt-webfaction/issues/139)
* Drop support for Ruby 2.1. It's unsupported upstream and third party libraries are dropping support. Feel free to file a ticket if you need this for some reason.
* Restore ability to define custom configuration files paths. Fixes [#136](https://github.com/will-in-wi/letsencrypt-webfaction/issues/136)
* [#144](https://github.com/will-in-wi/letsencrypt-webfaction/pull/144) - Tiny fix so that "default" does what it says on the tin. Thanks to @nootrope for raising this UX issue!

v3.0.1

* Improves messaging when requesting validation fails
* [#127](https://github.com/will-in-wi/letsencrypt-webfaction/pull/127) - Fix output to reference TOML instead of YAML. (@basetta)
* Update Acme::Client to require stable 1.0

v3.0.0

*NOTE: Backwards incompatible, and requires changes to upgrade*

* One command to update all certs
* Checks cert validity and only renews if needed (Run daily instead of every other month)
* Uses config file instead of command line arguments
* Creates a single private key to serve as the registration cert, and reuses. (fixes #122)

v2.2.3

* Fix issue where Acme::Client v0.5.0 changed API. Require newer version and use differently. Fixes #120
* Fix timing issue where it always took 10 seconds to fail.
* Upgrade required Acme::Client to v0.6.0.

v2.2.2

* Removes `output_dir` from configuration as it hasn't been used since 1..
* Rubocop cleanups.
* Fix situation where cert_name has invalid chars. Fixes #114.

v2.2.1

* Fixes issue where older (pre-2.1.0) configs would have a string as the domain. Converts this to array internally.

v2.2.0

* Output helpful message on success unless `--quiet` flag is used. Fixes #86.

v2.1.0

* Allow multiple public directories to be used. The authorization responses will be duplicated across all of them, allowing a single cert to serve multiple applications. Fixes #96 (thanks @lsemprini for the suggestion!)

v2.0.1

* Check WebFaction credentials before issuing cert.

v2.0.0

* Switch to using the Webfaction API for certificate installation.

*MIGRATION NOTES*

* New required parameters for Webfaction API: `username` and `password`. It is recommended that these be passed in a config file instead of being command line arguments.
* `--account_email`, `--admin_notification_email`, and `--support_email` are gone. `--letsencrypt_account_email` remains and needs to be set directly.
* Pony and direct emailing are gone. Since this utility uses the admin interface, the only reason to send emails are for errors, which are handled with the `MAILTO` string in the crontab, per the readme.
* `--cert_name` is a new conditional param. This defaults to the first domain given, with dots replaced by underscores.
* `--servername` and `--api_url` are new params with sane defaults.

v1.1.8

* Remove accidental runtime dependency on Pry.

v1.1.7

* Manually require fileutils, something formerly done automatically.
* Require Acme::Client 0.4.1 to fix `require` issue.
* Output improved help text in case of failure.

v1.1.6

* Fix issue with pulling in ActiveSupport when no longer needed.

v1.1.5

* Doc improvements.
* Require a new enough version of Acme::Client.

v1.1.4

* Show version number with `--version` flag.

v1.1.3

* Lock version of activesupport so that older versions of Ruby still work.

v1.1.2

* Lock version of json-jwt since they changed API.

v1.1.1

* Handle changes in Acme::Client regarding autoloading. Require newer version.

v1.1.0

* Support for additional special email configuration.
* Building on the previous feature, additional documentation around Gmail support.
* Fix issue where users had to specify all params in a custom config file.

v1.0.1

* Clean up help response.
* Sign gems

v1.0.0

* Add support for creating a ticket with WebFaction directly.
* Allowed increased specificity for email address usage.
* Added support for using without RBenv.

v0.0.3

* Updates to readme.

v0.0.2

* Fix a bug related to Gem pathing and the defaults.yml file.

v0.0.1

* Initial release.
