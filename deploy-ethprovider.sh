r!/bin/bash
set -e

########################################
## Config

if [[ "$1" == "geth" ]]
then provider="geth"
else provider="parity"
fi

me=`whoami`
domain="eth.bohendo.com"
email="noreply@example.com"

cache="4096"
http_port="8545"
ws_port="8546"
data_dir="/root/eth"

########################################
## Build Provider

image="$name_$provider:latest"
tmp="/tmp/$name"
mkdir -p $tmp

cat - > $tmp/parity.Dockerfile <<EOF
FROM ubuntu:16.04
RUN apt-get update -y && apt-get install -y bash sudo curl
RUN curl https://get.parity.io -Lk > /tmp/get-parity.sh && bash /tmp/get-parity.sh # v2.0.1
ENTRYPOINT ["/usr/bin/parity"]
CMD [ \
  "--identity=$me", \
  "--base-path=$data_dir", \
  "--auto-update=all", \
  "--cache-size=$cache", \
  "--no-secretstore", \
  "--no-hardware-wallets", \
  "--jsonrpc-port=$http_port", \
  "--jsonrpc-interface=all", \
  "--jsonrpc-apis=safe", \
  "--jsonrpc-hosts=all", \
  "--jsonrpc-cors=all", \
  "--ws-port=$ws_port", \
  "--ws-interface=all", \
  "--ws-apis=safe", \
  "--ws-origins=all", \
  "--ws-hosts=all", \
  "--no-ipc", \
  "--whisper", \
  "--whisper-pool-size=128" \
]
EOF

cat - > $tmp/geth.Dockerfile <<EOF
FROM ethereum/client-go:v1.8.13 as base
FROM alpine:latest
COPY --from=base /usr/local/bin/geth /usr/local/bin
RUN apk add --no-cache ca-certificates && mkdir /root/eth && mkdir /tmp/ipc
ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ \
  "--identity=$me", \
  "--datadir=$data_dir", \
  "--lightserv=50", \
  "--nousb", \
  "--cache=$cache", \
  "--rpc", \
  "--rpcaddr=0.0.0.0", \
  "--rpcport=$http_port", \
  "--rpcapi=safe", \
  "--rpccorsdomain=*", \
  "--rpcvhosts=*", \
  "--ws", \
  "--wsaddr=0.0.0.0", \
  "--wsport=$ws_port", \
  "--wsapi=safe", \
  "--wsorigins=*", \
  "--ipcdisable", \
  "--shh" \
]
EOF

docker build -f $tmp/$provider.Dockerfile -t $provider_image $tmp/
rm -rf $tmp

########################################
## Build Proxy

proxy_image="eth_proxy:latest"
tmp="/tmp/eth_proxy"
mkdir -p $tmp

devcerts=/etc/letsencrypt/devcerts

cat - > $tmp/entry.sh <<EOF
#!/bin/sh
env
mkdir -p $devcerts
mkdir -p /etc/certs
mkdir -p /var/www/letsencrypt
# Wait for dependencies to come alive
while true
do
  ping -c1 -w1 provider > /dev/null 2> /dev/null
  if [ "\$?" != "0" ]
  then
    echo "Waiting for provider to come alive.."
    sleep 5
    continue
  fi
  echo "provider is awake, let's go!"
  break
done

if [[ -f "/etc/letsencrypt/live/$domain/privkey.pem" ]]
then
  echo "Found letsencrypt certs for $domain, using those"
  ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/certs/privkey.pem
  ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/certs/fullchain.pem
elif [[ "$domain" == "localhost" ]]
then
  echo "Developing locally, using self-signed certs"
  if [[ ! -f "$devcerts/site.crt" ]]
  then
    openssl req -x509 -newkey rsa:4096 -keyout $devcerts/site.key -out $devcerts/site.crt -days 365 -nodes -subj '/CN=localhost'
  fi
  ln -sf $devcerts/site.key /etc/certs/privkey.pem
  ln -sf $devcerts/site.crt /etc/certs/fullchain.pem
else
  echo "Couldn't find certs for $domain, using certbot to initialize those now.."
  certbot certonly --standalone -m $email --agree-tos --no-eff-email -d $domain -n
  [ \$? -eq 0 ] || sleep 9999 # FREEZE! Don't pester eff so much we get throttled
  ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/certs/privkey.pem
  ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/certs/fullchain.pem
  echo "Done initializing certs, starting nginx..."
fi

# periodically fork off & see if our certs need to be renewed
renewcerts() {
  while true
  do
    echo -n "Preparing to renew certs... "
    if [[ -d "/etc/letsencrypt/live/$domain" ]]
    then
      echo -n "Found certs to renew for $domain... "
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

cat - > $tmp/nginx.conf <<EOF
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
        server_name $domain;
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
        server_name $domain;
        ssl_dhparam         /etc/ssl/dhparam.pem;
        ssl_certificate     /etc/certs/fullchain.pem;
        ssl_certificate_key /etc/certs/privkey.pem;
        ssl_session_cache shared:le_nginx_SSL:1m;
        ssl_session_timeout 1440m;
        ssl_protocols TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        ssl_ecdh_curve secp384r1;

        location /http {
            proxy_pass http://provider:8545;
            proxy_redirect off;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host \$server_name;
        }

        location /ws {
            proxy_pass http://provider:8546;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$connection_upgrade;
        }
    }
}
EOF

cat - > $tmp/Dockerfile <<EOF
FROM alpine:3.6
RUN apk add --update --no-cache openssl certbot nginx iputils && \
    openssl dhparam -out /etc/ssl/dhparam.pem 2048 && \
    ln -fs /dev/stdout /var/log/nginx/access.log && \
    ln -fs /dev/stderr /var/log/nginx/error.log
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entry.sh /root/entry.sh
ENTRYPOINT ["sh", "/root/entry.sh"]
EOF

docker build -f $tmp/Dockerfile -t $proxy_image $tmp/
rm -rf $tmp

########################################
## Deploy

tmp=/tmp/ethprovider

cat - > $tmp/docker-compose.yml <<EOF
version: '3.4'

volumes:
  letsencrypt:
  devcerts:
  chaindata:

services:

  provider:
    image: $provider_image
    deploy:
      mode: global
    volumes:
      - ${provider}_chaindata:$data_dir
    ports:
      - "30303:30303"

  proxy:
    image: $proxy_image
    deploy:
      mode: global
    depends_on:
      - provider
    volumes:
      - devcerts:/etc/devcerts
      - letsencrypt:/etc/letsencrypt
    ports:
      - "80:80"
      - "443:443"
EOF

docker stack deploy $tmp/docker-compose.yml eth
rm -rf $tmp
