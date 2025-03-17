pragma solidity ^0.8.28;

import { AksErc2612Token } from "../eip2612Token/Eip2612Token.sol";
import { MyNFT } from "../nftMarket_study/myNft.sol";

contract AirdopMerkleNFTMarket {
    AksErc2612Token public token;
    MyNFT public nft;

    address public owner;
    bytes32 public merkleRoot; //默克尔树根

    error DeadlineExpired();
    error TransferFailed();

    event NftBuy(address buyer, uint256 tokenId);
    event Debug(uint8, bytes32, bytes32);
    event DebugStr(string);

    constructor(AksErc2612Token _tokenAddress, address _nftAddress) {
        nft = MyNFT(_nftAddress);
        token = _tokenAddress;
        owner = msg.sender;
    }

    function permitPrePay(address from, uint256 amount, uint256 deadline, bytes memory sign) public {
        if (block.timestamp > deadline) revert DeadlineExpired();
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(sign, (uint8, bytes32, bytes32));
        token.permit(from, address(this), amount, deadline, v, r, s);
        // bool success = token.transferFrom(from, address(this), amount);
        // if (!success) revert TransferFailed();
    }

    function claimNFT(bytes32[] calldata _merkleProof, uint256 tokenId) internal {
        require(isWhitelisted(msg.sender, _merkleProof), "not whitelisted");
        nft.transferFrom(address(this), msg.sender, tokenId);
        emit NftBuy(msg.sender, tokenId);
    }

    function multipleCall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "Call failed");
            results[i] = result;
        }
        return results;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external {
        require(msg.sender == owner, "owner error");
        merkleRoot = _merkleRoot;
    }

    //验证是否是白名单
    function isWhitelisted(address _address, bytes32[] calldata _merkleProof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_address));
        return verify(merkleRoot, _merkleProof, leaf);
    }

    // 验证方法
    function verify(bytes32 root, bytes32[] memory proof, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }
}
