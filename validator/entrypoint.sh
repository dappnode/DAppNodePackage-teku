#!/bin/bash

CLIENT="teku"
NETWORK="mainnet"
VALIDATOR_PORT=3500
WEB3SIGNER_API="http://web3signer.web3signer.dappnode:9000"


if [[ "$EXIT_VALIDATOR" == "I want to exit my validators" ]]; then
    echo "Check connectivity with the web3signer"
    WEB3SIGNER_STATUS=$(curl -s  http://web3signer.web3signer.dappnode:9000/healthcheck | jq '.status')
    if [[ "$WEB3SIGNER_STATUS" == '"UP"' ]]; then
    echo "Proceeds to do the voluntary exit of the next keystores:"
    echo "$KEYSTORES_VOLUNTARY_EXIT"
    echo yes | exec /opt/teku/bin/teku voluntary-exit --beacon-node-api-endpoint=http://beacon-chain.teku.dappnode:3500 \
        --validators-external-signer-public-keys=$KEYSTORES_VOLUNTARY_EXIT \
        --validators-external-signer-url=$WEB3SIGNER_API
    else
      echo "The web3signer is not running or the teku package has not access to the web3signer"
    fi
fi


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
  --validators-graffiti="${GRAFFITI}" \
  --validator-api-keystore-file=/cert/teku_client_keystore.p12 \
  --validator-api-keystore-password-file=/cert/teku_keystore_password.txt \
  --validators-proposer-default-fee-recipient="${DEFAULT_FEE_RECIPIENT}" \
  --logging=ALL \
  ${EXTRA_OPTS}
