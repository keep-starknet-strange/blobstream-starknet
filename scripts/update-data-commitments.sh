#!/bin/bash

PROJECT_ROOT=`git rev-parse --show-toplevel`

# Load env variable from `.env` only if they're not already set
if [ -z "$STARKNET_KEYSTORE" ] || [ -z "$STARKNET_ACCOUNT" ]; then
  source $PROJECT_ROOT/.env
fi

# Check if required env variables are set, if not exit
if [ -z "$STARKNET_KEYSTORE" ]; then
  echo "Error: STARKNET_KEYSTORE is not set."
  exit 1
elif [ -z "$STARKNET_ACCOUNT" ]; then
  echo "Error: STARKNET_ACCOUNT is not set."
  exit 1
fi

# Constants
BLOBSTREAMX_STARKNET_ADDRESS="0x04179fb9990b3c7e44de802c4e40c8f395862d79a8c5eaa7340d999a5c1f625d"
HERODOTUS_FACTS_REGISTRY_ADDRESS="0x07d3550237ecf2d6ddef9b78e59b38647ee511467fe000ce276f245a006b40bc"
MAX_FEE="none"

display_help() {
  echo "Usage: $0 [option...]"
  echo
  echo "   -n, --block-number U256       L1 block number"
  echo "                                 (required)"
  
  echo
  echo "   -B, --blobstreamx-starknet ADDR  BlobstreamX contract address on Starknet"
  echo "                                    (default: $BLOBSTREAMX_STARKNET_ADDRESS (SEPOLIA))"
  echo "   -m, --max-fee ETH                Max fee"
  echo "                                    (default: estimated automatically)"
  
  echo
  echo "   -h, --help                    display help"
  echo "   -v, --verbose                 verbose output"
  echo
  echo "Example: $0 --block-number 123456"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--block-number") set -- "$@" "-n" ;;
    "--blobstreamx-starknet") set -- "$@" "-B" ;;
    "--max-fee") set -- "$@" "-m" ;;
    "--help") set -- "$@" "-h" ;;
    "--verbose") set -- "$@" "-v" ;;
    *) set -- "$@" "$arg"
  esac
done

# Parse command line arguments
while getopts ":hvn:B:m:-:" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    v )
      VERBOSE=true
      ;;
    n )
      L1_BLOCK_NUMBER="$OPTARG"
      ;;
    B )
      BLOBSTREAMX_STARKNET_ADDRESS="$OPTARG"
      ;;
    m )
      MAX_FEE="$OPTARG"
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

# Check if required options are set, if not exit
if [ -z "$L1_BLOCK_NUMBER" ]; then
  echo "Error: missing required option --block-number"
  exit 1
fi

if [ "$MAX_FEE" = "none" ]; then
    COMMAND="starkli invoke --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $BLOBSTREAMX_STARKNET_ADDRESS update_data_commitments_from_facts u256:$L1_BLOCK_NUMBER"
else
    COMMAND="starkli invoke --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --max-fee $MAX_FEE --watch $BLOBSTREAMX_STARKNET_ADDRESS update_data_commitments_from_facts u256:$L1_BLOCK_NUMBER"
fi

# Call the update_data_commitments_from_facts function
if [ "$VERBOSE" = true ]; then
  echo "$COMMAND"
fi

output=$($COMMAND 2>&1)

if [[ $output == *"Error"* ]]; then
  echo "Error: $output"
  exit 1
fi

echo "Data commitments updated successfully from Herodotus Fact registry for block $L1_BLOCK_NUMBER."