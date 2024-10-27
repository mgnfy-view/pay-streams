// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IPayStreams {
    struct StreamData {
        address streamer;
        address streamerVault;
        address recipient;
        address recipientVault;
        address token;
        uint256 amount;
        uint256 startingTimestamp;
        uint256 duration;
        uint256 totalStreamed;
        bool recurring;
        bool isPaused;
    }

    struct HookConfig {
        bool callAfterStreamCreated;
        bool callBeforeFundsCollected;
        bool callAfterFundsCollected;
        bool callBeforeStreamUpdated;
        bool callAfterStreamUpdated;
        bool callBeforeStreamClosed;
        bool callAfterStreamClosed;
        bool callBeforeStreamPaused;
        bool callAfterStreamPaused;
        bool callBeforeStreamUnPaused;
        bool callAfterStreamUnPaused;
    }

    event FeeRecipientSet(address newFeeRecipient);
    event FeeInBasisPointsSet(uint16 _feeInBasisPoints);
    event TokenSet(address token, bool support);
    event StreamCreated(bytes32 streamHash);
    event FeesCollected(address token, uint256 amount);
    event VaultSet(address by, bytes32 streamHash, address vault);
    event HookConfigSet(address by, bytes32 streamHash);
    event FundsCollectedFromStream(bytes32 streamHash, uint256 amountToCollect);
    event StreamUpdated(
        bytes32 streamHash, uint256 amount, uint256 startingTimestamp, uint256 duration, bool recurring
    );
    event StreamCancelled(bytes32 streamHash);
    event StreamPaused(bytes32 streamHash);
    event StreamUnPaused(bytes32 streamHash);

    error PayStreams__AddressZero();
    error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
    error PayStreams__UnsupportedToken(address token);
    error PayStreams__InsufficientCollectedFees();
    error PayStreams__InvalidStreamConfig();
    error PayStreams__StreamAlreadyExists(bytes32 streamHash);
    error PayStreams__Unauthorized();
    error PayStreams__StreamHasNotStartedYet(bytes32 streamHash, uint256 startingTimestamp);
    error PayStreams__StreamPaused();
    error PayStreams__ZeroAmountToCollect();
}
