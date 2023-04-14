#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n $CHECKPOINT_SYNC_URL ]] && EXTRA_OPTS="--initial-state=$(echo $CHECKPOINT_SYNC_URL | sed 's:/*$::')/eth/v2/debug/beacon/states/finalized ${EXTRA_OPTS}"


case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET in
"geth.dnp.dappnode.eth")
    HTTP_ENGINE="http://geth.dappnode:8551"
    ;;
"nethermind.public.dappnode.eth")
    HTTP_ENGINE="http://nethermind.public.dappnode:8551"
    ;;
"erigon.dnp.dappnode.eth")
    HTTP_ENGINE="http://erigon.dappnode:8551"
    ;;
"besu.public.dappnode.eth")
    HTTP_ENGINE="http://besu.public.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET"
    HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET
    ;;
esac

# MEVBOOST: https://docs.teku.consensys.net/en/latest/HowTo/Builder-Network/
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost.dappnode:18550"
    EXTRA_OPTS="--builder-endpoint=${MEVBOOST_URL} ${EXTRA_OPTS}"
fi

# If EXTRA_OPTS does not include flag --suggested-fee-recipient, append it
if [[ $EXTRA_OPTS != *"validators-proposer-default-fee-recipient"* ]]; then
  echo "Adding --validators-proposer-default-fee-recipient=${FEE_RECIPIENT_ADDRESS} to EXTRA_OPTS"
  EXTRA_OPTS="--validators-proposer-default-fee-recipient=${FEE_RECIPIENT_ADDRESS} ${EXTRA_OPTS}"
fi

exec /opt/teku/bin/teku \
    --network=mainnet \
    --data-base-path=/opt/teku/data \
    --ee-endpoint=$HTTP_ENGINE \
    --ee-jwt-secret-file="/jwtsecret" \
    --p2p-port=$P2P_PORT \
    --rest-api-cors-origins="*" \
    --rest-api-interface=0.0.0.0 \
    --rest-api-port=$BEACON_API_PORT \
    --rest-api-host-allowlist "*" \
    --rest-api-enabled=true \
    --rest-api-docs-enabled=true \
    --metrics-enabled=true \
    --metrics-interface 0.0.0.0 \
    --metrics-port 8008 \
    --metrics-host-allowlist "*" \
    --log-destination=CONSOLE \
    $EXTRA_OPTS
