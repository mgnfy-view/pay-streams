// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IPayStreams {
    /**
     * @notice The stream details struct.
     * @param streamer The address of the streamer.
     * @param streamerVault The address of the streamer's vault.
     * @param recipient The address of the recipient.
     * @param recipientVault The address of the recipient's vault.
     * @param token The address of the token to stream.
     * @param amount The amount of the token to stream.
     * @param startingTimestamp The timestamp when the stream begins.
     * @param duration The duration for which the stream lasts.
     * @param totalStreamed The total amount collected by recipient from the stream.
     * @param recurring A bool indicating if the stream is recurring or one-time only.
     */
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
    }

    /**
     * @notice The hook configuration details struct for both streamer and recipient.
     * @param callAfterStreamCreated If set, the afterStreamCreated() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callBeforeFundsCollected If set, the beforeFundsCollected() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callAfterFundsCollected If set, the afterFundsCollected() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callBeforeStreamUpdated If set, the beforeStreamUpdated() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callAfterStreamUpdated If set, the afterStreamUpdated() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callBeforeStreamClosed If set, the beforeStreamClosed() function will be called on
     * the user's vault (if it isn't address(0)).
     * @param callAfterStreamClosed If set, the afterStreamClosed() function will be called on
     * the user's vault (if it isn't address(0)).
     */
    struct HookConfig {
        bool callAfterStreamCreated;
        bool callBeforeFundsCollected;
        bool callAfterFundsCollected;
        bool callBeforeStreamUpdated;
        bool callAfterStreamUpdated;
        bool callBeforeStreamClosed;
        bool callAfterStreamClosed;
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

    error PayStreams__AddressZero();
    error PayStreams__InvalidFeeInBasisPoints(uint16 feeInBasisPoints);
    error PayStreams__UnsupportedToken(address token);
    error PayStreams__InsufficientCollectedFees();
    error PayStreams__InvalidStreamConfig();
    error PayStreams__StreamAlreadyExists(bytes32 streamHash);
    error PayStreams__Unauthorized();
    error PayStreams__StreamHasNotStartedYet(bytes32 streamHash, uint256 startingTimestamp);
    error PayStreams__ZeroAmountToCollect();
}
