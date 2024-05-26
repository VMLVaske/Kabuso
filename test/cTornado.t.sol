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

        // deploy the EthTornado Contract
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

    function testDeposit() public {
        // Address to act as the sender
        address depositor = address(0x123);
        address withdrawer = address(0x456);

        // Set the balance of the depositor address
        vm.deal(depositor, 10 ether);

        // Start acting as the depositor
        vm.startPrank(depositor);

        // Call the JavaScript script and get the result
        string[] memory inputs = new string[](2);
        inputs[0] = "node";
        inputs[1] = "helpers/createDeposit.js";

        bytes memory comMem = vm.ffi(inputs);
        bytes32 commitment = abi.decode(comMem, (bytes32));

        // cast commitment to bytes32
        bytes32 testCommitment = commitment;

        // Deposit 1 ether + use testCommitment in deposit call
        tornado.deposit{value: 1 ether}(testCommitment);

        // ---

        // ---------- WITHDRAW ----------

        // Start acting as the depositor
        vm.startPrank(withdrawer);

        // Call the JavaScript script and get the result
        string[] memory inputs1 = new string[](2);
        inputs1[0] = "node";
        inputs1[1] = "helpers/note.js";
        /* inputs1[2] = address(withdrawer); */

        /*  bytes memory noteMem = vm.ffi(inputs);
        bytes32 note = abi.decode(noteMem, (bytes32)); */

        /* tornado.withdraw{}(proof, ...args); */

        // Stop acting as the depositor
        vm.stopPrank();
    }

    function testRedeployDeactivated() public {
        // calling the 'redeploy' function will result in a revert if blocks haven't passed
    }

    function testWarp() public {
        // warp 2 weeks / 20160 blocks
        vm.warp(20160);

        // calling of 'redeploy' function should work - new contract address should be returned?
    }

    function testDisabled() public {
        // after redeploy of new contract, deposit and withdrawal should be disabled
        // call "deposit" function should revert
        // call withdraw function should revert
    }

    function testNewWithdraw() public {
        // after redeploy of new contract, withdraw function on new contract with old promise should work
    }
}
