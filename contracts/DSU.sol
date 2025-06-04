// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IPriceFeed {
    function latestAnswer() external view returns (int);
}


contract DSUStablecoin is ERC20, Ownable, ReentrancyGuard {
    IPriceFeed public priceFeed;
    address public feeReceiver;
    address public usdtAddress;
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    event Mint(address indexed to, uint256 dsuAmount);

    constructor(address _priceFeedAddress, address _usdtAddress) ERC20("Dollar Stable Unit", "DSU") Ownable(msg.sender) ReentrancyGuard() {
        
        priceFeed = IPriceFeed(_priceFeedAddress);
        feeReceiver = msg.sender;
        usdtAddress = _usdtAddress;
    }

    function getPrice() public view returns (uint256) {

        int256 price = priceFeed.latestAnswer();

        require(price > 0, "Invalid price");
        return uint256(price);
    }

    function calculateDsuAmount(uint256 amount) public view returns (uint256) {
        uint256 price = getPrice(); // 8 decimals precision
        return (amount * price) / 1e8;
    }

    function mintDSU(uint256 _amount) external payable nonReentrant {
        uint256 dsuAmount;

        if(msg.value > 0) {
            require(_amount == 0, "Cannot specify amount with ETH");
            dsuAmount = calculateDsuAmount(msg.value);
            require(dsuAmount > 0, "Too small");

            uint256 feeAmount = msg.value / 10000;
            uint256 burnAmount = msg.value - feeAmount;

            (bool sent, ) = BURN_ADDRESS.call{value: burnAmount}("");
            payable(feeReceiver).transfer(feeAmount);
            require(sent, "Burn failed");
            
        } else {
            require(_amount > 0, "Must specify amount");

            dsuAmount = _amount;

            // Get token amount from user approval
            IERC20 usdt = IERC20(usdtAddress);
            uint256 allowance = usdt.allowance(msg.sender, address(this));
            require(allowance > _amount, "Must approve USDT tokens");
            
            uint256 feeAmount = _amount / 10000;
            uint256 burnAmount = _amount - feeAmount;
            
            require(usdt.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
            
            require(usdt.transfer(BURN_ADDRESS, burnAmount), "Token burn failed");
            
            require(usdt.transfer(feeReceiver, feeAmount), "Fee transfer failed");
        }   
    
        _mint(msg.sender, dsuAmount);
        emit Mint(msg.sender, dsuAmount);
    }
    

    function transfer(address to, uint256 value) public override virtual returns (bool) {

        uint256 feeAmount = value / 10000;
        
        _transfer(_msgSender(), feeReceiver, feeAmount);
        _transfer(_msgSender(), to, value - feeAmount);
        
        return true;
    }

    receive() external payable {}
}
