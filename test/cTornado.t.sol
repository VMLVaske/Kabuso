pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Verifier} from "src/Verifier.sol";
import {IHasher} from "src/MerkleTreeWithHistory.sol";
import {HuffDeployer} from "lib/foundry-huff/src/HuffDeployer.sol";
import {ETHTornado} from "src/ETHTornado.sol";

contract TornadoTest is Test {
    ETHTornado tornado;
    uint256 etherFork;

    function setUp() public {
        etherFork = vm.createFork("https://api.securerpc.com/v1");
        vm.selectFork(etherFork);

        tornado = new ETHTornado(
            new Verifier(),
            IHasher(0x83584f83f26aF4eDDA9CBe8C730bc87C364b28fe),
            1 ether,
            20
        );
    }

    function testConsole() public {
        console2.log("Hello, World!");
    }

    // Fork a specific block height, aka mainnet where tornado cash is deployed
    // Using this we can test whether a newly deployed contract with a new address might still access the old pools funds and promises
}

// Test Case Ideas

// Deposit
// 1 ETH deposits require 1.0002
