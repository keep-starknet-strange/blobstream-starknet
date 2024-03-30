#!/bin/bash
source ../.env

# Check if required env variables are set, if not exit
if [ -z "$STARKNET_KEYSTORE" ]; then
  echo "Error: STARKNET_KEYSTORE is not set."
  exit 1
elif [ -z "$STARKNET_ACCOUNT" ]; then
  echo "Error: STARKNET_ACCOUNT is not set."
  exit 1
fi

# Constants
SIERRA_FILE=../target/dev/blobstream_sn_blobstreamx.contract_class.json
# Optional arguments
HERODOTUS_FACTS_REGISTRY_ADDRESS="0x07d3550237ecf2d6ddef9b78e59b38647ee511467fe000ce276f245a006b40bc"
BLOBSTREAMX_L1_ADDRESS="0x48B257EC1610d04191cC2c528d0c940AdbE1E439"
# TODO : Change when Succint contracts are deployed
GATEWAY_ADDRESS="0x07e4220832ecf2d6ddef9b78e59b38647ee511467fe000ce225f245a006b32cb"
HEADER_RANGE_FUNCTION_ID="0x1"
NEXT_HEADER_FUNCTION_ID="0x2"

display_help() {
  echo "Usage: $0 [option...]"
  echo
  echo "   -o, --owner ADDR                         Owner address on Starknet"
  echo "                                            (required)"
  echo "   -H, --height U64                         Height of the latest block number updated by the light client"
  echo "                                            (required)"
  echo "   -a, --header U256                        Header hash for the corresponding block height"
  echo "                                            (required)"

  echo
  echo "   -g, --gateway ADDR                       Succint gateway contract address on Starknet"
  echo "                                            (default: $GATEWAY_ADDRESS (SEPOLIA))"
  echo "   -r, --header-range-function-id U256      Header range function id"
  echo "                                            (default: $HEADER_RANGE_FUNCTION_ID)"
  echo "   -n, --next-header-function-id U256       Next header function id"
  echo "                                            (default: $NEXT_HEADER_FUNCTION_ID)"
  echo "   -f, --herodotus-facts-registry ADDR      Herodotus facts registry address on Starknet"
  echo "                                            (default: $HERODOTUS_FACTS_REGISTRY_ADDRESS (SEPOLIA))"
  echo "   -b, --blobstreamx-l1 ADDR                BlobstreamX contract address on L1"
  echo "                                            (default: $BLOBSTREAMX_L1_ADDRESS (SEPOLIA))"

  echo
  echo "   -h, --help                               display help"
  echo "   -d, --debug                              save logs in debug_blobstreamx.log"

  echo
  echo "Example: $0 --owner 0x0 --height 0x1 --header 0x2"
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
    "--next-header-function-id") set -- "$@" "-n" ;;
    "--herodotus-facts-registry") set -- "$@" "-f" ;;
    "--blobstreamx-l1") set -- "$@" "-b" ;;
    "--help") set -- "$@" "-h" ;;
    "--debug") set -- "$@" "-d" ;;
    --*) unrecognized_options+=("$arg") ;;
    *) set -- "$@" "$arg"
  esac
done

# Check if unknown options are passed, if so exit
if [ ! -z "${unrecognized_options[@]}" ]; then
  echo "Error: invalid option(s) passed ${unrecognized_options[*]}" 1>&2
  exit 1
fi

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
      HERODOTUS_FACTS_REGISTRY_ADDRESS="$OPTARG"
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

# Check if required options are set, if not exit
if [ -z "$OWNER" ] || [ -z "$HEIGHT" ] || [ -z "$HEADER" ]; then
  echo "Error: missing required options (see --help)"
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
        echo "declare --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $SIERRA_FILE" > debug_blobstreamx.log
    fi

    output=$(starkli declare --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $SIERRA_FILE 2>&1)
    
    if [ "$DEBUG" = true ]; then
        echo "$output" >> debug_blobstreamx.log
    fi
    
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
        echo "deploy --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $class_hash $GATEWAY_ADDRESS $OWNER $HEIGHT u256:$HEADER u256:$HEADER_RANGE_FUNCTION_ID u256:$NEXT_HEADER_FUNCTION_ID $HERODOTUS_FACTS_REGISTRY_ADDRESS $BLOBSTREAMX_L1_ADDRESS" >> debug_blobstreamx.log
    fi

    output=$(starkli deploy --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $class_hash "$GATEWAY_ADDRESS" "$OWNER" "$HEIGHT" u256:"$HEADER" u256:"$HEADER_RANGE_FUNCTION_ID" u256:"$NEXT_HEADER_FUNCTION_ID" "$HERODOTUS_FACTS_REGISTRY_ADDRESS" "$BLOBSTREAMX_L1_ADDRESS" 2>&1)

    if [ "$DEBUG" = true ]; then
        echo "$output" >> debug_blobstreamx.log
    fi

    if [[ $output == *"Error"* ]]; then
        echo "Error: $output"
        exit 1
    fi

    address=$(echo "$output" | grep -oP '0x[0-9a-fA-F]+' | tail -n 1) 
    echo $address
}

contract_address=$(deploy)
echo "Deployed at: $contract_address"