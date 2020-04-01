Letsencrypt Hetzner DNS Verification
== 
This script lets you create and renew certificates for letsencrypt with the dns authenticator for domains hosted with Hetzner DNS over their mail API.

Ideally you want this script to be executed on a machine where no user has access (not your webserver) and later transmit the files to your server.

## Requirements/Install
You need to specify a public gpg key in Hetzner [robot.your-server.de|robot]. The matching private key is used to sign your mail for the DNS change request and needs to be configured in the gpg keyring for the user sending the mail.
To create a pair you can use (replace `MAIL_FROM`):
`gpg --batch --passphrase ''  --quick-generate-key "MAIL_FROM <MAIL_FROM>"`

This will print the public key to be specified in Hetzner robot.
`gpg --export --armor MAIL_FROM`

Additionally you need to specify the file for your basic DNS zone in hetzner-auth.sh `ZONE_FILE`. You may want to get an initial one from the robot. 

This script runs on Linux systems and uses the following utilities:
`dig mail gpg`

It is expected that your server has a working configuration for sending mails.

## Usage:
Specify this script in your letsencrypt config either in the cli file or similary as commandline parameter:
```
authenticator = manual
preferred-challenges = dns
manual_auth_hook = /root/dns-letsencrypt-challenge/hetzner-auth.sh
manual_public_ip_logging_ok = True
server = https://acme-v02.api.letsencrypt.org/directory
#manual-cleanup-hook = /root/dns-letsencrypt-challenge/hetzner-cleanup.sh
```

## Security
* Make sure to secure your private GPG key that no one else can change your DNS entries and domains!

As information, but most people do not need to change anything:
* This script needs to be able to send a mail and communicate with the hetzner DNS server (ns1.first-ns.de)
* There is a temporary file containing the zone file accessible for the user in /tmp/CERTBOT.

## Parameters
You can specify another user to mail the DNS change request to, additionally to Hetzner robot, for monitoring. Use the `MAIL_TO` variable in the hetzner-auth.sh
| Parameter | Description |
| --- | --- |
|`MAIL_FROM`|The mail address the mail is sent from. You should have control over this mail.|
|`HETZNER_USER`|Your account number at hetzner. Should be something like KNNNNNNNNNN where N is a decimal digit.|
|`ZONE_FILE`|The file with the basic zone configuration for the dns file.|
|||
|`MAIL_SUBJECT`|The subject of the mail. Does not really matter, but might be helpful to be changed if you want to send a copy of the mails to you or a monitoring software.|
|`MAIL_TO`|Here you can specify additional users that should receive the DNS change API requests. robot@robot.first-ns.de is required, additional mails can be specified with whitespaces between adresses.|
|`GPG_PARAMS`|If you want to specify any parameters for the gpg call, this si the variable. Maybe you want to specify the location of the key or keyring...|

## References
Another tool, that uses the HTTPs interface of Hetzner to modify the zone: https://github.com/macskay/hetzner-letsencrypt-wildcard-auto-renew 

[https://wiki.hetzner.de/index.php/E-Mail-Schnittstelle_Domain_Registration_Robot/en|Description of the API at wiki.hetzner.de]
