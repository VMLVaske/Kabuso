// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Kabuso.sol";
import "./KabusoFactory.sol";

contract ETHKabuso is Kabuso {

    event Redeploy(address nextAddress, uint blocknumber);

    uint public startingBlock;

    constructor(
        IVerifier _verifier,
        IHasher _hasher,
        uint256 _denomination,
        uint32 _merkleTreeHeight,
        address _factoryAddress
    ) Kabuso(_verifier, _hasher, _denomination, _merkleTreeHeight, _factoryAddress) {
        // Initialize startingBlock to the current block number
        startingBlock = readBlockNumber();
    }

    modifier blockcycle_complete {
        require(block.number >= startingBlock + 200, "Block cycle not complete");
        _;
    }

    function _processDeposit() internal override {
        require(msg.value == denomination, "Please send `mixDenomination` ETH along with transaction");
    }

    function _processWithdraw(
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) internal override {
        // sanity checks
        require(msg.value == 0, "Message value is supposed to be zero for ETH instance");
        require(_refund == 0, "Refund value is supposed to be zero for ETH instance");

        (bool success, ) = _recipient.call{ value: denomination - _fee }("");
        require(success, "Payment to _recipient did not go through");
        if (_fee > 0) {
            (success, ) = _relayer.call{ value: _fee }("");
            require(success, "Payment to _relayer did not go through");
        }
    }

    function readBlockNumber() public view returns (uint) {
        return Kabuso.blocknumber;
    }

    // Only callable after 200 block
    function reDeploy() public override blockcycle_complete {
        KabusoFactory factory = KabusoFactory(factoryAddress);
        address newDeployAddress = factory.deploy(verifier, hasher, denomination, levels);

        emit Redeploy(newDeployAddress, block.number);
    }
}
