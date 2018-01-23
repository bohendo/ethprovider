v=latest # tweak to deploy a specific version number
me=`whoami` # your docker.io username

mkdir -p /tmp/ethprovider

cat - > /tmp/ethprovider/Dockerfile <<EOF
FROM ethereum/client-go:stable as base

ENTRYPOINT ["/usr/local/bin/geth"]
CMD [ \
  "--identity=$me", \
  "--datadir=/root/eth", \
  "--ipcpath=/tmp/ipc/eth.ipc", \
  "--keystore=/run/secrets", \
  "--cache=8192" \
]
EOF

docker build -f /tmp/ethprovider/Dockerfile -t $me/ethprovider:$v -t ethprovider:$v /tmp/ethprovider

docker push $me/ethprovider:$v

rm /tmp/ethprovider/Dockerfile
