// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";

import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IPayStreams } from "../interfaces/IPayStreams.sol";

import { BaseVault } from "../utils/BaseVault.sol";

/**
 * @title PaymentSplitterVault.
 * @author mgnfy-view.
 * @notice A payment splitter vault that splits any streamed payment among a
 * list of recipients.
 */
contract PaymentSplitterVault is BaseVault {
    using SafeERC20 for IERC20;

    address private s_payStreams;
    address[] private s_recipients;

    event PaymentSplit(uint256 indexed amount, address[] indexed recipients);
    event RecipientListUpdated(address[] indexed recipients);

    error PaymentSplitterVault__NotPayStream();

    modifier onlyPayStreams() {
        if (msg.sender != address(s_payStreams)) revert PaymentSplitterVault__NotPayStream();
        _;
    }

    constructor(address _payStreams, address[] memory _recipients) {
        s_payStreams = _payStreams;
        s_recipients = _recipients;
    }

    /**
     * @notice Once funds have been received by this vault, this function is invoked by the
     * payStreams contract to split the streamed funds among multiple recipients.
     * @param _streamHash The hash of the stream.
     * @param _amount The amount along with the fee.
     * @param _feeAmount The fee collected from the streamed amount.
     */
    function afterFundsCollected(
        bytes32 _streamHash,
        uint256 _amount,
        uint256 _feeAmount
    )
        external
        override
        onlyPayStreams
    {
        address token = IPayStreams(s_payStreams).getStreamData(_streamHash).token;
        address[] memory recipients = s_recipients;
        uint256 numberOfRecipients = recipients.length;
        uint256 amountPerRecipient = (_amount - _feeAmount) / numberOfRecipients;

        for (uint256 i; i < numberOfRecipients; ++i) {
            IERC20(token).safeTransfer(recipients[i], amountPerRecipient);
        }

        emit PaymentSplit(_amount - _feeAmount, recipients);
    }

    /**
     * @notice Allows the owner to update the recipient list.
     * @param _recipients The new list of recipients.
     */
    function updateRecipientList(address[] memory _recipients) external onlyOwner {
        s_recipients = _recipients;

        emit RecipientListUpdated(_recipients);
    }
}
