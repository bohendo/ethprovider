
# Unlock sudo first
sudo true

addr=`echo '{"method":"eth_accounts","params":[],"id":1,"jsonrpc":"2.0"}' | sudo nc -q1 -U /var/lib/docker/volumes/ethprovider_ipc/_data/eth.ipc | jq '.result[0]' | tr -d '"'`

echo "Enter password to unlock eth account $addr (no echo)"
echo -n "> "
read -s password
echo

q='{"method":"personal_unlockAccount","params":["'"$addr"'","'"$password"'","0x12c"],"id":1,"jsonrpc":"2.0"}'

res=`echo $q | sudo nc -q1 -U /var/lib/docker/volumes/ethprovider_ipc/_data/eth.ipc | jq '.result'`

echo "Success: $res"

