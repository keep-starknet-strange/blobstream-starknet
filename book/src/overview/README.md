# Overview

![BSN Module](../assets/blobstreamSnModule.png)

Blobstream Starknet is an integration of Celestia's modular Data Availability layer with Starknet. This solution allows Starknet L3 to submit data to Celestia through Blobstream.

## Blobstream : Modular Data Availability Layer

Blobstream is a solution developed by Celestia Labs to stream Celestia's modular DA layer to Ethereum. It relays commitments of Celestia's data root using an on-chain light client. This enables Ethereum developers to create scalable L2.

Blobstream is based on Data Availability Sampling (DAS). It allows any user to contribute to DA for rollups by running a sampling light node. As the light node network grows, Celestia can scale without compromising security for end users.

To optimize Celestia as a DA layer, Succinct Labs contributed **Blobstream X**, a zero-knowledge (ZK) implementation that uses a ZK light client to verify Celestia validator signatures on-chain with a single ZK proof. This approach reduces overhead for validators, simplifies the core Celestia protocol, and enables faster streaming of data root commitments for Ethereum L2s.

## Why Starknet L3 should use Blobstream

Several key differences highlight the advantages of using Celestia's Blobstream for DA instead of relying on Data Availability Committee (DAC).

### Scalability

The scalability of a DAC can be limited by its structure. With a modular approach to DA, Blobstream maximises data throughout by providing dedicated blobspace that is priced independently of Ethereum gas costs and unrelated to execution.

### Decentralization

DACs rely on a selected group of nodes which can lead to points of failure. Blobstream decentralizes the process by spreading data across a wider network to enhance security. Light nodes can detect if up to two-thirds of Celestia validators withhold data or produce invalid blocks, holding them accountable via slashing.

### Trust and transparency

In a DAC, users must trust the commitee to act honestly and make data available whereas Blobstream's use of cryptographic proofs for data availability offers a higher degree of transparency and trustlessness. Users don't need to trust individual actors anymore. 

## How does it work ? 

As Starknet does not natively support Ethereum Virtual Machine (EVM). The Blobstream X contracts had to be rewrited from Solidity to Cairo. 

Each L3 would need to deploy a [core contract](./l3_starknet/core_contract.md). They would need to either fork [piltover](https://github.com/keep-starknet-strange/piltover) or create new core contracts if they work significantly different from Starknet.

Then the Starknet L3 can use Celestia as DA by : 
- Posting data to Celestia
- Interacting with the Core Contract to verify proofs and check DA via the [blobstream DA contract](./l3_starknet/verifier.md)  


Useful links : 
- [Solidity Blobstream X Contracts](https://github.com/succinctlabs/blobstreamx)
- [Cairo](https://book.cairo-lang.org/)
- [Starknet](https://docs.starknet.io/documentation)
