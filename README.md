# escrow-cairo-workshop

Code for the [Cairo workshop @ ETHPrauge 2024](https://lu.ma/kgduelev).

We'll learn the basics of working with Cairo and creating a smart contract for Starknet. That includes contract structure, manipulating storage, creating and implementing an interface, events, external and internal methods, etc. We'll take a stab at writing tests and get familiar with the interface. If time permits, we'll declare and deploy our contract to a testnet.

## Setup

To get most out of this workshop, you should come prepared. Please install [Scarb](https://docs.swmansion.com/scarb/download.html) v2.6.4 and [Starknet foundry](https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html) v0.23.0.

To confirm your setup is correct, clone this repository and run `scarb test`. You should see the following output in the console:

```text
Collected 1 test(s) from escrow package
Running 1 test(s) from src/
It works!
[PASS] escrow::tests::test_setup (gas: ~1)
Tests: 1 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```

### Starkli setup

If we'll have enough time, we'll also deploy a contract to the Sepolia testnet. To do so, we'll use [starkli](https://book.starkli.rs/installation) so please install v0.2.9 as well. Next, create a keystore file with starkli:

```sh
starkli signer keystore new sepolia_keystore.json
```

Then, create an account you'll use for interacting with the testnet:

```sh
starkli account oz init sepolia_account --keystore sepolia_keystore.json
```

Starkli prints out the address to which this account will be deployed. Before you can deploy it, you'll have to send some ETH to that address. If you need Sepolia ETH, try one of the faucets: [Alchemy](https://www.alchemy.com/faucets/starknet-sepolia), [Blast](https://blastapi.io/faucets/starknet-sepolia-eth), [Starknet Foundation](https://starknet-faucet.vercel.app/). Once funded, you can deploy the account:

```sh
starkli account deploy sepolia_account.json --keystore sepolia_keystore.json --network sepolia
```

See you in Prague!
