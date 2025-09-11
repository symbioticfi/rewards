// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Mock vault contract that implements Ownable
contract MockVault is Ownable {
    constructor(
        address owner
    ) Ownable(owner) {}
}
