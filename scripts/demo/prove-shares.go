package main

import (
	"context"
	"encoding/hex"
	"fmt"
	"github.com/tendermint/tendermint/rpc/client/http"
)

// default block height
var CELESTIA_HEIGHT uint64 = 1727045
var CEL_RPC string = "tcp://rpc-mocha.pops.one:26657"
var TX_HASH string = "8470355AEB1481D69E1612F1C95741B77A60696CE21662C03E2FEA0E0D7414F6"

func main() {
	// ---------------- Setup Clients & Contracts --------------------
	ctx := context.Background()

	trpc, err := http.New(CEL_RPC, "/websocket")
	if err != nil {
		panic(err)
	}
	err = trpc.Start()
	if err != nil {
		panic(err)
	}

	decoded, _ := hex.DecodeString(TX_HASH)
	tx, err := trpc.Tx(ctx, decoded, true)
	if err != nil {
		panic(err)
	}
	fmt.Printf("TX: %+v\n\n", tx)
}
