# Upgrading from v3 to v4

Switching to ACMEv2 broke backwards compatibility in a couple ways.

- You need to change the `endpoint` entry in your config to `directory` and update it to staging or production.
  directory = "https://acme-staging-v02.api.letsencrypt.org/directory" # Staging
  #directory = "https://acme-v02.api.letsencrypt.org/directory" # Production

# Upgrading from v2 to v3

Version 3 has a number of major ease of use improvements that break backwards compatibility:

- Run one command to update all certs instead of one command per cert.
- When the command runs, it only updates certs that need updating.
- Uses a single config file instead of a large set of command arguments.

The basic procedure to upgrade is:

- Upgrade the program
- Initialize the config file
- Migrate command lines to the config file
- Replace crontab lines with new single line

## Upgrade the program

Follow the [instructions in the readme](/README.md#Upgrading).

## Initialize the config file

Create the config file by running `letsencrypt_webfaction init` on the server. Edit it to reflect your situation (`nano -w ~/letsencrypt_webfaction.toml`).

## Migrate command lines to the config file

You can dump the letsencrypt_webfaction crontab lines by running `crontab -l | grep letsencrypt_webfaction` on the server. For each line, create a `[[certificate]]` section in the config file.

For example, this:

```sh
0 4 1 */2 *      RBENV_ROOT=~/.rbenv RBENV_VERSION=2.3.1 ~/.rbenv/bin/rbenv exec letsencrypt_webfaction --domains example.com,www.example.com,test.example.com --public ~/webapps/myapp/ --cert_name mycertname
```

Would become this:

```toml
[[certificate]]
domains = [
  "example.com",
  "www.example.com",
  "test.example.com"
]
public = "~/webapps/myapp/"
name = "mycertname"
```

## Replace crontab lines with new single line

Once these are all migrated, run `letsencrypt_webfaction run`. You should see output regarding which certs were issued, updated, or ignored. If this looks satisfactory, remove the existing `letsencrypt_webfaction` lines from your crontab (You edit it by running `crontab -e` on the server), and insert the new line from the readme.
