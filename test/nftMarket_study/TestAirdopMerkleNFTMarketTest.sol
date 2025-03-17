// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../../src/nftMarket_study/AirdopMerkleNFTMarket.sol";
import { MyNFT } from "../../src/nftMarket_study/myNft.sol";
import { AksErc2612Token } from "../../src/eip2612Token/Eip2612Token.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TestAirdropMerkleNFTMarketTest is Test {
    MyNFT nft;
    AksErc2612Token token;
    AirdopMerkleNFTMarket market;

    bytes32 merkleRoot;
    address user1;
    address user2;
    address seller;
    uint256 signUserPrivateKey;

    uint256 tokenId;
    uint256 amount;

    function setUp() public {
        user1 = address(0x1);
        user2 = address(0x2);

        token = new AksErc2612Token();
        nft = new MyNFT();
        market = new AirdopMerkleNFTMarket(token, address(nft));

        token.transfer(user1, 10000000000000);

        (seller, signUserPrivateKey) = makeAddrAndKey("seller");
        vm.startPrank(seller);
        tokenId = nft.mintNFT("https://baiduc.com");
        amount = 10000000000000000000;
        vm.stopPrank();
    }

    function testSetMerkleRootTest() public {
        // 构建白名单用户生成默克尔树
        bytes32[] memory elements = new bytes32[](2);
        elements[0] = keccak256(abi.encodePacked(user1));
        elements[1] = keccak256(abi.encodePacked(user2));
        merkleRoot = keccak256(abi.encodePacked(elements));
        market.setMerkleRoot(merkleRoot);
        bytes32 storedRoot = market.merkleRoot();
        assertEq(storedRoot, merkleRoot, "Merkle root should be set correctly");

        // 验证是否是白名单
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = elements[1]; // 使用正确的proof
        bool isWhitelisted = market.isWhitelisted(user1, proof);
        assertEq(isWhitelisted, true, "User1 should be whitelisted");

        vm.startPrank(seller);
        uint256 nonce = token.nonces(seller);
        uint256 deadline = block.timestamp + 1000;
        bytes memory sign = permitSign(nonce, deadline);
        bytes memory a = abi.encodeWithSignature("permitPrePay(address,uint256,uint256,bytes)", seller, amount, deadline, sign);
        console.logBytes(a);
        market.permitPrePay(seller, amount, deadline, sign);

        // bytes[] memory data = new bytes[](2);
        // data[0] = abi.encodeWithSignature("permitPrePay(address,uint256,uint256,bytes)", user1, amount, deadline, sign);
        // // data[1] = abi.encodeWithSignature("claimNFT(bytes32[],uint256)", proof, 1);
        // bytes[] memory results = market.multipleCall(data);
        // console.logBytes(results[0]);

        vm.stopPrank();
    }

    // 修改签名编码方式，确保与解码一致
    function permitSign(uint256 nonce, uint256 deadline) private view returns (bytes memory) {
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitTypehash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(permitTypehash, seller, address(market), amount, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signUserPrivateKey, digest);
        return abi.encode(v, r, s); // 使用abi.encode代替abi.encodePacked
    }
}
