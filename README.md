# LetsEncrypt WebFaction

LetsEncrypt utility client for WebFaction hosts.

*NOTE: Version 3 is out and requires some manual changes. See [the upgrade guide for details](docs/upgrading.md).*

This tool automates the process of using LetsEncrypt on WebFaction hosts. It can be added to the Cron scheduled task runner where it will validate your domains automatically, obtain the certificates, and then install them using the Webfaction API.

For more documentation, as well as walkthroughs, [see the wiki](https://github.com/will-in-wi/letsencrypt-webfaction/wiki)!

[![Build Status](https://travis-ci.org/will-in-wi/letsencrypt-webfaction.svg?branch=master)](https://travis-ci.org/will-in-wi/letsencrypt-webfaction)

[![Gem Version](https://badge.fury.io/rb/letsencrypt_webfaction.svg)](https://badge.fury.io/rb/letsencrypt_webfaction)

[![Code Climate](https://codeclimate.com/github/will-in-wi/letsencrypt-webfaction/badges/gpa.svg)](https://codeclimate.com/github/will-in-wi/letsencrypt-webfaction)

*Note: if you find this useful and are setting up a new account, you can support me a little by using [my WebFaction affiliate link](https://www.webfaction.com/?aid=49923). I think I get a 10% referal bonus from whatever you spend at WebFaction. Thanks!*

## Why not Certbot?

[Certbot](https://certbot.eff.org/) is the "official" (in that it was the first and to some extent reference client) Let's Encrypt client. Let's Encrypt decided to focus Certbot on a particular use case, namely the configuration of servers which are directly facing the internet and can have the Certbot application run as root. For other use cases, they encourage the implementation of other clients tailored to different cases. This has spawned a wide variety of alternative implementations.

LetsEncrypt WebFaction is just such an alternative implementation. It was built because the WebFaction use case does not fit in the Certbot preconditions, namely that users don't have root access to change the frontend Nginx server configuration. WebFaction has a custom API we use to install the certificate.

Certbot could probably be used in "webroot" mode to create the certificate on disk, and have someone write a custom plugin to install using the API. For various reasons, I decided not to do this. If someone creates instructions to do this, I'd be happy to link to it from [the wiki](https://github.com/will-in-wi/letsencrypt-webfaction/wiki).

## Prerequisite topics

Below are a list of server administration topics that it is assumed you know in order to follow the installation and setup instructions. If you find something in the readme that is unclear to you, please open a ticket and I'll try to improve the documentation!

### Cron

Cron is an application which will execute commands on a defined schedule. WebFaction has [some good documentation on how to use it](https://docs.webfaction.com/software/general.html#scheduling-tasks-with-cron).

### SSH

All of the commands listed below (unless specified otherwise) are run in an SSH session on the server. Again, WebFaction has written a [splendid little tutorial on how to get this working](https://docs.webfaction.com/user-guide/access.html#ssh).

### SFTP

If you're not happy navigating around your server's folders and files through SSH, you might find some of this process easier if you access your server with an FTP client over Secure FTP. WebFaction [also has this covered](https://docs.webfaction.com/user-guide/access.html#connecting-with-ftp).

## Installation

This utility works on [CentOS 6 and 7 boxes](https://docs.webfaction.com/user-guide/server.html#finding-your-server-s-operating-system). The CentOS 5 systems do not have a new enough OpenSSL to include the algorithms required. You may be able to make this work using rbenv and compiling openssl yourself. A tutorial for CentOS 5 is available here: https://github.com/will-in-wi/letsencrypt-webfaction/wiki/Install-custom-OpenSSL-and-Ruby-on-CentOS-5-host

All places where you need to substitute a value specific to your setup will be denoted with square brackets, e.g. [yourdomain.com]. There are cases where shell variables are used, such as `$HOME`. These should be typed verbatim.

*NOTE: You can install letsencrypt_webfaction using rbenv if you are an advanced Ruby user. Replace the following section with [these instructions](docs/rbenv.md) if you choose to do so.*

Run the following command in an SSH session to install the letsencrypt_webfaction package via the [RubyGems package management site](https://rubygems.org/gems/letsencrypt_webfaction):

```sh
GEM_HOME=$HOME/.letsencrypt_webfaction/gems RUBYLIB=$GEM_HOME/lib gem2.2 install letsencrypt_webfaction
```

Add the following to `~/.bash_profile` (using, for example, an FTP client or your favorite text editor):

```sh
function letsencrypt_webfaction {
    PATH=$PATH:$GEM_HOME/bin GEM_HOME=$HOME/.letsencrypt_webfaction/gems RUBYLIB=$GEM_HOME/lib ruby2.2 $HOME/.letsencrypt_webfaction/gems/bin/letsencrypt_webfaction $*
}
```
This will simplify the running of the LetsEncrypt WebFaction command, by setting some variables in advance.

After saving `~/.bash_profile`, run the command `source $HOME/.bash_profile` to apply the new settings.

Run `letsencrypt_webfaction init` to generate a registration cert and the config file. Open the config file `nano -w ~/letsencrypt_webfaction.toml` and edit to reflect your configuration.

Now, you are ready to run `letsencrypt_webfaction run` from your SSH session to get certificates.

After you run this command, you will see new certificates in the webfaction admin panel, with the names you have provided. You need to change your application to point to this certificate after the certificate has been issued. Future runs of this command will update the existing certificate entry and not require a change in the admin.

## Usage

### Syntax

The syntax of the letsencrypt_webfaction command is as follows:

    $ letsencrypt_webfaction [cmd] [*args]

The commands are `init` and `run`. You can add the `--quiet` argument to the `run` command to keep normal output from appearing (useful in cron).

### Testing

To test certificate issuance, consider using the [LetsEncrypt staging server](https://community.letsencrypt.org/t/testing-against-the-lets-encrypt-staging-environment/6763). This doesn't have the rate limit of 5 certs per domain every 7 days. You can change the `endpoint` config line to be `https://acme-staging.api.letsencrypt.org/` in order to test the system.

### Operation

When letsencrypt_webfaction runs, it places verification files into the public directory specified, validates the domains with LetsEncrypt, and then uploads the certificate to WebFaction's API.

Once you have the certificate installed and working, you will probably want to redirect the HTTP version of your site to the HTTPS version. WebFaction has [documentation describing how to do this](https://docs.webfaction.com/software/static.html#static-redirecting-from-http-to-https).

### Cron usage

Normally, you will run the script manually once to get the certificate, and then you will use Cron to automate future certificate renewal.

The Cron task should run daily (or however often you prefer) and will only renew or issue certs which have been added, changed, or are near or past expiration.

Your Cron task should look like:

```cron
18 3 * * *     PATH=$PATH:$GEM_HOME/bin:/usr/local/bin GEM_HOME=$HOME/.letsencrypt_webfaction/gems RUBYLIB=$GEM_HOME/lib ruby2.2 $HOME/.letsencrypt_webfaction/gems/bin/letsencrypt_webfaction run --quiet
```

*Note the usage of `--quiet` to keep the success message from being shown and emailed.*

This [would run](https://crontab.guru/#18_3_*_*_*) at 03:18 a.m. every day. Change the exact time of the Cron task so that the load on Let's Encrypt is spread out.

If you want to be notified upon failure, you can add `MAILTO=[you@youremail.com]` to the top of the crontab. This will send you an email whenever any cron job outputs standard out or standard error, which is generally good practice. According to the Webfaction [Cron documentaion](https://docs.webfaction.com/software/general.html#scheduling-tasks-with-cron) some webfaction servers also require you to add `MAILFROM=[you@youremail.com]` to the top of the crontab.

## Upgrading

While WebFaction staff maintain your standard server software, the support team will not upgrade your installation of LetsEncrypt WebFaction. You won't usually need to do this unless you have an issue but, as is good practice with most software, it's best kept up to date.

You can find the current version by running `letsencrypt_webfaction --version`. Sort of. In versions >= 1.1.4, this will work. In older versions, this will just print `letsencrypt_webfaction: version unknown` due to an oversight on my part. So if you get the latter output, just upgrade.

[The changelog](CHANGELOG.md) describes changes from version to version.

LetsEncrypt WebFaction follows [Semantic Versioning](http://semver.org/). In a nutshell, a version number such as `1.2.3` is divided as `major.minor.patch`. When the major version is incremented, you will probably have to change something about the configuration to make it work. The changelog will let you know what changes you need to make. When the minor version is incremented, there are new features but existing features haven't changed. If the patch version is incremented, the changes are all under the hood and shouldn't change or add any existing features.

TL;DR: Be careful with major version upgrades and you should be fine with upgrading to minor or patch releases.

To upgrade, run the following command to fetch and install the newest version from RubyGems:

```sh
GEM_HOME=$HOME/.letsencrypt_webfaction/gems RUBYLIB=$GEM_HOME/lib gem2.2 install letsencrypt_webfaction
```

## Development

If you are interested in contributing to this project with new code or bugfixes, welcome!

To run the script directly from the repository, use:

    $ ruby -Ilib exe/letsencrypt_webfaction

See details in the "Testing" section above on how to use the Let's Encrypt stage server when developing, together with usage of the `--support_email` parameter in a testing environment.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `lib/letsencrypt_webfaction.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). This project uses [Semantic Versioning](http://semver.org/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/will-in-wi/letsencrypt-webfaction
