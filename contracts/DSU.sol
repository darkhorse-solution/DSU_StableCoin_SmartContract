// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

interface IPriceFeed {
    function getChainlinkDataFeedLatestAnswer() external view returns (int);
}

contract DSU is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    IPriceFeed public priceFeed;
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    event Mint(address indexed to, uint256 dsuAmount);
    event ETHBurned(address indexed burner, uint256 ethAmount, uint256 usdValue);
    event PriceFeedUpdated(address indexed oldPriceFeed, address indexed newPriceFeed);

    function initialize(address _priceFeedAddress) public initializer {
        __ERC20_init("Dollar Stable Unit", "DSU");
        __ReentrancyGuard_init();

        require(_priceFeedAddress != address(0), "Invalid price feed address");
        priceFeed = IPriceFeed(_priceFeedAddress);
    }

    function reinitialize(address _newPriceFeed) public reinitializer(2) {
        require(_newPriceFeed != address(0), "Invalid price feed");
        priceFeed = IPriceFeed(_newPriceFeed);
        emit PriceFeedUpdated(address(0), _newPriceFeed);
    }

    function getEthUsdPrice() public view returns (uint256) {
        int256 price = priceFeed.getChainlinkDataFeedLatestAnswer();
        require(price > 0, "Invalid ETH/USD price");
        return uint256(price);
    }

    function calculateDsuAmount(uint256 ethAmount) public view returns (uint256) {
        uint256 ethUsdPrice = getEthUsdPrice(); // 8 decimals precision
        return (ethAmount * ethUsdPrice) / 1e8;
    }

    function mintWithEth() external payable nonReentrant {
        require(msg.value > 0, "Must send ETH");
        uint256 dsuAmount = calculateDsuAmount(msg.value);
        require(dsuAmount > 0, "Too small");

        (bool sent, ) = BURN_ADDRESS.call{value: msg.value}("");
        require(sent, "ETH burn failed");

        _mint(msg.sender, dsuAmount);
        emit Mint(msg.sender, dsuAmount);
        emit ETHBurned(msg.sender, msg.value, dsuAmount);
    }

    function updatePriceFeed(address _newPriceFeed) external onlyOwner {
        require(_newPriceFeed != address(0), "Invalid price feed address");
        address old = address(priceFeed);
        priceFeed = IPriceFeed(_newPriceFeed);
        emit PriceFeedUpdated(old, _newPriceFeed);
    }

    function recoverToken(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20Upgradeable(tokenAddress).transfer(owner(), amount);
    }

    function recoverETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Too much");
        (bool sent, ) = owner().call{value: amount}("");
        require(sent, "ETH send failed");
    }

    receive() external payable {}
}
