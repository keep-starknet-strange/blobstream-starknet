#!/bin/bash
#
# Wait for the requested slot value relay to be fulfilled by Herodotus.
# Monitors the Herodotus Fact registry on Starknet for the requested slot values.

# Constants
HERODOTUS_GET_SLOT_VALUE_SELECTOR="0x01d02b5043fe08831f4d75f1582080c274c6b4d5245fae933747a6990009adff"

# Optional arguments
STARKNET_RPC_URL="https://starknet-sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
HERODOTUS_FACT_REGISTRY="0x07d3550237ecf2d6ddef9b78e59b38647ee511467fe000ce276f245a006b40bc"

VERBOSE=false

display_help() {
  echo "Usage: $0 [option...] {arguments...}"
  echo

  echo "   -s, --starknet-rpc URL                 URL of the Starknet RPC server"
  echo "                                          (default: $STARKNET_RPC_URL)"
  echo "   -F, --herodotus-fact-registry ADDRESS  Address of the Herodotus Fact registry on Starknet"
  echo "                                          (default: $HERODOTUS_FACT_REGISTRY (SN_SEPOLIA))"
  echo
  echo "   -b, --block-number NUMBER              Block number for the slot fact (required)"
  echo "   -a, --address ADDRESS                  Address of the contract for the slot fact (required)"
  echo "   -S, --slot NUMBER                      Slot number for the slot fact - Hex (required)"

  echo
  echo "   -h, --help                             display help"
  echo "   -v, --verbose                          display verbose output"

  echo
  echo "Example: $0"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--starknet-rpc") set -- "$@" "-s" ;;
    "--herodotus-fact-registry") set -- "$@" "-F" ;;
    "--block-number") set -- "$@" "-b" ;;
    "--address") set -- "$@" "-a" ;;
    "--slot") set -- "$@" "-S" ;;
    "--help") set -- "$@" "-h" ;;
    "--verbose") set -- "$@" "-v" ;;
    *) set -- "$@" "$arg"
  esac
done

# Parse command line arguments
while getopts ":hvs:F:b:a:S:" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    v )
      VERBOSE=true
      ;;
    s )
      STARKNET_RPC_URL="${OPTARG}"
      ;;
    F )
      HERODOTUS_FACT_REGISTRY="${OPTARG}"
      ;;
    b )
      BLOCK_NUMBER="${OPTARG}"
      ;;
    a )
      ADDRESS="${OPTARG}"
      ;;
    S )
      SLOT="${OPTARG}"
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

if [ -z $BLOCK_NUMBER ] || [ -z $ADDRESS ] || [ -z $SLOT ]; then
  echo "Missing required arguments: block-number, address, slot" 1>&2
  display_help
  exit 1
fi

# Convert block number to 32-byte hex
BLOCK_NUMBER=$(printf "%064x" $BLOCK_NUMBER)
# Get the low and high 16 bytes
BLOCK_NUMBER_HIGH=0x${BLOCK_NUMBER:0:32}
BLOCK_NUMBER_LOW=0x${BLOCK_NUMBER:32:32}

# Left pad the slot value to 32 bytes
if [[ $SLOT == 0x* ]]; then
  SLOT=${SLOT:2}
fi
while [ ${#SLOT} -lt 64 ]; do
  SLOT="0$SLOT"
done
# Get the low and high 16 bytes
SLOT_HIGH=0x${SLOT:0:32}
SLOT_LOW=0x${SLOT:32:32}

HERODOTUS_FACT_QUERY='{ 
  "id": 1,
  "jsonrpc": "2.0",
  "method": "starknet_call",
  "params": [
    {
      "calldata": [
          "'$ADDRESS'",
          "'$BLOCK_NUMBER_LOW'",
          "'$BLOCK_NUMBER_HIGH'",
          "'$SLOT_LOW'",
          "'$SLOT_HIGH'"
      ],
      "entry_point_selector": "'$HERODOTUS_GET_SLOT_VALUE_SELECTOR'",
      "contract_address": "'$HERODOTUS_FACT_REGISTRY'"
    },
    "pending"
  ]
}'

if [ $VERBOSE == true ]; then
  echo "Query: $HERODOTUS_FACT_QUERY"

  echo
  echo "Waiting for Herodotus to fulfill the slot fact..."
fi

RES='{"jsonrpc":"2.0","id":1,"result":["0x1"]}'
while [ $(echo $RES | jq -r '.result[0]') == "0x1" ]; do
  RES=$(curl $STARKNET_RPC_URL \
    -X 'POST' \
    -H "Content-Type: application/json" \
    -d "$HERODOTUS_FACT_QUERY" 2>/dev/null)
  if [ $(echo $RES | jq -r '.result[0]') == "0x0" ]; then
    VAL_LOW=$(echo $RES | jq -r '.result[1]')
    VAL_HIGH=$(echo $RES | jq -r '.result[2]')
    # Pad and remove 0x prefix
    VAL_LOW=${VAL_LOW:2}
    while [ ${#VAL_LOW} -lt 32 ]; do
      VAL_LOW="0$VAL_LOW"
    done
    VAL_HIGH=${VAL_HIGH:2}
    while [ ${#VAL_HIGH} -lt 32 ]; do
      VAL_HIGH="0$VAL_HIGH"
    done
    VAL="0x$VAL_HIGH$VAL_LOW"
    echo "Slot fact was fulfilled w/ value: $VAL"
    exit 0
  fi
  sleep 5
done
