#!/bin/bash

PROJECT_ROOT=`git rev-parse --show-toplevel`

# Load env variable from .env only if they're not already set
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
MAX_FEE="none"

display_help() {
    echo "Usage: $0 [option...]"
    echo
    echo "  -n, --proof-nonce U64           Proof nonce"
    echo "                                  (required)"
    echo "  -r, --data-root DATA_ROOT       Data root"
    echo "                                  (required)"
    echo "  -p, --proof BINARY_PROOF        Binary merkle proof"
    echo "                                  (required)"

    echo
    echo "   -B, --blobstreamx-starknet ADDR  BlobstreamX contract address on Starknet"
    echo "                                    (default: $BLOBSTREAMX_STARKNET_ADDRESS (SEPOLIA))"
    echo "   -m, --max-fee ETH                Max fee"
    echo "                                    (default: estimated automatically)"
    
    echo
    echo "  -h, --help                      display help"
    echo "  -v, --verbose                   verbose output"
    echo
    echo "Example: $0 --proof-nonce 123 --data-root <root_value> --proof <proof_value>"
}

# Transform long options to short ones
for arg in "$@"; do
    shift
    case "$arg" in
        "--proof-nonce") set -- "$@" "-n" ;;
        "--data-root") set -- "$@" "-r" ;;
        "--proof") set -- "$@" "-p" ;;
        "--blobstreamx-starknet") set -- "$@" "-B" ;;
        "--max-fee") set -- "$@" "-m" ;;
        "--help") set -- "$@" "-h" ;;
        "--verbose") set -- "$@" "-v" ;;
        *) set -- "$@" "$arg"
    esac
done

# Parse command line arguments
while getopts ":hvn:r:p:B:m:-:" opt; do
    case ${opt} in
        h )
            display_help
            exit 0
            ;;
        v )
            VERBOSE=true
            ;;
        n )
            PROOF_NONCE="$OPTARG"
            ;;
        r )
            DATA_ROOT="$OPTARG"
            ;;
        p )
            PROOF="$OPTARG"
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
if [ -z "$PROOF_NONCE" ] || [ -z "$DATA_ROOT" ] || [ -z "$PROOF" ]; then
    echo "Error: missing required options"
    display_help
    exit 1
fi

if [ "$MAX_FEE" = "none" ]; then
    COMMAND="starkli invoke --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $BLOBSTREAMX_STARKNET_ADDRESS verify_attestation $PROOF_NONCE $DATA_ROOT $PROOF"
else
    COMMAND="starkli invoke --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --max-fee $MAX_FEE  --watch $BLOBSTREAMX_STARKNET_ADDRESS verify_attestation $PROOF_NONCE $DATA_ROOT $PROOF"
fi

if [ "$VERBOSE" = true ]; then
    echo "$COMMAND"
fi

output=$($COMMAND 2>&1)

if [[ $output == *"Error"* ]]; then
    echo "Error: $output"
    exit 1
fi

tx=$(echo "$output" | grep -oP '0x[0-9a-fA-F]+' | tail -n 1)

echo "Submitted transaction for DA verification at: $tx"
