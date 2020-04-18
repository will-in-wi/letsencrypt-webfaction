# Installing with RBenv

This method is useful if you are already using RBEnv to manage Ruby, or if you are already a Ruby developer. If neither of these cases are true, just use the system Ruby method as described in the readme.

Follow the instructions to [set up RBEnv](https://github.com/rbenv/rbenv) and [Ruby Build](https://github.com/rbenv/ruby-build#readme) on your WebFaction server.

Once you have done so, install Ruby 2.4+. Then set the local Ruby and install the Gem. Finally unset the local Ruby so that you don't run into problems.

    $ rbenv install 2.7.0 # Installs Ruby 2.7.0
    $ rbenv local 2.7.0 # Sets Ruby 2.7.0 as the default version in the current folder.
    $ gem install letsencrypt_webfaction # Installs this utility from RubyGems.
    $ rbenv rehash # Makes RBenv aware of the letsencrypt_webfaction utility.
    $ rm .ruby-version # Unsets Ruby 2.7.0 as the default version in the current folder.

## Cron usage

Instead of the cron command in the readme, when using rbenv it would look like the following:

```cron
18 3 * * *     RBENV_ROOT=~/.rbenv RBENV_VERSION=2.7.0 ~/.rbenv/bin/rbenv exec letsencrypt_webfaction --letsencrypt_account_email [you@youremail.com] --domains [yourdomain.com,www.yourdomain.com] --public ~/webapps/[yourapp/your_public_html]/ --quiet --username [yourusername] --password [yourpassword]
```

## Upgrading

To upgrade the installed version, run:

```sh
RBENV_VERSION=2.7.0 gem install letsencrypt_webfaction
```
