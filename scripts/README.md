## Set up `starkli`

Follow [Starkli 101](https://book.starkli.rs/tutorials/starkli-101) tutorial to set up a signer and an account. We are deploying to Sepolia so remember to use the `--network sepolia` option to interact with the testnet.

Create a `.env` file in project root as follows :

````shell
STARKNET_KEYSTORE="/path/to/key.json"
KEYSTORE_PASSWORD="password"
STARKNET_ACCOUNT="/path/to/account.json"
````

