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
while getopts ":hr:-:" opt; do
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

# TODO : This or latest option for just one proofNonce
#STARKNET_PROOF_NONCE_RES=$(curl $STARKNET_RPC_URL \
#    -X POST \
#    -H "Content-Type: application/json" \
#    -d '{"jsonrpc":"2.0","method":"starknet_getState","params":["'"$BLOBSTREAMX_STARKNET_ADDRESS"'",'"$LATEST_PROOF_NONCE"'],"id":1}' 2>/dev/null)
STARKNET_PROOF_NONCE_RES=$(echo '{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000006a4"}')
STARKNET_PROOF_NONCE=$(echo $STARKNET_PROOF_NONCE_RES | jq -r '.result')
echo "Latest Starknet state_proofNonce: $STARKNET_PROOF_NONCE"

DATA_COMMITMENT_SLOTS=''
# TODO: Think about edge cases
# Loop through each missing state_proofNonce to build the batch query slots
for ((i = STARKNET_PROOF_NONCE; i <= LATEST_PROOF_NONCE - 1; i++)); do
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

echo
echo "Submitting batch query to Herodotus API..."
echo "Query: $HERODOTUS_QUERY"
curl -X 'POST' \
  $HERODOTUS_QUERY_URL \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "$HERODOTUS_QUERY"

#TODO: Wait option
# Wait for state proof nonce slot to be relayed
echo
echo "Waiting for state proof nonce slot $STATE_PROOF_NONCE_SLOT to be relayed..."
$SCRIPT_DIR/wait-for-herodotus-fulfill.sh -b $L1_BLOCK_NUM_DEC -a $BLOBSTREAMX_L1_ADDRESS -S $STATE_PROOF_NONCE_SLOT
# Loop thru each data commitment slot to wait for the data to be relayed (comma separated)
for slot in $(echo $DATA_COMMITMENT_SLOTS | tr ',' '\n' | tr -d '"'); do
  echo
  echo "Waiting for data commitment at slot $slot to be relayed..."
  $SCRIPT_DIR/wait-for-herodotus-fulfill.sh -b $L1_BLOCK_NUM_DEC -a $BLOBSTREAMX_L1_ADDRESS -S $slot
done

#TODO: Herodotus Fact registry mock, cheat code set values, do call to herodotus reg to update state_proofNonce & data commitments and latest l1 block?, PR for verifying attestations, use herodotus to get data commitment and verify attestation from DC
