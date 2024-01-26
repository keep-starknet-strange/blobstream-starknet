# Getting Started

There are several ways to run `blobstream_sn`:

- Install dependencies
- Run in a dev container

## Install dependencies

`blobstream_sn` requires both [scarb](https://docs.swmansion.com/scarb/download.html)
and [snfoundry](https://foundry-rs.github.io/starknet-foundry). As scarb doesn't
currently have dependency version resolution we will use `asdf`:

- [install asdf](https://asdf-vm.com/guide/getting-started.html)
- navigate to project root
- run `asdf install`

## Run in a dev container

Dev containers provide a dedicated environment for the project. Since the dev
container configuration is stored in the `.devcontainer` directory, this ensures
that the environment is strictly identical from one developer to the next.

To run inside a dev container, please follow [Dev Containers tutorial](https://code.visualstudio.com/docs/devcontainers/tutorial).
