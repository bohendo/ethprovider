#!/bin/bash

DOMAINNAME=eth.bohendo.com
UPSTREAM=provider

mkdir -p /tmp/proxy

cat - > /tmp/proxy/Dockerfile <<EOF
FROM alpine:3.6
RUN apk add --update --no-cache openssl certbot nginx iputils && \
    openssl dhparam -out /etc/ssl/dhparam.pem 2048 && \
    ln -fs /dev/stdout /var/log/nginx/access.log && \
    ln -fs /dev/stderr /var/log/nginx/error.log
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entry.sh /root/entry.sh
ENTRYPOINT ["sh", "/root/entry.sh"]
EOF

cat - > /tmp/proxy/entry.sh <<EOF
#!/bin/sh
env

devcerts=/etc/letsencrypt/devcerts

mkdir -p \$devcerts
mkdir -p /etc/certs
mkdir -p /var/www/letsencrypt

# Wait for dependencies to come alive
while true
do
  ping -c1 -w1 $UPSTREAM > /dev/null 2> /dev/null
  if [ "\$?" != "0" ]
  then
    echo "Waiting for $UPSTREAM to come alive.."
    sleep 5
    continue
  fi
  echo "$UPSTREAM is awake, let's go!"
  break
done

if [[ -f "/etc/letsencrypt/live/$DOMAINNAME/privkey.pem" ]]
then
  echo "Found letsencrypt certs for $DOMAINNAME, using those"
  ln -sf /etc/letsencrypt/live/$DOMAINNAME/privkey.pem /etc/certs/privkey.pem
  ln -sf /etc/letsencrypt/live/$DOMAINNAME/fullchain.pem /etc/certs/fullchain.pem

elif [[ "$DOMAINNAME" == "localhost" ]]
then
  echo "Developing locally, using self-signed certs"
  if [[ ! -f "\$devcerts/site.crt" ]]
  then
    openssl req -x509 -newkey rsa:4096 -keyout \$devcerts/site.key -out \$devcerts/site.crt -days 365 -nodes -subj '/CN=localhost'
  fi
  ln -sf \$devcerts/site.key /etc/certs/privkey.pem
  ln -sf \$devcerts/site.crt /etc/certs/fullchain.pem

else
  echo "Couldn't find certs for $DOMAINNAME, using certbot to initialize those now.."
  certbot certonly --standalone -m $EMAIL --agree-tos --no-eff-email -d $DOMAINNAME -n
  [ \$? -eq 0 ] || sleep 9999 # FREEZE! Don't pester eff so much we get throttled
  ln -sf /etc/letsencrypt/live/$DOMAINNAME/privkey.pem /etc/certs/privkey.pem
  ln -sf /etc/letsencrypt/live/$DOMAINNAME/fullchain.pem /etc/certs/fullchain.pem
  echo "Done initializing certs, starting nginx..."
fi

# periodically fork off & see if our certs need to be renewed
renewcerts() {
  while true
  do
    echo -n "Preparing to renew certs... "
    if [[ -d "/etc/letsencrypt/live/$DOMAINNAME" ]]
    then
      echo -n "Found certs to renew for $DOMAINNAME... "
      certbot renew --webroot -w /var/www/letsencrypt/ -n
      echo "Done!"
    fi
    sleep 48h
  done
}
renewcerts &

sleep 3 # give renewcerts a sec to do it's first check
echo "Entrypoint finished, executing nginx..."; echo
exec nginx
EOF


cat - > /tmp/proxy/nginx.conf <<EOF
daemon off;
user nginx;
pid /run/nginx.pid;
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    ####################
    # HTTP server configuration
    server {
        listen 80;
        server_name $DOMAINNAME;
        location /.well-known/acme-challenge/ {
            root /var/www/letsencrypt/;
        }
        location / {
            return 301 https://\$host\$request_uri;
        }
    }

    ####################
    # HTTPS server configuration
    server {
        listen 443 ssl;
        server_name $DOMAINNAME;

        ssl_dhparam         /etc/ssl/dhparam.pem;
        ssl_certificate     /etc/certs/fullchain.pem;
        ssl_certificate_key /etc/certs/privkey.pem;

        ssl_session_cache shared:le_nginx_SSL:1m;
        ssl_session_timeout 1440m;
        ssl_protocols TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        ssl_ecdh_curve secp384r1;

        location / {
            proxy_pass http://$UPSTREAM:8080;
            proxy_redirect off;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host \$server_name;
        }
    }
}
EOF

docker build -f /tmp/proxy/Dockerfile -t eth_proxy /tmp/proxy
rm -rf /tmp/proxy



