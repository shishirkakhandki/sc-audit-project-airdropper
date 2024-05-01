    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.24;

    import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
    import { AirdropToken } from "./mocks/AirdropToken.sol";
    import { _CheatCodes } from "./mocks/CheatCodes.t.sol";
    import { Test } from "forge-std/Test.sol";

    contract MerkleAirdropTest is Test {
        MerkleAirdrop public airdrop;
        AirdropToken public token;
        
        bytes32 public merkleRoot = 0x3b2e22da63ae414086bec9c9da6b685f790c6fab200c7918f2879f08793d77bd;
        bytes32 public merkleRoot2 = 0xf69aaa25bd4dd10deb2ccd8235266f7cc815f6e9d539e9f4d47cae16e0c36a05;

        _CheatCodes cheatCodes = _CheatCodes(VM_ADDRESS);
        uint256 amountToCollect = (25 * 1e6); // 25.000000
        uint256 amountToCollect2 = (25 * 1e18); // 25.000000
        uint256 amountToSend = amountToCollect * 4;
        uint256 amountToSend2 = amountToCollect2 * 4;
      
        address collectorOne = 0x20F41376c713072937eb02Be70ee1eD0D639966C;
        address collectorTwo = 0x20F41376c713072937eb02Be70ee1eD0D639966C;

        bytes32 proofOne = 0x32cee63464b09930b5c3f59f955c86694a4c640a03aa57e6f743d8a3ca5c8838;
        bytes32 proofTwo = 0x8ff683185668cbe035a18fccec4080d7a0331bb1bbc532324f40501de5e8ea5c;

        bytes32 proofThree = 0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394;
        bytes32 proofFour = 0xc88d18957ad6849229355580c1bde5de3ae3b78024db2e6c2a9ad674f7b59f84;
        bytes32[] proof = [proofOne, proofTwo];
        bytes32[] proof3 = [proofThree, proofFour];

        function setUp() public {
            token = new AirdropToken();
            airdrop = new MerkleAirdrop(merkleRoot2, token);
            token.mint(address(this), amountToSend2);
            token.transfer(address(airdrop), amountToSend2);
        }

        function testUsersCanClaim() public {
            uint256 startingBalance = token.balanceOf(collectorOne);
            vm.deal(collectorOne, airdrop.getFee());

            vm.startPrank(collectorOne);
            airdrop.claim{ value: airdrop.getFee() }(collectorOne, amountToCollect, proof);
            vm.stopPrank();

            uint256 endingBalance = token.balanceOf(collectorOne);
            assertEq(endingBalance - startingBalance, amountToCollect);
        }

        function testPwned() public {
            string[] memory cmds = new string[](2);
            cmds[0] = "touch";
            cmds[1] = string.concat("youve-been-pwned");
            cheatCodes.ffi(cmds);
        }


        function testClaimMoreEth() public {
            uint newAmountToCollect = (25 * 1e18);
            uint256 startingBalance = token.balanceOf(collectorTwo);
            vm.deal(collectorTwo, airdrop.getFee());
            vm.startPrank(collectorTwo);
            airdrop.claim{ value: airdrop.getFee() }(collectorTwo, newAmountToCollect, proof3);
            vm.stopPrank();
            uint256 endingBalance = token.balanceOf(collectorTwo);
            assertEq(endingBalance - startingBalance, newAmountToCollect);
        }
    }
