#!/bin/bash
#
# Request relay of the latest BlobstreamX data commitments from L1 to Starknet
# Uses the Herodotus API to submit a batch query for all data commitments
# up to the latest state_proofNonce

# Constants
HERODOTUS_API_URL="https://api.herodotus.cloud/"
BLOBSTREAMX_SOURCE_CHAIN_ID="11155111"
BLOBSTREAMX_DESTINATION_CHAIN_ID="SN_SEPOLIA"
STATE_PROOF_NONCE_SLOT="0x00000000000000000000000000000000000000000000000000000000000000fc"
STATE_DATA_COMMITMENT_MAP_SLOT="0x00000000000000000000000000000000000000000000000000000000000000fe"

# Optional arguments
# TODO: To public api?
L1_RPC_URL="https://sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
STARKNET_RPC_URL="https://starknet-sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
BLOBSTREAMX_L1_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"
#TODO
BLOBSTREAMX_STARKNET_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORK_DIR=$SCRIPT_DIR/..

#TODO: w/o webhook, verbose, w/o header access
#TODO: resume from id 

display_help() {
  echo "Usage: $0 [option...] {arguments...}"
  echo

  echo "   -h, --help                       display help"
  echo "   -r, --l1-rpc=URL                 URL of the L1 RPC server (default: $L1_RPC_URL)"
  echo "   -s, --starknet-rpc=URL           URL of the Starknet RPC server (default: $STARKNET_RPC_URL)"
  echo "   -b, --blobstreamx-l1=ADDR        BlobstreamX contract address on L1 (default: $BLOBSTREAMX_L1_ADDRESS)"
  echo "   -B, --blobstreamx-starknet=ADDR  BlobstreamX contract address on Starknet (default: $BLOBSTREAMX_STARKNET_ADDRESS)"

  echo
  echo "Example: $0"
}

#TODO: Add support for optional arguments

# Parse command line arguments
while getopts ":hp:-:" opt; do
  case ${opt} in
    - )
      case "${OPTARG}" in
        help )
          display_help
          exit 0
          ;;
        * )
          echo "Invalid option: --$OPTARG" 1>&2
          display_help
          exit 1
          ;;
      esac
      ;;
    h )
      display_help
      exit 0
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      display_help
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      display_help
      exit 1
      ;;
  esac
done

if [ -z "$HERODOTUS_API_KEY" ]; then
  echo "HERODOTUS_API_KEY is not set. Get your API key from https://dashboard.herodotus.dev by signing up with your GitHub."
  exit 1
fi

L1_BLOCK_NUM_RES=$(curl $L1_RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null)
L1_BLOCK_NUM=$(echo $L1_BLOCK_NUM_RES | jq -r '.result')
echo "Latest L1 block number: $L1_BLOCK_NUM"

# echo
# echo "Getting current Starknet block number..."
# curl $STARKNET_RPC_URL \
#     -X POST \
#     -H "Content-Type: application/json" \
#     -d '{"jsonrpc":"2.0","method":"starknet_blockNumber","params":[],"id":1}'

LATEST_PROOF_NONCE_RES=$(curl $L1_RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_getStorageAt","params":["'"$BLOBSTREAMX_L1_ADDRESS"'","'"$STATE_PROOF_NONCE_SLOT"'","latest"],"id":1}' 2>/dev/null)
LATEST_PROOF_NONCE=$(echo $LATEST_PROOF_NONCE_RES | jq -r '.result')
echo "Latest L1 state_proofNonce: $LATEST_PROOF_NONCE"
