// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { GlobalHelper } from "../utils/GlobalHelper.sol";

contract PayStreamsAdminControlsTest is GlobalHelper {
    function test_setFeeInBasisPoints() public {
        uint16 newFee = 100; // 1%

        _setFee(newFee);

        assertEq(stream.getFeeInBasisPoints(), newFee);
    }

    function test_setGasLimitForHooks() public {
        uint256 newGasLimit = 1_000_000;

        _setGasLimitForHooks(newGasLimit);

        assertEq(stream.getGasLimitForHooks(), newGasLimit);
    }

    function test_collectFeesFromStream() public {
        uint16 newFee = 100; // 1%

        _setFee(newFee);

        (IPayStreams.StreamData memory streamData, IPayStreams.HookConfig memory hookConfig, string memory tag) =
            _getTestStreamCreationData();
        _mintAndApprove(streamData.amount);
        vm.startPrank(streamer);
        bytes32 streamHash = stream.setStream(streamData, hookConfig, tag);
        vm.stopPrank();

        _warpBy(streamData.duration);
        stream.collectFundsFromStream(streamHash);

        uint256 expectedFeeAmount = (streamData.amount * newFee) / BPS;
        assertEq(token.balanceOf(address(stream)), expectedFeeAmount);

        vm.startPrank(deployer);
        stream.collectFees(address(token), expectedFeeAmount);
        vm.stopPrank();
        assertEq(token.balanceOf(address(deployer)), expectedFeeAmount);
        assertEq(token.balanceOf(address(stream)), 0);
    }
}
