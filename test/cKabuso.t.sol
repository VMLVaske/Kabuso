pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import {Verifier} from "src/Verifier.sol";
import {IHasher} from "src/MerkleTreeWithHistory.sol";
import {HuffDeployer} from "lib/foundry-huff/src/HuffDeployer.sol";
import {ETHKabuso} from "src/ETHKabuso.sol";

contract KabusoTest is Test {
    ETHKabuso kabuso;
    IHasher deployedMiMCSponge =
        IHasher(0x83584f83f26aF4eDDA9CBe8C730bc87C364b28fe);
    address optimizedMiMCSpongeAddress;

    event Deposit(
        bytes32 indexed commitment,
        uint32 leafIndex,
        uint256 timestamp
    );
    event Withdrawal(
        address to,
        bytes32 nullifierHash,
        address indexed relayer,
        uint256 fee
    );

    function setUp() public {
        uint256 etherFork = vm.createFork("https://api.securerpc.com/v1");
        vm.selectFork(etherFork);

        // deploy the EthKabuso Contract
        kabuso = new ETHKabuso(
            new Verifier(),
            IHasher(0x83584f83f26aF4eDDA9CBe8C730bc87C364b28fe),
            1 ether,
            20,
            address(0x124245)
        );
    }

    function testConsole() public pure {
        console2.log("Setting up deployment successful");
    }

    function testDeposit() public {
        // Address to act as the sender
        address depositorA = address(0x123);
        address depositorB = address(0xffff);
        address withdrawer = address(0x456);

        // Set the balance of the depositor address
        vm.deal(depositorA, 10 ether);
        vm.deal(depositorB, 10 ether);

        // Start acting as the depositor
        vm.startPrank(depositorA);

        // Call the JavaScript script and get the result
        string[] memory inputs = new string[](2);
        inputs[0] = "node";
        inputs[1] = "helpers/createDeposit.js";

        bytes memory comMem = vm.ffi(inputs);
        bytes32 commitment = abi.decode(comMem, (bytes32));

        // cast commitment to bytes32
        bytes32 testCommitment = commitment;

        vm.recordLogs();

        uint32 leafIndex = 0;

        // Expect the event to be emitted
        vm.expectEmit(true, true, false, true);
        emit Deposit(testCommitment, leafIndex, block.timestamp);
        //bytes32 indexed commitment,uint32 leafIndex,uint256 timestamp

        leafIndex++;

        // Deposit 1 ether + use testCommitment in deposit call
        kabuso.deposit{value: 1 ether}(testCommitment);

        // ---------- WITHDRAW ----------

        // Start acting as the depositor
        vm.startPrank(withdrawer);

        // Call the JavaScript script and get the result
        string[] memory noteInputs = new string[](2);
        noteInputs[0] = "node";
        noteInputs[1] = "helpers/note.js";
        /* noteInputs[2] = address(withdrawer); */

        // need to pass a list of recorded deposit events from the contract history to withdraw
        Vm.Log[] memory entries = vm.getRecordedLogs();

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
