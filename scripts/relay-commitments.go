package main

import (
	"context"
	"fmt"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	ethcmn "github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	blobstreamxwrapper "github.com/succinctlabs/blobstreamx/bindings"
	"github.com/tendermint/tendermint/rpc/client/http"
)

const 
var ETH_RPC string = "https://sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
var CEL_RPC string = "tcp://rpc-mocha.pops.one:26657"
var BLOBSTREAMX_ADDR string = "0xF0c6429ebAB2e7DC6e05DaFB61128bE21f13cb1e"