# LetsEncrypt Webfaction

LetsEncrypt utility client for WebFaction hosts.

This tool simplifies the manual process of using LetsEncrypt on Webfaction hosts. It can be added to cron where it will validate your domains automatically, place the generated certificates in a common folder, and then email you directions and example text to send the WebFaction support team.

[![Build Status](https://travis-ci.org/will-in-wi/letsencrypt-webfaction.svg?branch=master)](https://travis-ci.org/will-in-wi/letsencrypt-webfaction)

## Installation

Because WebFaction has an unusual Ruby setup with the default Ruby as 1.8, I recommend that you [set up RBEnv](https://github.com/rbenv/rbenv) and [Ruby Build](https://github.com/rbenv/ruby-build#readme) on your WebFaction server to run this script.

Once you have done so, install Ruby 2.1+ (probably 2.3.0 at time of writing). Then set the local Ruby and install the Gem. Finally unset the local Ruby so that you don't run into problems.

    $ rbenv install 2.3.0
    $ rbenv local 2.3.0
    $ gem install letsencrypt_webfaction
    $ rbenv rehash
    $ rm .ruby-version

## Usage

Basic example:

    $ letsencrypt_webfaction --contact me@example.com --domains example.com,www.example.com --public ~/webapps/myapp/public_html/

To quickly get a list of parameters, you can call:

    $ letsencrypt_webfaction --help

### Cron usage

Normally, you will run the script manually once to get the certificate, and then you will use Cron to automate future certificate renewal.

Your cron task could look something like:

    0 4 * */2 *     RBENV_ROOT=~/.rbenv RBENV_VERSION=2.3.0 ~/.rbenv/bin/rbenv exec letsencrypt_webfaction --contact you@example.com --domains example.com,www.example.com --public ~/webapps/myapp/

This [would run](http://crontab.guru/#0_4_*_*/2_*) at 4 a.m. in Jan, Mar, May, Jul, Sep, and Nov. Certificates expire three months after issuance, so modify as desired.

If you have more than one cron task running like this, you may want to set the environment variables at the top of the file, and create a config file containing the contact information.

### Detailed examples

Default parameters can be found in [config.defaults.yml](./config.defaults.yml). All of the parameters can be overridden by passing another config file, arguments to the executable, or both. If a config file and arguments are passed, they will be interleaved with the arguments having precedence.

A config file needs to be in YAML format and have a subset of the keys in [config.defaults.yml](./config.defaults.yml). If you use a config file, you pass the `--config ./myconfig.yml` parameter.

This allows you to set up a cron task for multiple sites with the defaults for all of them (such as your email address) in a config file, and site specific directives in the command. For example:

    $ letsencrypt_webfaction --config ~/le_config.yml --domains example.com,www.example.com --public ~/webapps/myapp/public_html/

This could be run automatically every two months.

### Operation

When the code runs, it places verification files into a public directory, validates the domains with LetsEncrypt (or your ACME provider), and then dumps the signed certificate and private key into an output folder. By default, the output folder is `~/le_certs/`, inside which it will create `[domain_name]/[timestamp]/`.

After this is done, the utility will dump to stdout instructions regarding how to request that your new certs be installed by the WebFaction admins. This will include sample text and a link to https://help.webfaction.com/.

If you use Cron, you should set `MAILTO=youremail@example.com` and `MAILFROM=username@servername.webfaction.com` at the top in order to receive the instructions. The [WebFaction docs](https://docs.webfaction.com/software/general.html#scheduling-tasks-cron) have more details about how to do this.

If you see messages containing SyntaxErrors, you are most likely using an old version of Ruby. This utility requires Ruby 2.1+.

### Public folders

For this utility to work, it is assumed that there is a folder which is directly served at `http://yourdomain/` into which the ACME verification files can be placed.

In the case of a PHP site, such as Drupal or Wordpress, look for the folder with `index.php` in it. This is usually in `/home/myuser/webapps/myapp/`.

In the case of a Rails app, look for a folder called `public/`. If you are deploying your app with Capistrano, this could show up in `/home/myuser/webapps/myapp/current/public/`.

## Development

To run the script directly from the repository, use:

    $ ruby -Ilib exe/letsencrypt_webfaction

To test certificate issuance, consider using the [LetsEncrypt staging server](https://community.letsencrypt.org/t/testing-against-the-lets-encrypt-staging-environment/6763). This doesn't have the 5 certs per domain every 7 days rate limit. You can add the `--endpoint https://acme-staging.api.letsencrypt.org/` parameter to do so.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `lib/letsencrypt_webfaction.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). This project uses [Semantic Versioning](http://semver.org/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/will-in-wi/letsencrypt-webfaction
