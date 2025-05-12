// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPriceFeed {
    function getChainlinkDataFeedLatestAnswer() external view returns (int);
    function latestAnswer() external view returns (int);
}


contract DSUStablecoin is ERC20, Ownable {
    IPriceFeed public priceFeed;
    bool public ethIsNative;
    address public ETHAddress;
    address public feeReceiver;
    uint256 public fee;
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    event Mint(address indexed to, uint256 dsuAmount);
    event ETHBurned(address indexed burner, uint256 ethAmount, uint256 usdValue);
    event PriceFeedUpdated(address indexed oldPriceFeed, address indexed newPriceFeed);

    constructor(address _priceFeedAddress, address _feeReceiver, bool _ethIsNative, address _ethAddress) ERC20("Dollar Stable Unit", "DSU") Ownable(msg.sender) {
        
        require(_priceFeedAddress != address(0), "Invalid price feed address");
        if (!_ethIsNative) {
            require(_ethAddress != address(0), "Invalid ETH token address");
        }
        
        priceFeed = IPriceFeed(_priceFeedAddress);
        ethIsNative = _ethIsNative;
        ETHAddress = _ethAddress;
        feeReceiver = _feeReceiver;
        fee = 1000;
    }


    function getEthUsdPrice() public view returns (uint256) {

        int256 price;

        if(ethIsNative) {
            price = priceFeed.latestAnswer();
        } else {
            price = priceFeed.getChainlinkDataFeedLatestAnswer();
        }

        require(price > 0, "Invalid ETH/USD price");
        return uint256(price);
    }

    function calculateDsuAmount(uint256 ethAmount) public view returns (uint256) {
        uint256 ethUsdPrice = getEthUsdPrice(); // 8 decimals precision
        return (ethAmount * ethUsdPrice) / 1e8;
    }

    function mintWithEth(uint256 _ethAmount) external payable {
        uint256 dsuAmount;
        uint256 totalAmount;

        if (ethIsNative) {
            require(msg.value > 0, "Must send ETH");
            uint256 ethFeeAmount = msg.value / fee;
            uint256 ethBurnAmount = msg.value - ethFeeAmount;

            dsuAmount = calculateDsuAmount(ethBurnAmount);
            require(dsuAmount > 0, "Too small");
            totalAmount = msg.value;

            (bool sent, ) = BURN_ADDRESS.call{value: ethBurnAmount}("");
            payable(feeReceiver).transfer(ethFeeAmount);
            require(sent, "ETH burn failed");   
        } else {
            // Using token ETH (like WETH)
            require(ETHAddress != address(0), "ETH token not set");
            require(msg.value == 0, "Native ETH not accepted");
            
            // Get token amount from user approval
            IERC20 ethToken = IERC20(ETHAddress);
            uint256 allowance = ethToken.allowance(msg.sender, address(this));
            require(allowance > _ethAmount, "Must approve ETH tokens");
            
            uint256 ethFeeAmount = _ethAmount / fee;
            uint256 ethBurnAmount = _ethAmount - ethFeeAmount;
            totalAmount = _ethAmount;
            
            dsuAmount = calculateDsuAmount(ethBurnAmount);
            require(dsuAmount > 0, "Too small");
            
            // Transfer tokens from user to this contract
            require(ethToken.transferFrom(msg.sender, address(this), _ethAmount), "Token transfer failed");
            
            // Burn 99% of tokens
            require(ethToken.transfer(BURN_ADDRESS, ethBurnAmount), "Token burn failed");
            
            // Return 1% fee to user
            require(ethToken.transfer(feeReceiver, ethFeeAmount), "Fee transfer failed");
        }

        _mint(msg.sender, dsuAmount);
        emit Mint(msg.sender, dsuAmount);
        emit ETHBurned(msg.sender, totalAmount, dsuAmount);
    }

    function updatePriceFeed(address _newPriceFeed) external onlyOwner {
        require(_newPriceFeed != address(0), "Invalid price feed address");
        address old = address(priceFeed);
        priceFeed = IPriceFeed(_newPriceFeed);
        emit PriceFeedUpdated(old, _newPriceFeed);
    }

    function updateEthAddress(address _newEthAddress) external onlyOwner {
        require(_newEthAddress != address(0), "Invalid ETH address");
        ETHAddress = _newEthAddress;
    }

    function updateFeeReceiver(address _feeReceiver) external onlyOwner() {
        require(_feeReceiver != address(0), "Invalid FeeReceiver address");
        feeReceiver = _feeReceiver;
    }

    function updateFee(uint256 _fee) external onlyOwner() {
        require(_fee > 1, "Fee must be greater than 1");
        fee = _fee;
    }
    
    function toggleEthIsNative() external onlyOwner {
        if (!ethIsNative) {
            require(ETHAddress != address(0), "ETH token not set");
        }
        ethIsNative = !ethIsNative;
    }

    function recoverToken(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), amount);
    }

    function recoverETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Too much");
        (bool sent, ) = owner().call{value: amount}("");
        require(sent, "ETH send failed");
    }

    receive() external payable {}
}
