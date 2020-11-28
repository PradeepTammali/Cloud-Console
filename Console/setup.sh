#!/bin/bash

: '
MIT License

Copyright (c) 2020 Pradeep Tammali

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'

# Keycloak Details
KEYCLOAK="Keycloak URL with port <cloudconsole.keycloak.com:8080>"
REALM="Keycloak REALM"
CLIENT="Keycloak Client"
CLIENT_SECRET="Keycloak Client Secret"
ROOTCA_PEM="Root Certificate for the Keycloak to authenticate with k8s"
K8S_APISERVER="Kubernets Api server URL"

# Color logging
log() {
    # Color Logging
    RED="\033[1;31m"     # ERROR
    GREEN="\033[1;32m"   # INFO
    YELLOW="\033[33;33m" # WARN
    BLUE='\e[0;34m'      # DEBUG
    NOCOLOR="\033[0m"
    ts=$(date "+%Y-%m-%d %H:%M:%S")
    if [[ "$1" == "INFO" ]]; then
        prefix="$ts ${GREEN}INFO: "
    elif [[ "$1" == "ERROR" ]]; then
        prefix="$ts ${RED}ERROR: "
    elif [[ "$1" == "WARN" ]]; then

            prefix="$ts ${YELLOW}WARN: "
    elif [[ "$1" == "DEBUG" ]]; then
        prefix="$ts ${BLUE}DEBUG: "
    else
        prefix="$ts ${GREEN}INFO: "
    fi
    suffix="${NOCOLOR}"
    message="$prefix$2$suffix"
    echo -e "$message" > /dev/null 2>&1
}

_decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -d
}

# $1 => JWT to decode
# $2 => either 1 for header or 2 for body (default is 2)
decode_jwt() { _decode_base64_url $(echo -n $1 | cut -d "." -f ${2:-2}) | jq .; }

create_user() {
        log INFO "Creating user..."
        useradd -u ${2} -m -G cloudconsole -d /home/${1} -s /bin/bash -c "NSC user" ${1} > /dev/null 2>&1
}

# User authentication
auth() {
        log INFO "Authenticating the user..."
        echo -n "Username: "
        read username
        echo -n "Password: "
        read -s password
        log INFO "Authentication user $username with keycloak..."
        RESPONSE=$(curl -sS --location --insecure --request POST "https://${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token" \
                        --header "Content-Type: application/x-www-form-urlencoded" \
                        --data-urlencode "scope=openid" \
                        --data-urlencode "username=${username}" \
                        --data-urlencode "client_secret=${CLIENT_SECRET}" \
                        --data-urlencode "grant_type=password" \
                        --data-urlencode "client_id=${CLIENT}" \
                        --data-urlencode "password=${password}")
        if [[ $(echo ${RESPONSE} | jq -r '.access_token') == 'null' ]]; then
                echo -e "\nInvalid credentials."
                exit 1
        else
                export UNAME=$(decode_jwt $(echo ${RESPONSE} | jq -r '.access_token') | jq -r '.username')
                export USERID=$(decode_jwt $(echo ${RESPONSE} | jq -r '.access_token') | jq -r '.uidNumber')
                # Configuring User kubeconfig
                log INFO "Configuring user ${username} kube token..."
                export ID_TOKEN=$(echo ${RESPONSE} | jq -r '.id_token')
                export REFRESH_TOKEN=$(echo ${RESPONSE} | jq -r '.refresh_token')
                echo -e "\nSuccess."
        fi
}

if [ ! -f /tmp/shell-login ]; then
        cat /etc/issue
        auth
        if id "$UNAME" &>/dev/null; then
                log INFO 'User found, Skipping the creationg of user.'
        else
                log WARN 'User not found, Creating the user.'
                create_user $UNAME $USERID
        fi
        if [ ! -d /home/$UNAME/.kube/ ]; then
                mkdir -p /home/$UNAME/.kube/ > /dev/null 2>&1
                chown -R $UNAME:$UNAME /home/$UNAME/.kube/ > /dev/null 2>&1
        fi
        log INFO "Updating User kubeconfig..."
        cp kubeconfig /home/$UNAME/.kube/config > /dev/null 2>&1
        sed -i -e "s*APISERVER-URL*${K8S_APISERVER}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*USERNAME*${UNAME}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*KEYCLOAK-CLIENT-ID*${CLIENT}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*KEYCLOAK-CLIENT-SECRET*${CLIENT_SECRET}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*USER-ID-TOKEN*${ID_TOKEN}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*ROOTCA-CERT-DATA*${ROOTCA_PEM}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*KEYCLOAK-URL*${KEYCLOAK}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*KEYCLOAK-REALM*${REALM}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        sed -i -e "s*USER-REFRESH-TOKEN*${REFRESH_TOKEN}*g" "/home/$UNAME/.kube/config" > /dev/null 2>&1
        chown -R $UNAME:$UNAME /home/$UNAME/.kube/config > /dev/null 2>&1
        chmod 400 /home/$UNAME/.kube/config > /dev/null 2>&1
        if ! fgrep -qw "PS1='\\u > '" /home/$UNAME/.bashrc; then
            echo "PS1='\u > '" >> /home/$UNAME/.bashrc
        fi
        touch /tmp/shell-login > /dev/null 2>&1
        chown $UNAME:$UNAME /tmp/shell-login
        if ! grep -qw "rm /tmp/shell-login > /dev/null 2>&1" /home/$UNAME/.bashrc; then
            echo "rm /tmp/shell-login > /dev/null 2>&1" >> /home/$UNAME/.bashrc
        fi
        su - $UNAME
fi
exit 0