// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.0 <0.9.0;

import "./ETHKabuso.sol";
import {IVerifier} from "./Kabuso.sol";
import {IHasher} from "./MerkleTreeWithHistory.sol";

contract KabusoFactory {

    function deploy(
        IVerifier _verifier,
        IHasher _hasher,
        uint256 _denomination,
        uint32 _merkleTreeHeight
    ) public returns (address){
        ETHKabuso kabuso = new ETHKabuso(_verifier, _hasher, _denomination, _merkleTreeHeight, address(this));
        return address(kabuso);       
    }

    
}