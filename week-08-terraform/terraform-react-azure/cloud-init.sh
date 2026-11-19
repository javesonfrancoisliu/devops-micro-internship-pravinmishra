#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/react-deploy.log) 2>&1

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export CI=false

APP_USER=azureuser
APP_DIR=/home/${APP_USER}/my-react-app
WEB_ROOT=/var/www/my-react-app
DEPLOY_DATE=$(date +%d/%m/%Y)

apt-get update -y
apt-get install -y git nodejs npm nginx

git clone https://github.com/pravinmishraaws/my-react-app.git "${APP_DIR}"
cd "${APP_DIR}"

sed -i 's|Your Full Name|Javeson Francois Liu|' src/App.js
sed -i "s|DD/MM/YYYY|${DEPLOY_DATE}|" src/App.js

npm install
npm run build

mkdir -p "${WEB_ROOT}"
cp -r build/. "${WEB_ROOT}/"
chown -R www-data:www-data "${WEB_ROOT}"
chown -R ${APP_USER}:${APP_USER} "${APP_DIR}"

cat > /etc/nginx/sites-available/my-react-app <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root ${WEB_ROOT};
    index index.html;

    location / {
        try_files \$uri /index.html;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/my-react-app /etc/nginx/sites-enabled/my-react-app
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "React deployment completed"
