package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"

	blobtypes "github.com/celestiaorg/celestia-app/x/blob/types"
)

type Price struct {
	Usd float64 `json:"usd"`
}

type GetByAddress struct {
	Result struct {
		Data struct {
			Json struct {
				Transactions []struct {
					Hash string `json:"hash"`
				} `json:"transactions"`
			} `json:"json"`
		} `json:"data"`
	} `json:"result"`
}

type GetByHash struct {
	Result struct {
		Data struct {
			Json struct {
				BlobAsCalldataGasUsed uint64 `json:"blobAsCalldataGasUsed,string"`
				Blobs                 []struct {
					BlobHash string `json:"blobHash"`
					Blob     struct {
						Commitment string `json:"commitment"`
						Size       uint32 `json:"size"`
					} `json:"blob"`
				} `json:"blobs"`
				Block struct {
					BlobGasPrice uint64 `json:"blobGasPrice,string"`
				} `json:"block"`
				GasPrice uint64 `json:"gasPrice,string"`
			} `json:"json"`
		} `json:"data"`
	} `json:"result"`
}

type TiaGasPrice struct {
	Slow   float64 `json:"slow,string"`
	Median float64 `json:"median,string"`
	Fast   float64 `json:"fast,string"`
}

type Data struct {
	TotalBlobSize    uint64
	Blobs            []uint32
	BlobFee          float64
	BlobGasPrice     uint64
	GasPrice         uint64
	GasIfEthCalldata uint64
}

func main() {
	tia_price, _ := getTokenPriceInUSD("celestia")
	tia_gas_price, _ := getTIAGasPrice()
	eth_price, _ := getTokenPriceInUSD("ethereum")

	fmt.Printf("TIA: %.2f$\n", tia_price)
	fmt.Printf("ETH: %.2f$\n", eth_price)

	// Fetch last transaction hash of starknet submitting blob to ETH
	transaction_hash, _ := getLastTransactionHash()
	fmt.Println("Found last transaction hash: " + transaction_hash)

	// Get fees and size of blob from latest starknet submission
	data, err := getMetadataByTransactionHash(transaction_hash)
	if err != nil {
		return
	}

	// calculate what would be the cost if it was submitted to TIA instead
	gas_estimate := blobtypes.DefaultEstimateGas(data.Blobs)
	// Gas price in TIA = (consumed gas * gas price (in utia))/1e6
	gas_estimate_tia := (float64(gas_estimate) * tia_gas_price.Median / 1e6)

	// 3. Print output
	fmt.Println("Total Blob Size:", data.TotalBlobSize, "bytes")
	fmt.Println("Number of Blobs:", len(data.Blobs))
	fmt.Println("Blob Fee: ", data.BlobFee, "ETH")
	fmt.Println("ETH: Gas Used if posted as calldata", data.GasIfEthCalldata)

	fmt.Println()
	fmt.Println("ETH: Gas Used:", data.TotalBlobSize)
	fmt.Println("TIA: Gas Used:", tia_gas_price.Median)

	fmt.Println()
	gas_cost_if_calldata := float64(data.GasIfEthCalldata) * float64(data.GasPrice) / 1e18
	fmt.Println("Cost when posted on ETH as blob:", data.BlobFee*eth_price, "USD")
	fmt.Println("Cost when posted on ETH as calldata:", gas_cost_if_calldata*eth_price, "USD")
	fmt.Println("Cost when posted on TIA:", gas_estimate_tia*tia_price, "USD")
}

func getTIAGasPrice() (TiaGasPrice, error) {
	api_endpoint := "https://api.celenium.io/v1/gas/price"

	request, err := http.NewRequest(http.MethodGet, api_endpoint, nil)

	if err != nil {
		fmt.Println(err)
		return TiaGasPrice{}, err
	}

	client := &http.Client{}
	response, err := client.Do(request)

	if err != nil {
		fmt.Println(err)
		return TiaGasPrice{}, err
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		fmt.Println(err)
		return TiaGasPrice{}, err
	}
	var res TiaGasPrice
	err = json.Unmarshal(body, &res)

	if err != nil {
		fmt.Print(err)
		return TiaGasPrice{}, err
	}

	return res, nil
}

func getMetadataByTransactionHash(txn_hash string) (Data, error) {
	api_endpoint := fmt.Sprintf(`https://goerli.blobscan.com/api/trpc/tx.getByHash?input={"json":{"hash":"%s"}}`, txn_hash)

	request, err := http.NewRequest(http.MethodGet, api_endpoint, nil)

	if err != nil {
		fmt.Println(err)
		return Data{}, err
	}

	client := &http.Client{}
	response, err := client.Do(request)

	if err != nil {
		fmt.Println(err)
		return Data{}, err
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		fmt.Println(err)
		return Data{}, err
	}
	var res GetByHash
	err = json.Unmarshal(body, &res)

	if err != nil {
		fmt.Print(err)
		return Data{}, err
	}

	var data Data

	var totalBlobSize uint64 = 0
	// create an array of blob sizes dynamic array

	var blobs []uint32 = make([]uint32, 0)

	for _, blob := range res.Result.Data.Json.Blobs {
		totalBlobSize += uint64(blob.Blob.Size)
		blobs = append(blobs, blob.Blob.Size)
	}

	data.TotalBlobSize = totalBlobSize
	data.Blobs = blobs
	data.BlobGasPrice = res.Result.Data.Json.Block.BlobGasPrice
	data.GasIfEthCalldata = uint64(res.Result.Data.Json.BlobAsCalldataGasUsed)
	// BlobGasUsed seems to equal to TotalBlobSize
	data.BlobFee = float64((data.TotalBlobSize * data.BlobGasPrice)) / 1e18
	data.GasPrice = res.Result.Data.Json.GasPrice

	return data, nil

}

func getLastTransactionHash() (hash string, err error) {
	contract_address := "0x194e22f49bc3f58903866d55488e1e9e8d69b517"
	api_endpoint := fmt.Sprintf(`https://goerli.blobscan.com/api/trpc/tx.getByAddress?input={"json":{"address":"%s","p":1,"ps":25}}`, contract_address)

	request, err := http.NewRequest(http.MethodGet, api_endpoint, nil)

	if err != nil {
		fmt.Println(err)
		return "", err
	}

	client := &http.Client{}
	response, err := client.Do(request)

	if err != nil {
		fmt.Println(err)
		return "", err
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		fmt.Println(err)
		return "", err
	}
	var res GetByAddress
	err = json.Unmarshal(body, &res)

	return res.Result.Data.Json.Transactions[0].Hash, nil
}

func getTokenPriceInUSD(tokenID string) (price float64, err error) {
	api_endpoint := fmt.Sprintf("https://api.coingecko.com/api/v3/simple/price?ids=%s&vs_currencies=usd", tokenID)
	request, err := http.NewRequest(http.MethodGet, api_endpoint, nil)

	if err != nil {
		fmt.Println(err)
		return 0, err
	}

	key := os.Getenv("COIN_GECKO_KEY")
	if key != "" {
		request.Header.Add("x-cg-demo-api-key", key)
	}

	client := &http.Client{}
	response, err := client.Do(request)

	if err != nil {
		fmt.Println(err)
		return 0, err
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		fmt.Println(err)
		return 0, err
	}

	var data map[string]Price
	err = json.Unmarshal(body, &data)

	if err != nil {
		fmt.Println(err)
		return 0, err
	}

	return data[tokenID].Usd, nil
}

// Used for debugging
func dump(data interface{}) {
	b, _ := json.MarshalIndent(data, "", "  ")
	fmt.Println(string(b))
}
