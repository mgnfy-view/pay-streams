// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";

import { PayStreams } from "../src/PayStreams.sol";

contract DeployPayStreams is Script {
    uint16 feeInBasisPoints = 10;

    function run() external returns (address) {
        vm.startBroadcast();
        PayStreams stream = new PayStreams(feeInBasisPoints);
        vm.stopBroadcast();

        return address(stream);
    }
}
