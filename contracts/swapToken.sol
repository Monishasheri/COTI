// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@coti-io/coti-contracts/contracts/utils/mpc/MpcCore.sol";
import "@coti-io/coti-contracts/contracts/token/PrivateERC20/IPrivateERC20.sol";

contract PrivateSwap {
    IPrivateERC20 public tokenA;
    IPrivateERC20 public tokenB;
    ctUint64 public ctOutputB;
    ctUint64 public reserve1;
    ctUint64 public reserve2;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IPrivateERC20(_tokenA);
        tokenB = IPrivateERC20(_tokenB);
        gtUint64 zero = MpcCore.setPublic64(0);
        reserve1 = MpcCore.offBoard(zero);
        reserve2 = MpcCore.offBoard(zero);
    }
    function addLiquidity(
        itUint64 calldata amountA,
        itUint64 calldata amountB
    ) external {
        gtUint64 gtAmountA = MpcCore.validateCiphertext(amountA);
        gtUint64 gtAmountB = MpcCore.validateCiphertext(amountB);

        gtBool successA = tokenA.transferFrom(
            msg.sender,
            address(this),
            gtAmountA
        );
        uint256 successAUint = gtBool.unwrap(successA);
        require(successAUint != 0, "Token A transfer failed");

        gtBool successB = tokenB.transferFrom(
            msg.sender,
            address(this),
            gtAmountB
        );
        uint256 successBUint = gtBool.unwrap(successB);
        require(successBUint != 0, "Token B transfer failed");

        reserve1 = tokenA.balanceOf(address(this));
        reserve2 = tokenB.balanceOf(address(this));
    }

    function getUserReserves() public returns (ctUint64, ctUint64) {
        gtUint64 gtR1 = MpcCore.onBoard(reserve1);
        gtUint64 gtR2 = MpcCore.onBoard(reserve2);

        reserve1 = MpcCore.offBoardToUser(gtR1, msg.sender);
        reserve2 = MpcCore.offBoardToUser(gtR2, msg.sender);
    }

    function swap(itUint64 calldata inputA) external {
        gtUint64 gtInputA = MpcCore.validateCiphertext(inputA);

        gtUint64 gtR1;
        if (ctUint64.unwrap(reserve1) == 0) {
            gtR1 = MpcCore.setPublic64(0);
        } else {
            gtR1 = MpcCore.onBoard(reserve1);
        }
        gtUint64 gtR2;
        if (ctUint64.unwrap(reserve2) == 0) {
            gtR2 = MpcCore.setPublic64(0);
        } else {
            gtR2 = MpcCore.onBoard(reserve2);
        }

        gtUint64 newR1 = MpcCore.add(gtR1, gtInputA);
        gtUint64 k = MpcCore.mul(gtR1, gtR2);
        gtUint64 newR2 = MpcCore.div(k, newR1);
        gtUint64 outputB = MpcCore.sub(gtR2, newR2);

        gtBool successA = tokenA.transferFrom(
            msg.sender,
            address(this),
            gtInputA
        );
        uint256 successAUint = gtBool.unwrap(successA);
        require(
            successAUint != 0,
            "Token A from user to contract transfer failed"
        );

        gtBool successB = tokenB.transfer(msg.sender, outputB);

        uint256 successBUint = gtBool.unwrap(successB);
        require(
            successBUint != 0,
            "Token B from contract to user transfer failed"
        );
        ctOutputB = MpcCore.offBoardToUser(outputB, msg.sender);
    }
}
