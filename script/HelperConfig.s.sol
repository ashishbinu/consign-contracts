// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

contract HelperConfig is Script {
    uint256 public constant ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function getPrivateKey() public view returns (uint256) {
        if (block.chainid == 69420) return ANVIL_DEFAULT_KEY;

        return vm.envUint("PRIVATE_KEY");
    }
}
