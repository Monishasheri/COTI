// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@coti-io/coti-contracts/contracts/utils/mpc/MpcCore.sol";

contract PrivateStorage {
    ctUint64 public privateNumber;
    ctUint64 public addResult;
    ctUint64 public reserve1;
    ctUint64 public reserve2;
    ctUint64 public ctOutputB;

    constructor() {
        gtUint64 gtR1 = MpcCore.setPublic64(1000);
        gtUint64 gtR2 = MpcCore.setPublic64(1000);
        reserve1 = MpcCore.offBoard(gtR1);
        reserve2 = MpcCore.offBoard(gtR2);
    }
    function setPrivateNumber(itUint64 calldata value) external {
        gtUint64 gtNumber = MpcCore.validateCiphertext(value);

        privateNumber = MpcCore.offBoardToUser(gtNumber, msg.sender);
    }
    function add(itUint64 calldata value1, itUint64 calldata value2) external {
        gtUint64 _value1 = MpcCore.validateCiphertext(value1);
        gtUint64 _value2 = MpcCore.validateCiphertext(value2);
        gtUint64 res = MpcCore.add(_value1, _value2);
        addResult = MpcCore.offBoardToUser(res, msg.sender);
    }

    function swap(itUint64 calldata inputA) external {
        gtUint64 gtInputA = MpcCore.validateCiphertext(inputA);

        gtUint64 gtR1 = MpcCore.onBoard(reserve1);
        gtUint64 gtR2 = MpcCore.onBoard(reserve2);

        gtUint64 newR1 = MpcCore.add(gtR1, gtInputA);
        gtUint64 k = MpcCore.mul(gtR1, gtR2);
        gtUint64 newR2 = MpcCore.div(k, newR1);
        gtUint64 outputB = MpcCore.sub(gtR2, newR2);

        reserve1 = MpcCore.offBoard(newR1);
        reserve2 = MpcCore.offBoard(newR2);
        ctOutputB = MpcCore.offBoardToUser(outputB, msg.sender);
    }
}
