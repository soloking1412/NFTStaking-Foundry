// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract NFTStaking is UUPSUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    IERC721 public nft;
    IERC20 public rewardToken;

    struct Staker {
        uint256[] stakedNFTs;
        uint256 rewards;
        uint256 lastUpdateBlock;
        uint256 unstakingStartBlock;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public nftOwner;

    uint256 public rewardPerBlock;
    uint256 public delayPeriod;
    uint256 public unbondingPeriod;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardClaimed(address indexed user, uint256 amount);

    function initialize(
        address _nft,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _delayPeriod,
        uint256 _unbondingPeriod
    ) public initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();
        __UUPSUpgradeable_init();

        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
        rewardPerBlock = _rewardPerBlock;
        delayPeriod = _delayPeriod;
        unbondingPeriod = _unbondingPeriod;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function stake(uint256 tokenId) external whenNotPaused {
        nft.transferFrom(msg.sender, address(this), tokenId);

        Staker storage staker = stakers[msg.sender];
        staker.stakedNFTs.push(tokenId);
        _updateRewards(msg.sender);

        nftOwner[tokenId] = msg.sender;

        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external whenNotPaused {
        require(nftOwner[tokenId] == msg.sender, "Not the owner");

        Staker storage staker = stakers[msg.sender];
        _updateRewards(msg.sender);

        // Remove NFT from stakedNFTs array
        uint256 index = _findIndex(staker.stakedNFTs, tokenId);
        staker.stakedNFTs[index] = staker.stakedNFTs[staker.stakedNFTs.length - 1];
        staker.stakedNFTs.pop();

        staker.unstakingStartBlock = block.number;

        emit Unstaked(msg.sender, tokenId);
    }

    function withdrawNFT(uint256 tokenId) external {
        require(nftOwner[tokenId] == msg.sender, "Not the owner");
        Staker storage staker = stakers[msg.sender];
        require(block.number >= staker.unstakingStartBlock + unbondingPeriod, "Unbonding period not over");

        delete nftOwner[tokenId];
        nft.transferFrom(address(this), msg.sender, tokenId);
    }

    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        require(block.number >= staker.lastUpdateBlock + delayPeriod, "Delay period not over");

        _updateRewards(msg.sender);

        uint256 rewards = staker.rewards;
        staker.rewards = 0;

        rewardToken.transfer(msg.sender, rewards);

        emit RewardClaimed(msg.sender, rewards);
    }

    function _updateRewards(address stakerAddress) internal {
        Staker storage staker = stakers[stakerAddress];

        if (staker.lastUpdateBlock == 0) {
            staker.lastUpdateBlock = block.number;
            return;
        }

        uint256 blocks = block.number - staker.lastUpdateBlock;
        staker.rewards += staker.stakedNFTs.length * blocks * rewardPerBlock;
        staker.lastUpdateBlock = block.number;
    }

    function _findIndex(uint256[] storage array, uint256 value) internal view returns (uint256) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return i;
            }
        }
        revert("Value not found");
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        rewardPerBlock = _rewardPerBlock;
    }

    function setDelayPeriod(uint256 _delayPeriod) external onlyOwner {
        delayPeriod = _delayPeriod;
    }

    function setUnbondingPeriod(uint256 _unbondingPeriod) external onlyOwner {
        unbondingPeriod = _unbondingPeriod;
    }
}
