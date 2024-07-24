# NFT Staking Contract

## Overview

This project implements an NFT staking contract where users can stake their NFTs and earn reward tokens. The contract supports staking and unstaking NFTs, claiming rewards, and is upgradeable using the UUPS proxy pattern.

## Requirements

- Node.js
- Foundry
- An Ethereum network (e.g., Mainnet, Rinkeby, etc.)
- RPC URL and Private Key for deployment

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/soloking1412/NFTStaking-Foundry.git
    cd NFTStaking-Foundry
    ```

2. Install Foundry and other dependencies:

    ```bash
    forge install
    ```

## Deployment

1. Update the deployment script `DeployNFTStaking.s.sol` with your RPC URL and Private Key.

2. Compile the contracts:

    ```bash
    forge build
    ```

3. Run the deployment script:

    ```bash
    forge script script/DeployNFTStaking.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
    ```

    Replace `<your_rpc_url>` with the RPC URL of the network you're deploying to (e.g., Infura, Alchemy) and `<your_private_key>` with the private key of the deploying wallet.

## Testing

1. Run the tests:

    ```bash
    forge test
    ```

## Contracts

### NFTStaking

The main contract for staking NFTs and earning rewards. Users can stake their NFTs, claim rewards, and unstake their NFTs after an unbonding period.

### ERC721Mock

A mock ERC721 contract used for testing purposes. This contract allows minting of NFTs for testing.

### ERC20Mock

A mock ERC20 contract used for testing purposes. This contract allows minting of reward tokens for testing.

## Project Structure

- `src/`: Contains the Solidity source files.
  - `NFTStaking.sol`: The main NFT staking contract.
  - `ERC721Mock.sol`: Mock ERC721 contract for testing.
  - `ERC20Mock.sol`: Mock ERC20 contract for testing.
- `script/`: Contains the deployment script.
  - `DeployNFTStaking.s.sol`: Script to deploy the NFTStaking contract and the mock contracts.
- `test/`: Contains the test scripts.
  - `NFTStakingTest.t.sol`: Test cases for the NFTStaking contract.

