#!/bin/bash
# dowload
cd /tmp
LATEST_TAG=$(curl -sL https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name)
VERSION=$(echo $LATEST_TAG | grep -Eo "(\d+\.)+\d+")
curl -OL https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_darwin_amd64.zip

# install
unzip terraform_${VERSION}_darwin_amd64.zip
mv terraform /usr/local/bin/

# autocompletion
terraform -install-autocomplete
terraform version
