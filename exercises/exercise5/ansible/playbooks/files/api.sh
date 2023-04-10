#!/bin/bash
apt-get update
echo API - download latest release, install, and start...
mkdir -p /tmp/cloudacademy-app/voteapp-api-go
cd /tmp/cloudacademy-app/voteapp-api-go
curl -sL https://api.github.com/repos/cloudacademy/voteapp-api-go/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url' | xargs curl -OL
INSTALL_FILENAME=$(curl -sL https://api.github.com/repos/cloudacademy/voteapp-api-go/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .name')
tar -xvzf $INSTALL_FILENAME