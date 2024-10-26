// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IPayStreams } from "./interfaces/IPayStreams.sol";

contract PyStreams is Ownable, IPayStreams {
    using SafeERC20 for IERC20;

    uint16 private constant BASIS_POINTS = 10_000;

    address private s_feeRecipient;
    uint16 private s_feeInBasisPoints;
    mapping(address token => bool isSupported) private s_supportedTokens;
    mapping(address token => uint256 collectedFees) private s_collectedFees;

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
}
