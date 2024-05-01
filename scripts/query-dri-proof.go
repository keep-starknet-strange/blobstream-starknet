// 
// Query the data root inclusion proof for given block height (default 5 block buffer)
// 
package main

import (
	"context"
	"fmt"
	"github.com/tendermint/tendermint/rpc/client/http"
	"os"
	"strconv"
)

// default block height
var CELESTIA_HEIGHT uint64 = 1723705

func main() {
	ctx := context.Background()
	trpc, err := http.New("tcp://rpc-mocha.pops.one:26657", "/websocket")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	err = trpc.Start()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	if len(os.Args) > 1 {
		CELESTIA_HEIGHT, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}
	
	dcProof, err := trpc.DataRootInclusionProof(ctx, CELESTIA_HEIGHT, CELESTIA_HEIGHT-5, CELESTIA_HEIGHT+5)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Println(dcProof.Proof.String())
}
