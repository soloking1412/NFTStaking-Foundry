// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NFTStaking.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTStakingTest is Test {
    ERC721 nft;
    ERC20 rewardToken;
    NFTStaking nftStaking;
    address user = address(0x123);

    function setUp() public {
        // Deploy the ERC721 (NFT) and ERC20 (Reward Token) contracts
        nft = new ERC721("NFT Collection", "NFTC");
        rewardToken = new ERC20("Reward Token", "RWT");

        // Mint some NFTs to user address
        nft.mint(user, 1);
        nft.mint(user, 2);

        // Deploy the NFTStaking contract
        nftStaking = new NFTStaking();
        nftStaking.initialize(address(nft), address(rewardToken), 10, 100, 50);

        // Transfer some reward tokens to the staking contract
        rewardToken.transfer(address(nftStaking), 10000);
    }

    function testStakeAndClaimRewards() public {
        vm.startPrank(user);

        // Approve NFT transfer and stake
        nft.approve(address(nftStaking), 1);
        nftStaking.stake(1);

        // Simulate some blocks
        vm.roll(block.number + 10);

        // Claim rewards
        nftStaking.claimRewards();

        uint256 rewards = rewardToken.balanceOf(user);
        assert(rewards > 0);

        vm.stopPrank();
    }

    function testUnstakeAndWithdrawNFT() public {
        vm.startPrank(user);

        // Approve NFT transfer and stake
        nft.approve(address(nftStaking), 1);
        nftStaking.stake(1);

        // Unstake NFT
        nftStaking.unstake(1);

        // Simulate blocks to pass unbonding period
        vm.roll(block.number + 50);

        // Withdraw NFT
        nftStaking.withdrawNFT(1);

        assert(nft.ownerOf(1) == user);

        vm.stopPrank();
    }
}
