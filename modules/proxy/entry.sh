#!/bin/bash

export ETH_API_KEY="${ETH_API_KEY:-abc123}"
export ETH_DOMAINNAME="${ETH_DOMAINNAME:-localhost}"
export ETH_EMAIL="${ETH_EMAIL:-noreply@gmail.com}"

echo "Proxy container launched in env:"
echo "ETH_1_HTTP=$ETH_1_HTTP"
echo "ETH_1_WS=$ETH_1_WS"
echo "ETH_2_HTTP=$ETH_2_HTTP"
echo "ETH_API_KEY=$ETH_API_KEY"
echo "ETH_DOMAINNAME=$ETH_DOMAINNAME"
echo "ETH_EMAIL=$ETH_EMAIL"

# Provide a message indicating that we're still waiting for everything to wake up
function loading_msg {
  while true # unix.stackexchange.com/a/37762
  do echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\nWaiting for proxy to wake up" | nc -lk -p 80
  done > /dev/null
}
loading_msg &
loading_pid="$!"

########################################
# Wait for downstream services to wake up
# Define service hostnames & ports we depend on

function waitfor {
  no_proto=${1#*://}
  hostname=${no_proto%/*}
  echo "waiting for $hostname to wake up..."
  wait-for -q -t 60 "$hostname" 2>&1 | sed '/nc: bad address/d'
  while ! curl -s "$1" > /dev/null
  do sleep 2
  done
}

waitfor "$ETH_1_HTTP"
waitfor "$ETH_2_HTTP"

# Kill the loading message server
kill "$loading_pid" && pkill nc

if [[ -z "$ETH_DOMAINNAME" ]]
then
  cp /etc/ssl/cert.pem ca-certs.pem
  echo "Entrypoint finished, executing haproxy in http mode..."; echo
  exec haproxy -db -f http.cfg
fi

########################################
# Setup SSL Certs

letsencrypt=/etc/letsencrypt/live
certsdir=$letsencrypt/$ETH_DOMAINNAME
mkdir -p /etc/haproxy/certs
mkdir -p /var/www/letsencrypt

if [[ "$ETH_DOMAINNAME" == "localhost" && ! -f "$certsdir/privkey.pem" ]]
then
  echo "Developing locally, generating self-signed certs"
  mkdir -p "$certsdir"
  openssl req -x509 -newkey rsa:4096 -keyout "$certsdir/privkey.pem" -out "$certsdir/fullchain.pem" -days 365 -nodes -subj '/CN=localhost'
fi

if [[ ! -f "$certsdir/privkey.pem" ]]
then
  echo "Couldn't find certs for $ETH_DOMAINNAME, using certbot to initialize those now.."
  certbot certonly --standalone -m "$ETH_EMAIL" --agree-tos --no-eff-email -d "$ETH_DOMAINNAME" -n
  code=$?
  if [[ "$code" -ne 0 ]]
  then
    echo "certbot exited with code $code, freezing to debug (and so we don't get throttled)"
    sleep 9999 # FREEZE! Don't pester eff & get throttled
    exit 1;
  fi
fi

echo "Using certs for $ETH_DOMAINNAME"

export ETH_CERTBOT_PORT=31820

function copycerts {
  if [[ -f $certsdir/fullchain.pem && -f $certsdir/privkey.pem ]]
  then cat "$certsdir/fullchain.pem" "$certsdir/privkey.pem" > "$ETH_DOMAINNAME.pem"
  elif [[ -f "$certsdir-0001/fullchain.pem" && -f "$certsdir-0001/privkey.pem" ]]
  then cat "$certsdir-0001/fullchain.pem" "$certsdir-0001/privkey.pem" > "$ETH_DOMAINNAME.pem"
  else
    echo "Couldn't find certs, freezing to debug"
    sleep 9999;
    exit 1
  fi
}

# periodically fork off & see if our certs need to be renewed
function renewcerts {
  sleep 3 # give proxy a sec to wake up before attempting first renewal
  while true
  do
    echo -n "Preparing to renew certs... "
    if [[ -d "$certsdir" ]]
    then
      echo -n "Found certs to renew for $ETH_DOMAINNAME... "
      certbot renew -n --standalone --http-01-port=$ETH_CERTBOT_PORT
      copycerts
      echo "Done!"
    fi
    sleep 48h
  done
}

renewcerts &

copycerts

cp /etc/ssl/cert.pem ca-certs.pem

echo "Entrypoint finished, executing haproxy in https mode..."; echo
exec haproxy -db -f https.cfg
