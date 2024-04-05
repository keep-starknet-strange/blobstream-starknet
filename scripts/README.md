# Tooling documentation

## Setting up `starkli`

Follow [Starkli 101](https://book.starkli.rs/tutorials/starkli-101) tutorial to set up a signer and an account. We are deploying to Sepolia, so you can use the `--network sepolia` option to interact with the testnet with a free RPC vendor.

Create a `.env` file in project root as follows:

````shell
STARKNET_KEYSTORE="/path/to/key.json"
STARKNET_ACCOUNT="/path/to/account.json"
````

## Deploying the blobstreamx contract

Run the deployment script:

````shell
deploy-blobstreamx.sh --owner <owner_address> --height <block_height> --header <block_header>
````

You will be prompted to enter your keystore password two times: once for declaring the class hash and another for deploying the contract.

You are required to provide an owner, a height, and a header, although additional parameters can be provided.

Please review the `--help` menu for more information. You can use `--debug` to create a log file.
