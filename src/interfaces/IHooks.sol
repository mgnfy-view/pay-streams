// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IHooks {
    function afterStreamCreated(bytes32 _streamHash) external;

    function beforeFundsCollected(bytes32 _streamHash) external;

    function afterFundsCollected(bytes32 _streamHash) external;
}
