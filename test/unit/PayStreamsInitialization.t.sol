// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { GlobalHelper } from "../utils/GlobalHelper.sol";

contract PayStreamsInitializationTest is GlobalHelper {
    function test_checkFee() public view {
        assertEq(stream.getFeeInBasisPoints(), fee);
    }

    function test_checkGasLimitForHooks() public view {
        assertEq(stream.getGasLimitForHooks(), gasLimitForHooks);
    }
}
