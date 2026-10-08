#!/bin/bash

# Init.
rcm-yaml init

use ijortengab/rcm rcm-dir
use ijortengab/rcm rcm-file

# Read variable RCM_PROMPT_YAML.
array="$RCM_PROMPT_YAML"
array certbot obtain

# Populate variable cloudflare_token.
for each in "${_return_array[@]}";do
    rcm-yaml append "$each"
done
rcm-yaml find parameter --cloudflare-token then get value
cloudflare_token="$_return_value"

# Make ini file.
path_dir="/usr/local/share/cloudflare-api/credentials"
rcm-dir createIfNotExists "$path_dir"

chapter Create file credentials.
contents="dns_cloudflare_api_token = ${cloudflare_token}"
cloudflare_token_ini=$(grep -Flr "$contents" "$path_dir")
code cloudflare_token_ini=$
if [ -z "$cloudflare_token_ini" ];then
    number=1
    while [[ -e "$path_dir/cloudflare.${number}.ini" ]]; do
        ((number++))
    done
    cloudflare_token_ini="$path_dir/cloudflare.${number}.ini"
    cat << EOF > "$cloudflare_token_ini"
dns_cloudflare_api_token = $cloudflare_token
EOF
    chmod 0600 "$cloudflare_token_ini"
    rcm-file "$cloudflare_token_ini" mustExists
fi
code cloudflare_token_ini=$
____

# Finishing.
RCM_CERTBOT_ARGUMENTS+=(--dns-cloudflare)
RCM_CERTBOT_ARGUMENTS+=("--dns-cloudflare-credentials=${cloudflare_token_ini}")
