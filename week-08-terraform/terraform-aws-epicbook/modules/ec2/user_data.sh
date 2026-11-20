#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/epicbook-userdata.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y git nginx nodejs npm mysql-client

systemctl enable nginx
systemctl start nginx

node -v
npm -v
mysql --version
git --version
echo "EpicBook user data completed"
