// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IPayStreams {
    struct StreamData {
        address streamer;
        address recipient;
        address token;
        uint256 amount;
        uint256 startingTimestamp;
    }

    event FeeRecipientSet(address newFeeRecipient);
    event FeeInBasisPointsSet(uint16 _feeInBasisPoints);
    event TokenSet(address token, bool support);
    event FeesCollected(address token, uint256 amount);

    error PayStreams__AddressZero();
    error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
    error PayStreams__UnsupportedToken(address token);
    error PayStreams__InsufficientCollectedFees();
}
