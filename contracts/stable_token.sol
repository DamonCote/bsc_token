// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Collateralized Basic Stable Token contract
contract CollateralizedStableCoin {
    string public name = "Collateralized Coffee Stable Token";
    string public symbol = "CCST";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public collateralizationRatio = 150; // 150% collateralization

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public collateralBalance;

    // Event declarations
    event Mint(address indexed user, uint256 amount, uint256 collateral);
    event Burn(address indexed user, uint256 amount, uint256 collateralReturned);

    /**
        * @dev Deposit collateral and mint stablecoins based on the collateralization ratio.
        * The user must send Ether as collateral, which will be locked in the contract.
        * The amount of stablecoins minted is determined by the collateralization ratio.
     */
    function depositCollateralAndMint() external payable {
        require(msg.value > 0, "Collateral must be greater than zero");

        // Calculate how much stablecoin can be minted based on the collateralization ratio
        uint256 mintAmount = (msg.value * 100) / collateralizationRatio;
        balanceOf[msg.sender] += mintAmount;
        collateralBalance[msg.sender] += msg.value;
        totalSupply += mintAmount;

        emit Mint(msg.sender, mintAmount, msg.value);
    }

    /**
        * @dev Burn stablecoins and withdraw the corresponding amount of collateral.
        * The user must have enough stablecoins to burn, and the contract will return
        * the collateral based on the collateralization ratio.
     */
    function burnAndWithdrawCollateral(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient stablecoin balance");
        uint256 collateralToReturn = (amount * collateralizationRatio) / 100;

        require(collateralBalance[msg.sender] >= collateralToReturn, "Insufficient collateral balance");

        // Burn stablecoins and update balances
        balanceOf[msg.sender] -= amount;
        collateralBalance[msg.sender] -= collateralToReturn;
        totalSupply -= amount;

        // Transfer collateral back to the user
        (bool success, ) = msg.sender.call{value: collateralToReturn}("");
        require(success, "Collateral transfer failed");

        emit Burn(msg.sender, amount, collateralToReturn);
    }
}