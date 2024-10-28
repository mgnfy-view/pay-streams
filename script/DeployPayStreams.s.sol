// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";

import { PayStreams } from "../src/PayStreams.sol";

contract DeployPayStreams is Script {
    uint16 feeInBasisPoints = 10;
    address public constant PYUSD = 0xCaC524BcA292aaade2DF8A05cC58F0a65B1B3bB9;

    function run() external returns (address) {
        vm.startBroadcast();
        PayStreams stream = new PayStreams(feeInBasisPoints);
        stream.setToken(PYUSD, true);
        vm.stopBroadcast();

        return address(stream);
    }
}
