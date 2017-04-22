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
