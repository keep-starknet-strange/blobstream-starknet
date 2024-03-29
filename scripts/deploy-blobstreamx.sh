#!/bin/bash
source ../.env

# Check if required env variables are set, if not exit
if [ -z "$STARKNET_KEYSTORE" ]; then
  echo "STARKNET_KEYSTORE is not set."
  exit 1
elif [ -z "$KEYSTORE_PASSWORD" ]; then
  echo "KEYSTORE_PASSWORD is not set."
  exit 1
elif [ -z "$STARKNET_ACCOUNT" ]; then
  echo "STARKNET_ACCOUNT is not set."
  exit 1
fi

# Constants
SIERRA_FILE=../target/dev/blobstream_sn_blobstreamx.contract_class.json
# Optional arguments
HERODOTUS_FACT_REGISTRY_ADDRESS="0x07d3550237ecf2d6ddef9b78e59b38647ee511467fe000ce276f245a006b40bc"
BLOBSTREAMX_L1_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"
# TODO : Change when Succint contracts are deployed
GATEWAY_ADDRESS="0x07e4220832ecf2d6ddef9b78e59b38647ee511467fe000ce225f245a006b32cb"
HEADER_RANGE_FUNCTION_ID="0x1"
NEXT_HEADER_FUNCTION_ID="0x2"

display_help() {
  echo "Usage: $0 [option...] {arguments...}"
  echo
  echo "   -o, --owner ADDR                         Owner address on Starknet"
  echo "                                            (required)"
  echo "   -H, --height U64                         Height of the latest block number updated by the light client"
  echo "                                            (required)"
  echo "   -a, --header U256                        Header hash for the block height"
  echo "                                            (required)"

  echo
  echo "   -g, --gateway ADDR                       Succint gateway contract address on Starknet"
  echo "                                            (default: $GATEWAY_ADDRESS (SEPOLIA))"
  echo "   -r, --header-range-function-id U256      Header range function id"
  echo "                                            (default: $HEADER_RANGE_FUNCTION_ID)"
  echo "   -n, --next-header-function_id U256       Next header function id"
  echo "                                            (default: $NEXT_HEADER_FUNCTION_ID)"
  echo "   -f, --herodotus-facts-registry ADDR      Herodotus fact registry address on Starknet"
  echo "                                            (default: $HERODOTUS_FACT_REGISTRY_ADDRESS (SEPOLIA))"
  echo "   -b, --blobstreamx-l1 ADDR                BlobstreamX contract address on L1"
  echo "                                            (default: $BLOBSTREAMX_L1_ADDRESS (SEPOLIA))"

  echo
  echo "   -h, --help                               display help"
  echo "   -d, --debug                              debug mode: creates debug_blobstreamx.log"

  echo
  echo "Example: $0"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--gateway") set -- "$@" "-g" ;;
    "--owner") set -- "$@" "-o" ;;
    "--height") set -- "$@" "-H" ;;
    "--header") set -- "$@" "-a" ;;
    "--header-range-function-id") set -- "$@" "-r" ;;
    "--next-header-function_id") set -- "$@" "-n" ;;
    "--herodotus-facts-registry") set -- "$@" "-f" ;;
    "--blobstreamx-l1") set -- "$@" "-b" ;;
    "--help") set -- "$@" "-h" ;;
    "--debug") set -- "$@" "-d" ;;
    *) set -- "$@" "$arg"
  esac
done

# Parse command line arguments
while getopts ":hdg:o:a:H:r:n:f:b:-:" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    d )
      DEBUG=true
      ;;
    g )
      GATEWAY_ADDRESS="$OPTARG"
      ;;
    o )
      OWNER="$OPTARG"
      ;;
    H )
      HEIGHT="$OPTARG"
      ;;
    a )
      HEADER="$OPTARG"
      ;;
    r )
      HEADER_RANGE_FUNCTION_ID="$OPTARG"
      ;;
    n )
      NEXT_HEADER_FUNCTION_ID="$OPTARG"
      ;;
    f )
      HERODOTUS_FACT_REGISTRY_ADDRESS="$OPTARG"
      ;;
    b )
      BLOBSTREAMX_L1_ADDRESS="$OPTARG"
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

# Check if required parameters are set, if not exit.
if [ -z "$OWNER" ]; then
  echo "Error: --owner is not specified."
  exit 1
elif [ -z "$HEIGHT" ]; then
  echo "Error: --height is not specified."
  exit 1
elif [ -z "$HEADER" ]; then
  echo "Error: --header is not specified."
  exit 1
fi

# Build the contract
build() {
    output=$(scarb build 2>&1)

    if [[ $output == *"Error"* ]]; then
        echo "Error: $output"
        exit 1
    fi
}

# Declare the contract
declare() {
    build
    if [ "$DEBUG" = true ]; then
        echo "declare --keystore $STARKNET_KEYSTORE --keystore-password $KEYSTORE_PASSWORD --account $STARKNET_ACCOUNT --watch $SIERRA_FILE" > debug_blobstreamx.log
    fi
    output=$(starkli declare --network sepolia --keystore $STARKNET_KEYSTORE --keystore-password $KEYSTORE_PASSWORD --account $STARKNET_ACCOUNT --watch $SIERRA_FILE 2>&1)

    if [[ $output == *"Error"* ]]; then
        echo "Error: $output"
        exit 1
    fi

    address=$(echo "$output" | grep -oP '0x[0-9a-fA-F]+')
    echo $address
}

# Deploy the contract
deploy() {
    class_hash=$(declare | tail -n 1)

    if [ "$DEBUG" = true ]; then
        echo "deploy --network sepolia --keystore $STARKNET_KEYSTORE --keystore-password $KEYSTORE_PASSWORD --account $STARKNET_ACCOUNT --watch $class_hash $GATEWAY_ADDRESS $OWNER $HEIGHT u256:$HEADER u256:$HEADER_RANGE_FUNCTION_ID u256:$NEXT_HEADER_FUNCTION_ID $HERODOTUS_FACT_REGISTRY_ADDRESS $BLOBSTREAMX_L1_ADDRESS" >> debug_blobstreamx.log
    fi
    output=$(starkli deploy --network sepolia --keystore $STARKNET_KEYSTORE --keystore-password $KEYSTORE_PASSWORD --account $STARKNET_ACCOUNT --watch $class_hash "$GATEWAY_ADDRESS" "$OWNER" "$HEIGHT" u256:"$HEADER" u256:"$HEADER_RANGE_FUNCTION_ID" u256:"$NEXT_HEADER_FUNCTION_ID" "$HERODOTUS_FACT_REGISTRY_ADDRESS" "$BLOBSTREAMX_L1_ADDRESS" 2>&1)

    if [[ $output == *"Error"* ]]; then
        echo "Error: $output"
        exit 1
    fi

    address=$(echo "$output" | grep -oP '0x[0-9a-fA-F]+' | tail -n 1) 
    echo $address
}

contract_address=$(deploy)
echo "Deployed at : $contract_address"