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
L1_RPC_URL="https://sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
STARKNET_RPC_URL="https://starknet-sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
BLOBSTREAMX_L1_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"
#TODO : Change address to the Sepolia address once it is deployed
BLOBSTREAMX_STARKNET_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"

NO_SEND=false
VERBOSE=false
WAIT=true


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORK_DIR=$SCRIPT_DIR/..

display_help() {
  echo "Usage: $0 [option...] {arguments...}"
  echo

  echo "   -b, --blobstreamx-l1 ADDR        BlobstreamX contract address on L1"
  echo "                                    (default: $BLOBSTREAMX_L1_ADDRESS (SEPOLIA))"
  echo "   -B, --blobstreamx-starknet ADDR  BlobstreamX contract address on Starknet"
  echo "                                    (default: $BLOBSTREAMX_STARKNET_ADDRESS (SEPOLIA))"
  echo "   -r, --l1-rpc URL                 URL of the L1 RPC server"
  echo "                                    (default: $L1_RPC_URL)"
  echo "   -s, --starknet-rpc URL           URL of the Starknet RPC server"
  echo "                                    (default: $STARKNET_RPC_URL)"

  echo
  echo "   -h, --help                       display help"
  echo "   -n, --no-send                    Do not send the batch query to Herodotus, only print the query"
  echo "   -N, --no-wait                    Do not wait for the state proof nonce and data commitments to be relayed"
  echo "   -v, --verbose                    verbose output"

  echo
  echo "Example: $0"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--blobstreamx-l1") set -- "$@" "-b" ;;
    "--blobstreamx-starknet") set -- "$@" "-B" ;;
    "--l1-rpc") set -- "$@" "-r" ;;
    "--starknet-rpc") set -- "$@" "-s" ;;
    "--help") set -- "$@" "-h" ;;
    "--no-send") set -- "$@" "-n" ;;
    "--no-wait") set -- "$@" "-N" ;;
    "--verbose") set -- "$@" "-v" ;;
    *) set -- "$@" "$arg"
  esac
done

# Parse command line arguments
while getopts ":hnvNb:B:r:s:-:" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    n )
      NO_SEND=true
      ;;
    v )
      VERBOSE=true
      ;;
    N )
      WAIT=false
      ;;
    b )
      BLOBSTREAMX_L1_ADDRESS="$OPTARG"
      ;;
    B )
      BLOBSTREAMX_STARKNET_ADDRESS="$OPTARG"
      ;;
    r )
      L1_RPC_URL="$OPTARG"
      ;;
    s )
      STARKNET_RPC_URL="$OPTARG"
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

# Check if HERODOTUS_API_KEY is set if not set and no-send is not set, exit
if [ -z "$HERODOTUS_API_KEY" ] && [ "$NO_SEND" = false ]; then
  echo "HERODOTUS_API_KEY is not set. Get your API key from https://dashboard.herodotus.dev by signing up with your GitHub."
  exit 1
fi

L1_BLOCK_NUM_RES=$(curl $L1_RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null)
L1_BLOCK_NUM=$(echo $L1_BLOCK_NUM_RES | jq -r '.result')

LATEST_PROOF_NONCE_RES=$(curl $L1_RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_getStorageAt","params":["'"$BLOBSTREAMX_L1_ADDRESS"'","'"$STATE_PROOF_NONCE_SLOT"'","'"$L1_BLOCK_NUM"'"],"id":1}' 2>/dev/null)
LATEST_PROOF_NONCE=$(echo $LATEST_PROOF_NONCE_RES | jq -r '.result')

#TODO: Do a call to get_state_proof_nonce() once the function is deployed & replace hardcoded
#STARKNET_PROOF_NONCE_RES=$(curl $STARKNET_RPC_URL \
#    -X POST \
#    -H "Content-Type: application/json" \
#    -d '{"jsonrpc":"2.0","method":"starknet_getState","params":["'"$BLOBSTREAMX_STARKNET_ADDRESS"'",'"$LATEST_PROOF_NONCE"'],"id":1}' 2>/dev/null)
#TODO: Remove the hardcoded value once the blobstreamx contract is deployed on Starknet
#STARKNET_PROOF_NONCE_RES=$(echo '{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000006cb"}')
#STARKNET_PROOF_NONCE=$(echo $STARKNET_PROOF_NONCE_RES | jq -r '.result')
STARKNET_PROOF_NONCE=$((LATEST_PROOF_NONCE - 4))

if [ "$VERBOSE" = true ]; then
  echo "Latest L1 block number: $L1_BLOCK_NUM"
  echo "Latest L1 state_proofNonce: $LATEST_PROOF_NONCE"
  echo "Latest Starknet state_proofNonce: $STARKNET_PROOF_NONCE"
fi

DATA_COMMITMENT_SLOTS=''
# Loop through each missing state_proofNonce to build the batch query slots
for ((i = $STARKNET_PROOF_NONCE; i <= LATEST_PROOF_NONCE - 1; i++)); do
  # Data commitment slot for each proofNonce is located at
  # keccak256(abi.encode(proofNonce, STATE_DATA_COMMITMENT_MAP_SLOT))
  DATA_COMMITMENT_ENCODED_SLOT=$(printf "%064x%064x" $i $STATE_DATA_COMMITMENT_MAP_SLOT)
  DATA_COMMITMENT_SLOT=$(echo $DATA_COMMITMENT_ENCODED_SLOT | keccak-256sum -x -l | awk '{print $1}')
  
  if [ -z "$DATA_COMMITMENT_SLOTS" ]; then
    DATA_COMMITMENT_SLOTS='"0x'$DATA_COMMITMENT_SLOT'"'
  else
    DATA_COMMITMENT_SLOTS=$DATA_COMMITMENT_SLOTS',"0x'$DATA_COMMITMENT_SLOT'"'
  fi
done

if [ -z "$DATA_COMMITMENT_SLOTS" ]; then
  echo "No missing data commitments found."
  exit 0
fi

# Convert L1 Block number from hex to decimal
L1_BLOCK_NUM_DEC=$(printf "%d" $L1_BLOCK_NUM)
HERODOTUS_QUERY='{
  "destinationChainId": "'$BLOBSTREAMX_DESTINATION_CHAIN_ID'",
  "fee": "0",
  "data": {
    "'$BLOBSTREAMX_SOURCE_CHAIN_ID'": {
      "block:'$L1_BLOCK_NUM_DEC'": {
        "header": [
          "PARENT_HASH"
        ],
        "accounts": {
          "'$BLOBSTREAMX_L1_ADDRESS'": {
            "slots": [
              "'$STATE_PROOF_NONCE_SLOT'",
              '$DATA_COMMITMENT_SLOTS'
            ],
            "props": []
          }
        }
      }
    }
  },
  "webhook": {
    "url": "https://webhook.site/1f3a9b5d-5c8c-4e2a-9d7e-6c3c5a0a0e2f",
    "headers": {
      "Content-Type": "application/json"
    }
  }
}'
# Clean up the query formatting for readability
HERODOTUS_QUERY=$(echo $HERODOTUS_QUERY | jq '.')
HERODOTUS_QUERY_URL=$(echo $HERODOTUS_API_URL | sed 's/\/$//')'/submit-batch-query?apiKey='$HERODOTUS_API_KEY

if [ "$VERBOSE" = true ] || [ "$NO_SEND" = true ]; then
  echo
  echo "Batch query to Herodotus API:"
  echo "$HERODOTUS_QUERY"
fi

if [ "$NO_SEND" = true ]; then
  exit 0
fi

echo
echo "Submitting batch query to Herodotus API..."
HERODOTUS_ID=$(curl -X 'POST' \
  $HERODOTUS_QUERY_URL \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "$HERODOTUS_QUERY" 2>/dev/null)
echo "Batch query submitted. Herodotus Internal ID: $HERODOTUS_ID"

if [ "$WAIT" = false ]; then
  echo
  echo "Query fulfillment can take some time, please wait for state proof nonce and data commitments to be relayed."
  exit 0
fi

# Wait for state proof nonce slot to be relayed
echo
echo "Waiting for state proof nonce slot $STATE_PROOF_NONCE_SLOT to be relayed..."
$SCRIPT_DIR/wait-for-herodotus-fulfill.sh -b $L1_BLOCK_NUM_DEC -a $BLOBSTREAMX_L1_ADDRESS -S $STATE_PROOF_NONCE_SLOT $([ "$VERBOSE" = true ] && echo "-v")
# Loop thru each data commitment slot to wait for the data to be relayed (comma separated)
for slot in $(echo $DATA_COMMITMENT_SLOTS | tr ',' '\n' | tr -d '"'); do
  echo
  echo "Waiting for data commitment at slot $slot to be relayed..."
  $SCRIPT_DIR/wait-for-herodotus-fulfill.sh -b $L1_BLOCK_NUM_DEC -a $BLOBSTREAMX_L1_ADDRESS -S $slot $([ "$VERBOSE" = true ] && echo "-v")
done
