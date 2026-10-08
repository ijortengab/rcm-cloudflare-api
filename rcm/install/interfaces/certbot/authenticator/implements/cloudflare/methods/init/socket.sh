#!/bin/bash

chapter Variable dump.
____

chapter Mengecek apakah snap certbot-dns-cloudflare installed.
notfound=
code snap list certbot-dns-cloudflare
stdout=$(snap list certbot-dns-cloudflare)
while IFS= read -r line; do e "$line"; _.; done <<< "$stdout"
if grep -q '^certbot-dns-cloudflare\s' <<< "$stdout";then
    __ Snap certbot-dns-cloudflare installed.
else
    __ Snap certbot-dns-cloudflare not found.
    notfound=1
fi
____

if [ -n "$notfound" ];then
    chapter Menginstall snap certbot-dns-cloudflare
    code snap install certbot-dns-cloudflare
    code snap refresh certbot
    snap install certbot-dns-cloudflare
    snap refresh certbot
    ____

    chapter Mengecek apakah snap certbot-dns-cloudflare installed.
    code snap list certbot-dns-cloudflare
    stdout=$(snap list certbot-dns-cloudflare)
    while IFS= read -r line; do e "$line"; _.; done <<< "$stdout"
    if grep -q '^certbot-dns-cloudflare\s' <<< "$stdout";then
        __; green Snap certbot-dns-cloudflare installed.; _.
    else
        __; red Snap certbot-dns-cloudflare not found.; x
    fi
    ____
fi
