# Installing with RBenv

This method is useful if you are already using RBEnv to manage Ruby, or if you are already a Ruby developer. If neither of these cases are true, just use the system Ruby method as described in the readme.

Follow the instructions to [set up RBEnv](https://github.com/rbenv/rbenv) and [Ruby Build](https://github.com/rbenv/ruby-build#readme) on your WebFaction server.

Once you have done so, install Ruby 2.1+, but <2.4 (probably 2.3.1 at time of writing). Then set the local Ruby and install the Gem. Finally unset the local Ruby so that you don't run into problems.

    $ rbenv install 2.3.1 # Installs Ruby 2.3.1
    $ rbenv local 2.3.1 # Sets Ruby 2.3.1 as the default version in the current folder.
    $ gem install letsencrypt_webfaction # Installs this utility from RubyGems.
    $ rbenv rehash # Makes RBenv aware of the letsencrypt_webfaction utility.
    $ rm .ruby-version # Unsets Ruby 2.3.1 as the default version in the current folder.

*Ruby 2.4.0+ is not supported since they removed the XMLRPC library from core and moved it to a gem. This Gem doesn't work in Ruby <2.3, leaving us with an issue as the majority of system Rubies used with this project are <2.4. So don't use 2.4 for now. If you absolutely want to, make sure you install the xmlrpc gem manually.*

## Cron usage

Instead of the cron command in the readme, when using rbenv it would look like the following:

```cron
18 3 * * *     RBENV_ROOT=~/.rbenv RBENV_VERSION=2.3.1 ~/.rbenv/bin/rbenv exec letsencrypt_webfaction --letsencrypt_account_email [you@youremail.com] --domains [yourdomain.com,www.yourdomain.com] --public ~/webapps/[yourapp/your_public_html]/ --quiet --username [yourusername] --password [yourpassword]
```

## Upgrading

To upgrade the installed version, run:

```sh
RBENV_VERSION=2.3.1 gem install letsencrypt_webfaction
```
