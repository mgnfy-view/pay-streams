// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IHooks } from "./interfaces/IHooks.sol";
import { IPayStreams } from "./interfaces/IPayStreams.sol";

contract PyStreams is Ownable, IPayStreams {
    using SafeERC20 for IERC20;

    uint16 private constant BASIS_POINTS = 10_000;

    address private s_feeRecipient;
    uint16 private s_feeInBasisPoints;
    mapping(address token => bool isSupported) private s_supportedTokens;
    mapping(address token => uint256 collectedFees) private s_collectedFees;

    mapping(bytes32 streamHash => StreamData streamData) private s_streamData;
    mapping(address user => mapping(bytes32 streamHash => HookConfig hookConfig)) private s_hookConfig;
    mapping(address streamer => string[] tags) private s_streamerToTags;

    constructor(uint16 _feeInBasisPoints) Ownable(msg.sender) {
        if (_feeInBasisPoints > BASIS_POINTS) revert PayStreams__InvalidFeeInBasisPoints(_feeInBasisPoints);
        s_feeInBasisPoints = _feeInBasisPoints;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        if (_feeRecipient == address(0)) revert PayStreams__AddressZero();
        s_feeRecipient = _feeRecipient;

        emit FeeRecipientSet(_feeRecipient);
    }

    function setFeeInBasisPoints(uint16 _feeInBasisPoints) external onlyOwner {
        if (_feeInBasisPoints > BASIS_POINTS) revert PayStreams__InvalidFeeInBasisPoints(_feeInBasisPoints);
        s_feeInBasisPoints = _feeInBasisPoints;

        emit FeeInBasisPointsSet(_feeInBasisPoints);
    }

    function collectFee(address _token, uint256 _amount) external onlyOwner {
        if (!s_supportedTokens[_token]) revert PayStreams__UnsupportedToken(_token);
        if (s_collectedFees[_token] < _amount) revert PayStreams__InsufficientCollectedFees();

        s_collectedFees[_token] -= _amount;
        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit FeesCollected(_token, _amount);
    }

    function setToken(address _token, bool _support) external onlyOwner {
        if (_token == address(0)) revert PayStreams__AddressZero();

        if (_support) {
            s_supportedTokens[_token] = true;
        } else {
            s_supportedTokens[_token] = false;
        }

        emit TokenSet(_token, _support);
    }

    function createStream(
        StreamData calldata _streamData,
        HookConfig calldata _streamerHookConfig,
        string memory _tag
    )
        external
    {
        if (
            _streamData.streamer != msg.sender || _streamData.recipient == address(0)
                || _streamData.recipientVault != address(0) || !s_supportedTokens[_streamData.token]
                || _streamData.amount == 0 || _streamData.startingTimestamp < block.timestamp || _streamData.duration == 0
                || _streamData.totalStreamed != 0
        ) revert PayStreams__InvalidStreamConfig();

        bytes32 streamHash = getStreamHash(msg.sender, _streamData.recipient, _streamData.token, _tag);
        s_streamData[streamHash] = _streamData;
        s_streamerToTags[msg.sender].push(_tag);
        s_hookConfig[msg.sender][streamHash] = _streamerHookConfig;

        if (_streamerHookConfig.callAfterStreamCreated && _streamData.streamerVault != address(0)) {
            IHooks(_streamData.streamerVault).afterStreamCreated(streamHash);
        }
    }

    function setRecipientVaultForStream(bytes32 _streamHash, address _vault) external {
        StreamData memory streamData = s_streamData[_streamHash];
        if (msg.sender != streamData.recipient) revert PayStreams__Unauthorized();

        s_streamData[_streamHash].recipientVault = _vault;

        emit RecipientVaultSet(msg.sender, _streamHash, _vault);
    }

    function setHookConfigForStream(bytes32 _streamHash, HookConfig calldata _recipientHookConfig) external {
        StreamData memory streamData = s_streamData[_streamHash];
        if (msg.sender != streamData.streamer || msg.sender != streamData.recipient) revert PayStreams__Unauthorized();

        s_hookConfig[msg.sender][_streamHash] = _recipientHookConfig;

        emit HookConfigSet(msg.sender, _streamHash);
    }

    function collectFundsFromStream(bytes32 _streamHash) external {
        StreamData memory streamData = s_streamData[_streamHash];
        if (msg.sender != streamData.recipient) revert PayStreams__Unauthorized();

        if (streamData.startingTimestamp < block.timestamp) {
            revert PayStreams__StreamHasNotStartedYet(_streamHash, streamData.startingTimestamp);
        }
        uint256 amountToCollect = (
            streamData.amount * (block.timestamp - streamData.startingTimestamp) / streamData.duration
        ) - streamData.totalStreamed;
        if (amountToCollect > streamData.amount) amountToCollect = streamData.amount - streamData.totalStreamed;

        s_streamData[_streamHash].totalStreamed += amountToCollect;

        HookConfig memory streamerHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        HookConfig memory recipientHookConfig = s_hookConfig[streamData.streamer][_streamHash];
        if (streamData.streamerVault != address(0)) {
            if (streamerHookConfig.callBeforeFundsCollected) {
                IHooks(streamData.streamerVault).beforeFundsCollected(_streamHash);
            }
        }
        if (streamData.recipientVault != address(0)) {
            if (recipientHookConfig.callBeforeFundsCollected) {
                IHooks(streamData.streamerVault).beforeFundsCollected(_streamHash);
            }
        }
        if (streamData.streamerVault != address(0)) {
            streamData.recipientVault != address(0)
                ? IERC20(streamData.token).safeTransferFrom(
                    streamData.streamerVault, streamData.recipientVault, amountToCollect
                )
                : IERC20(streamData.token).safeTransferFrom(streamData.streamerVault, streamData.recipient, amountToCollect);
        } else {
            streamData.recipientVault != address(0)
                ? IERC20(streamData.token).safeTransferFrom(streamData.streamer, streamData.recipientVault, amountToCollect)
                : IERC20(streamData.token).safeTransferFrom(streamData.streamer, streamData.recipient, amountToCollect);
        }
        if (streamData.streamerVault != address(0)) {
            if (streamerHookConfig.callAfterFundsCollected) {
                IHooks(streamData.streamerVault).afterFundsCollected(_streamHash);
            }
        }
        if (streamData.recipientVault != address(0)) {
            if (recipientHookConfig.callAfterFundsCollected) {
                IHooks(streamData.streamerVault).afterFundsCollected(_streamHash);
            }
        }

        emit FundsCollectedFromStream(_streamHash, amountToCollect);
    }

    function getFeeRecipient() external view returns (address) {
        return s_feeRecipient;
    }

    function getFeeInBasisPoints() external view returns (uint256) {
        return s_feeInBasisPoints;
    }

    function isSupportedToken(address _token) external view returns (bool) {
        return s_supportedTokens[_token];
    }

    function getCollectedFees(address _token) external view returns (uint256) {
        return s_collectedFees[_token];
    }

    function getStreamData(bytes32 _streamHash) external view returns (StreamData memory) {
        return s_streamData[_streamHash];
    }

    function getHookConfig(address _user, bytes32 _streamHash) external view returns (HookConfig memory) {
        return s_hookConfig[_user][_streamHash];
    }

    function getTags(address _streamer) external view returns (string[] memory) {
        return s_streamerToTags[_streamer];
    }

    function getStreamHash(
        address _streamer,
        address _recipient,
        address _token,
        string memory _tag
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_streamer, _recipient, _token, _tag));
    }
}
