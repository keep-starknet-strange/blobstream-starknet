#!/bin/bash
#
# Submit payload to Celestia
# Uses a light node and pre-funded account to submit data
# to Celestia

# Constants
NETWORK="mocha"
AUTH_TOKEN=$(celestia light auth admin --p2p.network $NETWORK)
VERBOSE=false

# Optional
NAMESPACE="SN_APP"
DATA_PATH="src/tests/data/os_output.json"

usage() {
  echo "usage: $0 [-n namespace] [-d path] [-v]"
  echo -e "\tsubmit data to celestia"
  echo
  echo -e "\t-n, --namespace                   celestia Namespace(default: SN_APP)"
  echo -e "\t-d, --data-path                   local path to data for submission"
  echo -e "\t-v, --verbose                     display verbose output"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--namespace") set -- "$@" "-n" ;;
    "--data-path") set -- "$@" "-d" ;;
    "--verbose") set -- "$@" "-v" ;;
    "--help") set -- "$@" "-h" ;;
    *) set -- "$@" "$arg"
  esac
done

# Parse command line arguments
while getopts ":n:d:vh" opt; do
  case ${opt} in
    n)
      NAMESPACE="${OPTARG}"
      ;;
    d)
      DATA_PATH="${OPTARG}"
      ;;
    v)
      VERBOSE=true
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      echo "Invalid option: $OPTARG" 1>&2
      usage
      exit 1
      ;;
  esac
done

# Check Dependencies
if ! command -v celestia > /dev/null; then
    echo -e "please install:\n\thttps://docs.celestia.org/developers/node-tutorial"
    exit 1
fi

CEL_BALANCE=$(celestia state balance --token $AUTH_TOKEN | jq -r '.result.amount')
if [ ${CEL_BALANCE} -gt 0 ]; then
    echo "Celestia Account Balance: $CEL_BALANCE UTIA"
else
    echo "Celestia Account: insufficient balance"
    exit 1
fi

if [ ! -f $DATA_PATH ]; then
    echo "INVALID DATA PATH($DATA_PATH)"
    exit 1
fi

# Format and submit data
HEX_NS=0x$(xxd -p <<< $NAMESPACE)
HEX_DATA=$(xxd -p -c 0 $DATA_PATH | tr -d '\n')
echo "Submission Results:"
CEL_RESPONSE=$(celestia blob submit $HEX_NS $HEX_DATA --token $AUTH_TOKEN)
echo $CEL_RESPONSE | jq

if $VERBOSE; then
    HEIGHT=$(echo $CEL_RESPONSE | jq '.result.height')
    celestia header get-by-height $HEIGHT --token $AUTH_TOKEN
fi
