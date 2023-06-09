// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

// Created by @tunnckoCore / @wgw_eth / wgw.eth

import "./WTF20.sol";

contract WTFDeployer {
    // the deployer of the TokenDepoyer
    address public immutable deployer = msg.sender;

    event ERC20TokenCreated(
        address deployedAt,
        string name,
        string symbol,
        uint256 supply,
        address creator
    );

    function deployToken(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply
    ) public returns (address) {
        return deployTokenCustom(name, symbol, initialSupply, 5848);
    }

    function deployTokenWithSalt(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply,
        uint256 salt
    ) public returns (address) {
        return deployTokenCustom(name, symbol, initialSupply, salt);
    }

    function deployTokenCustom(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply,
        uint256 salt
    ) public returns (address) {
        WTF20 token = new WTF20{salt: bytes32(salt)}(name, symbol);

        uint256 supply = initialSupply * 10 ** WTF20(token).decimals();
        uint256 onePercent = supply / 100;

        // Mint 1% to the service, 99% to the caller (creator/deployer of this token)
        WTF20(token).mint(deployer, onePercent);
        WTF20(token).mint(msg.sender, supply - onePercent);

        // immediately renounce the ownership of the created token,
        // so that no one owns it, even this deployer contract, nor the caller/creator/minter
        WTF20(token).renounceOwnership();

        emit ERC20TokenCreated(
            address(token),
            name,
            symbol,
            supply,
            msg.sender
        );

        return address(token);
    }
}
