#!/bin/bash

cat -> /root/.lighthouse/mainnet/validators/validator_definitions.yml <<EOF
---
- enabled: true
  voting_public_key: "$ETH_VALIDATOR_PUBKEY"
  type: local_keystore
  voting_keystore_path: /root/keystore.json
  voting_keystore_password_path: /run/secrets/validator_keystore_password
EOF

exec lighthouse --network mainnet beacon --http --http-address=0.0.0.0
