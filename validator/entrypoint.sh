#!/bin/bash

NETWORK="mainnet"
VALIDATOR_PORT=3500
WEB3SIGNER_API="http://web3signer.web3signer.dappnode:9000"

# MEVBOOST: https://docs.teku.consensys.net/en/latest/HowTo/Builder-Network/
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost.dappnode:18550"
    EXTRA_OPTS="--validators-builder-registration-default-enabled=true ${EXTRA_OPTS}"

  # If validator does not include flag --validators-proposer-blinded-blocks-enabled, append it to EXTRA_OPTS
  if [[ $EXTRA_OPTS != *"validators-proposer-blinded-blocks-enabled"* ]]; then
    EXTRA_OPTS="--validators-proposer-blinded-blocks-enabled=true ${EXTRA_OPTS}"
  fi
fi

#Handle Graffiti Character Limit
oLang=$LANG oLcAll=$LC_ALL
LANG=C LC_ALL=C 
graffitiString=${GRAFFITI:0:32}
LANG=$oLang LC_ALL=$oLcAll

# Teku must start with the current env due to JAVA_HOME var
exec /opt/teku/bin/teku --log-destination=CONSOLE \
  validator-client \
  --network=${NETWORK} \
  --data-base-path=/opt/teku/data \
  --beacon-node-api-endpoint="$BEACON_NODE_ADDR" \
  --validators-external-signer-url="$WEB3SIGNER_API" \
  --metrics-enabled=true \
  --metrics-interface 0.0.0.0 \
  --metrics-port 8008 \
  --metrics-host-allowlist=* \
  --validator-api-enabled=true \
  --validator-api-interface=0.0.0.0 \
  --validator-api-port="$VALIDATOR_PORT" \
  --validator-api-host-allowlist=* \
  --validators-graffiti="${graffitiString}" \
  --validator-api-keystore-file=/cert/teku_client_keystore.p12 \
  --validator-api-keystore-password-file=/cert/teku_keystore_password.txt \
  --validators-proposer-default-fee-recipient="${FEE_RECIPIENT_ADDRESS}" \
  --logging="${LOG_TYPE}" \
  ${EXTRA_OPTS}
