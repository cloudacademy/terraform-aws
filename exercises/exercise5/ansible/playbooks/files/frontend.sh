#!/bin/bash
ALB_DNS=$1
echo FRONTEND - download latest release and install...
mkdir -p /tmp/cloudacademy-app/voteapp-frontend-react-2023
cd /tmp/cloudacademy-app/voteapp-frontend-react-2023
curl -sL https://api.github.com/repos/cloudacademy/voteapp-frontend-react-2023/releases/latest | jq -r '.assets[0].browser_download_url' | xargs curl -OL
INSTALL_FILENAME=$(curl -sL https://api.github.com/repos/cloudacademy/voteapp-frontend-react-2023/releases/latest | jq -r '.assets[0].name')
tar -xvzf $INSTALL_FILENAME
rm -rf /var/www/html
cp -R build /var/www/html
cat > /var/www/html/env-config.js << EOFF
window._env_ = {REACT_APP_APIHOSTPORT: "$ALB_DNS"}
EOFF
