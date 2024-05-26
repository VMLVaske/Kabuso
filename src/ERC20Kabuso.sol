// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Kabuso.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ERC20Kabuso is Kabuso {
  using SafeERC20 for IERC20;
  IERC20 public token;

  constructor(
    IVerifier _verifier,
    IHasher _hasher,
    uint256 _denomination,
    uint32 _merkleTreeHeight,
    IERC20 _token,
    address _factoryAddress
  ) Kabuso(_verifier, _hasher, _denomination, _merkleTreeHeight, _factoryAddress) {
    token = _token;
  }

  function _processDeposit() internal override {
    require(msg.value == 0, "ETH value is supposed to be 0 for ERC20 instance");
    token.safeTransferFrom(msg.sender, address(this), denomination);
  }

  function _processWithdraw(
    address payable _recipient,
    address payable _relayer,
    uint256 _fee,
    uint256 _refund
  ) internal override {
    require(msg.value == _refund, "Incorrect refund amount received by the contract");

    token.safeTransfer(_recipient, denomination - _fee);
    if (_fee > 0) {
      token.safeTransfer(_relayer, _fee);
    }

    if (_refund > 0) {
      (bool success, ) = _recipient.call{ value: _refund }("");
      if (!success) {
        // let's return _refund back to the relayer
        _relayer.transfer(_refund);
      }
    }
  }

  function reDeploy() 
  
  public override {


  }

}
