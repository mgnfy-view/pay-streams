// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Test } from "forge-std/Test.sol";

import { IPayStreams } from "../../src/interfaces/IPayStreams.sol";

import { PayStreams } from "../../src/PayStreams.sol";
import { MockToken } from "./MockToken.sol";

contract GlobalHelper is Test {
    address public deployer;
    address public streamer;
    address public recipient;
    string public tokenName = "PayPal USD";
    string public tokenSymbol = "PYUSD";
    MockToken public token;

    uint16 public fee;
    uint256 public gasLimitForHooks;

    PayStreams public stream;

    uint256 public amount = 100e6;
    uint256 public duration = 10 days;
    bool public recurring = false;

    uint16 public constant BPS = 10_000;

    function setUp() public {
        deployer = makeAddr("deployer");
        streamer = makeAddr("streamer");
        recipient = makeAddr("recipient");
        token = new MockToken(tokenName, tokenSymbol);

        gasLimitForHooks = 100_000;

        vm.startPrank(deployer);
        stream = new PayStreams(fee, gasLimitForHooks);
        vm.stopPrank();
    }

    function _getTestStreamCreationData()
        internal
        returns (IPayStreams.StreamData memory, IPayStreams.HookConfig memory, string memory)
    {
        IPayStreams.StreamData memory streamData = IPayStreams.StreamData({
            streamer: streamer,
            streamerVault: address(0),
            recipient: recipient,
            recipientVault: address(0),
            token: address(token),
            amount: amount,
            startingTimestamp: block.timestamp,
            duration: duration,
            totalStreamed: 0,
            recurring: recurring
        });
        IPayStreams.HookConfig memory hookConfig = IPayStreams.HookConfig({
            callAfterStreamCreated: false,
            callBeforeFundsCollected: false,
            callAfterFundsCollected: false,
            callBeforeStreamUpdated: false,
            callAfterStreamUpdated: false,
            callBeforeStreamClosed: false,
            callAfterStreamClosed: false
        });
        string memory tag = "test stream";

        return (streamData, hookConfig, tag);
    }

    function _setFee(uint16 _newFee) internal {
        vm.startPrank(deployer);
        stream.setFeeInBasisPoints(_newFee);
        vm.stopPrank();
    }

    function _setGasLimitForHooks(uint256 _newGasLimit) internal {
        vm.startPrank(deployer);
        stream.setGasLimitForHooks(_newGasLimit);
        vm.stopPrank();
    }

    function _mintAndApprove(uint256 _amount) internal {
        token.mint(streamer, _amount);

        vm.startPrank(streamer);
        token.approve(address(stream), _amount);
        vm.stopPrank();
    }

    function _warpBy(uint256 _duration) internal {
        vm.warp(block.timestamp + _duration);
    }
}
