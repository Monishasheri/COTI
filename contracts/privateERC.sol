// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@coti-io/coti-contracts/contracts/token/PrivateERC20/PrivateERC20.sol";
import "@coti-io/coti-contracts/contracts/utils/mpc/MpcCore.sol";

contract MyPrivateToken is PrivateERC20 {
    constructor() PrivateERC20("Private COTI", "TokenB") {
        // Set initial supply as public, then offboard to ciphertext
        gtUint64 initial = MpcCore.setPublic64(100000);
        // Mint expects a gtUint64, so use 'initial' directly
        _mint(msg.sender, initial);
    }

    function encryptedTransfer(
        address to,
        itUint64 calldata value
    ) external returns (ctBool) {
        gtUint64 gtvalue = MpcCore.validateCiphertext(value);
        gtBool result = transfer(to, gtvalue);
        return MpcCore.offBoardToUser(result, msg.sender);
    }

    function balanceOfEncrypted(address account) external returns (gtUint64) {
        ctUint64 ctBalance = balanceOf(account);
        gtUint64 gtBalance = MpcCore.onBoard(ctBalance);
        return gtBalance;
    }
    
}
