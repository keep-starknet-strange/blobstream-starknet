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

// default block height
var CELESTIA_HEIGHT int64 = 1727045
var ETH_RPC string = "https://sepolia.infura.io/v3/bed8a8401c894421bd7cd31050e7ced6"
var CEL_RPC string = "tcp://rpc-mocha.pops.one:26657"
var BLOBSTREAMX_ADDR string = "0xF0c6429ebAB2e7DC6e05DaFB61128bE21f13cb1e"

func main() {
	err := verify()
	if err != nil {
		fmt.Println("err:", err)
		os.Exit(1)
	}
}

func verify() error {
	// ---------------- Setup Clients & Contracts --------------------
	ctx := context.Background()

	trpc, err := http.New(CEL_RPC, "/websocket")
	if err != nil {
		return err
	}
	err = trpc.Start()
	if err != nil {
		return err
	}

	blockRes, err := trpc.Block(ctx, &CELESTIA_HEIGHT)
	if err != nil {
		return err
	}

	ethClient, err := ethclient.Dial(ETH_RPC)
	if err != nil {
		return err
	}
	defer ethClient.Close()

	wrapper, err := blobstreamxwrapper.NewBlobstreamX(ethcmn.HexToAddress(BLOBSTREAMX_ADDR), ethClient)
	if err != nil {
		return err
	}

	LatestBlockNumber, err := ethClient.BlockNumber(context.Background())
	if err != nil {
		return err
	}

	// ---------------- Fetch BlobstreamX Event --------------------
	eventsIterator, err := wrapper.FilterDataCommitmentStored(
		&bind.FilterOpts{
			Context: ctx,
			Start:   LatestBlockNumber - 90000,
			End:     &LatestBlockNumber,
		},
		nil,
		nil,
		nil,
	)
	if err != nil {
		return err
	}

	var event *blobstreamxwrapper.BlobstreamXDataCommitmentStored
	for eventsIterator.Next() {
		e := eventsIterator.Event
		if int64(e.StartBlock) <= CELESTIA_HEIGHT && CELESTIA_HEIGHT < int64(e.EndBlock) {
			event = &blobstreamxwrapper.BlobstreamXDataCommitmentStored{
				ProofNonce:     e.ProofNonce,
				StartBlock:     e.StartBlock,
				EndBlock:       e.EndBlock,
				DataCommitment: e.DataCommitment,
			}
			break
		}
	}
	if err := eventsIterator.Error(); err != nil {
		return err
	}
	err = eventsIterator.Close()
	if err != nil {
		return err
	}
	if event == nil {
		return fmt.Errorf("couldn't find range containing the transaction height")
	}

	fmt.Println("Commitment Info:")
	fmt.Printf("\tdata commitment \t\t%x\n", event.DataCommitment)
	fmt.Printf("\tdata root tuple\t\t\t(%x, %d)\n", blockRes.Block.DataHash, CELESTIA_HEIGHT)
	fmt.Printf("\tproof nonce \t\t\t%d\n", event.ProofNonce)
	fmt.Printf("\tblobstreamx block range \t%d - %d\n", event.StartBlock, event.EndBlock)

	// ---------------- Fetch Inclusion Proof --------------------
	dcProof, err := trpc.DataRootInclusionProof(ctx, uint64(CELESTIA_HEIGHT), event.StartBlock, event.EndBlock)
	if err != nil {
		return err
	}

	// ---------------- Verify Inclusion --------------------
	tuple := blobstreamxwrapper.DataRootTuple{
		Height:   big.NewInt(CELESTIA_HEIGHT),
		DataRoot: *(*[32]byte)(blockRes.Block.DataHash),
	}

	sideNodes := make([][32]byte, len(dcProof.Proof.Aunts))
	for i, aunt := range dcProof.Proof.Aunts {
		sideNodes[i] = *(*[32]byte)(aunt)
	}
	wrappedProof := blobstreamxwrapper.BinaryMerkleProof{
		SideNodes: sideNodes,
		Key:       big.NewInt(dcProof.Proof.Index),
		NumLeaves: big.NewInt(dcProof.Proof.Total),
	}

	valid, err := wrapper.VerifyAttestation(&bind.CallOpts{}, big.NewInt(event.ProofNonce.Int64()), tuple, wrappedProof)
	if err != nil {
		return err
	}
	fmt.Printf("\tvalid proof \t\t\t%t\n", valid)

	return nil
}
