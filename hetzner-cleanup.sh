#!/bin/bash

# Author: danfai <dev@danfai.de>
# GitHub: https://github.com/danfai/letsencrypt-hetzner-dns-mail

TMP_FILE="/tmp/CERTBOT/$CERTBOT_DOMAIN.mail"

rm "$TMP_FILE"
