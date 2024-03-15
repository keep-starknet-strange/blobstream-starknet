#!/bin/bash
#
# Wait for the requested slot value relay to be fulfilled by Herodotus.
# Monitors the Herodotus Fact registry on Starknet for the requested slot values.

# Constants

# Optional arguments
STARKNET_RPC_URL="https://starknet-sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
HERODOTUS_FACT_REGISTRY="0x07d3550237ecf2d6ddef9b78e59b38647ee511467fe000ce276f245a006b40bc"

display_help() {
  echo "Usage: $0 [option...] {arguments...}"
  echo

  echo "   -h, --help                             display help"
  echo "   -s, --starknet-rpc=URL                 URL of the Starknet RPC server (default: $STARKNET_RPC_URL)"
  echo "   -F, --herodotus-fact-registry=ADDRESS  Address of the Herodotus Fact registry on Starknet (default: $HERODOTUS_FACT_REGISTRY)"
  echo
  echo "   -b, --block-number=NUMBER              Block number for the slot fact (required)"
  echo "   -a, --address=ADDRESS                  Address of the contract for the slot fact (required)"
  echo "   -S, --slot=NUMBER                      Slot number for the slot fact (required)"

  echo
  echo "Example: $0"
}

#TODO: Add support for optional arguments
#TODO: Add support for required arguments
#TODO: parse arg formats

# Parse command line arguments
while getopts ":hb:a:S:-:" opt; do
  case ${opt} in
    - )
      case "${OPTARG}" in
        help )
          display_help
          exit 0
          ;;
        block-number )
          BLOCK_NUMBER="${!OPTIND}"
          OPTIND=$((OPTIND + 1))
          ;;
        block-number=* )
          BLOCK_NUMBER="${OPTARG#*=}"
          ;;
        address )
          ADDRESS="${!OPTIND}"
          OPTIND=$((OPTIND + 1))
          ;;
        address=* )
          ADDRESS="${OPTARG#*=}"
          ;;
        slot )
          SLOT="${!OPTIND}"
          OPTIND=$((OPTIND + 1))
          ;;
        slot=* )
          SLOT="${OPTARG#*=}"
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

# Convert block number to 32-byte hex
BLOCK_NUMBER=$(printf "%064x" $BLOCK_NUMBER)
# Get the low and high 16 bytes
BLOCK_NUMBER_HIGH=0x${BLOCK_NUMBER:0:32}
BLOCK_NUMBER_LOW=0x${BLOCK_NUMBER:32:32}

# TODO: allow slots of non hex values
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

#TODO: Compute entry point selector from get_slot_value
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
      "entry_point_selector": "0x01d02b5043fe08831f4d75f1582080c274c6b4d5245fae933747a6990009adff",
      "contract_address": "'$HERODOTUS_FACT_REGISTRY'"
    },
    "pending"
  ]
}'
echo "Query: $HERODOTUS_FACT_QUERY"

echo
echo "Waiting for Herodotus to fulfill the slot fact..."
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

#TODO: verbose, ...
