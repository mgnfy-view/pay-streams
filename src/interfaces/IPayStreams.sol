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
    }

    struct HookConfig {
        bool callAfterStreamCreated;
        bool callBeforeFundsCollected;
        bool callAfterFundsCollected;
    }

    event FeeRecipientSet(address newFeeRecipient);
    event FeeInBasisPointsSet(uint16 _feeInBasisPoints);
    event TokenSet(address token, bool support);
    event FeesCollected(address token, uint256 amount);
    event StreamCreated(address by, bytes32 streamHash, string tag);
    event RecipientVaultSet(address by, bytes32 streamHash, address vault);
    event HookConfigSet(address by, bytes32 streamHash);
    event FundsCollectedFromStream(bytes32 streamHash, uint256 amountToCollect);

    error PayStreams__AddressZero();
    error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
    error PayStreams__UnsupportedToken(address token);
    error PayStreams__InsufficientCollectedFees();
    error PayStreams__InvalidStreamConfig();
    error PayStreams__Unauthorized();
    error PayStreams__StreamHasNotStartedYet(bytes32 streamHash, uint256 startingTimestamp);
}
