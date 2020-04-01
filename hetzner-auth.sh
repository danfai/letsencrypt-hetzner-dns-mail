#!/bin/bash

# Author: danfai <dev@danfai.de>
# GitHub: https://github.com/danfai/letsencrypt-hetzner-dns-mail

# required to change
MAIL_FROM="MAIL@DOMAIN.TLD"
HETZNER_USER="KXXXXXXXXXX" # KXXXX
ZONE_FILE=""

# optional parameter
MAIL_SUBJECT="letsencrypt dns challenge"
MAIL_TO="robot@robot.first-ns.de"

GPG_PARAMS=""

#######################################################
## You don't need to change anything after this line ##
#######################################################

# check for applications
which gpg |>/dev/null || echo "ERR: gpg not found, is needed for signing the message to hetzner robot" >&2
which dig |>/dev/null || echo "ERR: dig not found, is needed for checking whether entry is on dns server" >&2
which mail |>/dev/null || echo "ERR: mail not found, unable to send mails" >&2
# maybe we make dig optional and use a long time (2min+)

# check if required variables are changed and gpg can find key
if [ "x$HETZNER_USER" = "xKXXXXXXXXXX" ]
then
	echo "ERR: You need to specify your account number (HETZNER_USER)" >&2
	exit 1
fi
if [ "x$MAIL_FROM" = "xMAIL@DOMAIN.TLD" ]
then
	echo "ERR: You need to specify your mail (MAIL_FROM)" >&2
	exit 1
fi
gpg -K $GPG_PARAMS >/dev/null || (echo "ERR: No private key found" >&2 ; exit 1)
gpg -K $GPG_PARAMS "$MAIL_FROM" >/dev/null || echo "WARN: The mail address is different from the one used to sign the mail." >&2

if [ ! -d /tmp/CERTBOT ];
then
	mkdir -m 0700 /tmp/CERTBOT
fi
TMP_FILE="/tmp/CERTBOT/$CERTBOT_DOMAIN.mail"

cat - >$TMP_FILE <<UPD
user: $HETZNER_USER
job: ns
task: upd
domain: $CERTBOT_DOMAIN
primary: yours
zonefile: /begin
UPD

# append zone file without old acme_challenge
grep -v '_acme-challenge' $ZONE_FILE >> $TMP_FILE
# create new acme_challenge at the end
echo "_acme-challenge 300 IN TXT \"$CERTBOT_VALIDATION\"" >> $TMP_FILE
echo "/end" >> $TMP_FILE

gpg $GPG_PARAMS --detach-sign --armor <$TMP_FILE >>$TMP_FILE

mail -r "$MAIL_FROM" -s "$MAIL_SUBJECT" $MAIL_TO < $TMP_FILE

while true;
do
	sleep 10
	dig @ns1.first-ns.de -t txt "_acme-challenge.$CERTBOT_DOMAIN" +short | \
		grep -q "$CERTBOT_VALIDATION" && break
done
