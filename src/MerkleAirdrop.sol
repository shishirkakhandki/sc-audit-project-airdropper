// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop is Ownable {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidFeeAmount();
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__TransferFailed();

    uint256 private constant FEE = 1e9;
    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;

    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 newMerkleRoot);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(bytes32 merkleRoot, IERC20 airdropToken) Ownable(msg.sender) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    //done
    //1. move the ifs to modifiers
    // Modifier to check if the correct fee is paid
    // modifier validFee() {
    //     require(msg.value == FEE, "MerkleAirdrop__InvalidFeeAmount");
    //     _;
    // }

    // // Modifier to verify the merkle proof
    // modifier validMerkleProof(address account, uint256 amount, bytes32[] calldata merkleProof) {
    //     bytes32 leaf = keccak256(abi.encode(account, amount));
    //     require(MerkleProof.verify(merkleProof, i_merkleRoot, leaf), "MerkleAirdrop__InvalidProof");
    //     _;
    // }
    //done Check has claimed 
    // // State variable to track claimed status
    // mapping(address => bool) public hasClaimed;

    // // Modifier to check if the account has already claimed
    // modifier notAlreadyClaimed(address account) {
    //     require(!hasClaimed[account], "MerkleAirdrop__AlreadyClaimed");
    //     _;
    // }

    // function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external payable validFee validMerkleProof(account, amount, merkleProof) notAlreadyClaimed(account) {
    //     hasClaimed[account] = true; // Mark the account as claimed
    //     emit Claimed(account, amount);
    //     i_airdropToken.safeTransfer(account, amount);
    // }


    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external payable {
        if (msg.value != FEE) {
            revert MerkleAirdrop__InvalidFeeAmount();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        emit Claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function claimFees() external onlyOwner {
        (bool succ,) = payable(owner()).call{ value: address(this).balance }("");
        if (!succ) {
            revert MerkleAirdrop__TransferFailed();
        }
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function getFee() external pure returns (uint256) {
        return FEE;
    }
}
