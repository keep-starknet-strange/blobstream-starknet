# Overview

![BSN Module](../assets/blobstreamSnModule.png)

Blobstream allows Celestia block header data roots to be relayed
***from Celestia to Starknet.***

It does not support bridging assets such as fungible
or non-fungible tokens directly, and cannot send messages from the Starknet
back to Celestia.

`blobstream_sn` is a port of Celestia Blobstream in Cairo deployed on Starknet:

- [Solidity Blobstream Contracts](https://github.com/celestiaorg/blobstream-contracts)
- [Cairo](https://book.cairo-lang.org/)
- [Starknet](https://docs.starknet.io/documentation)
