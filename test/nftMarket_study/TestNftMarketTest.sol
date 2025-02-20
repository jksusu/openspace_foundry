// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseERC20} from "../../src/nftMarket_study/baseERC20.sol";
import {MyNFT} from "../../src/nftMarket_study/myNft.sol";
import {NFTMarket} from "../../src/nftMarket_study/nftMarket.sol";

//forge test --mc TestNftMarketTest
contract TestNftMarketTest is Test {
    BaseERC20 public baseERC20Instance;
    MyNFT public myNFTInstance;
    NFTMarket public nftMarketInstance;

    address admin = makeAddr("admin"); //管理员地址

    function setUp() public {
        vm.startPrank(admin);
        baseERC20Instance = new BaseERC20();
        myNFTInstance = new MyNFT();
        nftMarketInstance = new NFTMarket(baseERC20Instance, myNFTInstance);
        vm.stopPrank();
        console.log("baseERC20Address", address(baseERC20Instance));
        console.log("myNFTAddress", address(myNFTInstance));
        console.log("nftMarketAddress", address(nftMarketInstance));
        console.log("admin", admin);
    }

    mapping(uint256 => uint256) private tokenIds; //存nftId和价格
    uint[] private tokenIdsArr; //存所有nftId

    function test_list() public {
        address nftSeller = makeAddr("nftSeller"); // nft卖家
        address nftBuyer = makeAddr("nftBuyer"); // nft买家
        console.log("nftSeller", nftSeller);
        console.log("nftBuyer", nftBuyer);
        uint256 tokenId = 2;
        uint256 nftPrice = 1;

        // 卖家铸造并上架NFT
        vm.startPrank(nftSeller); //后续获取到的msg都是nftSeller的
        myNFTInstance.mintNFT("https://www.myNFT.com/1");
        myNFTInstance.approve(address(nftMarketInstance), tokenId);
        //断言授权是否成功
        assertEq(
            myNFTInstance.getApproved(tokenId),
            address(nftMarketInstance)
        );
        //上架nft设置价格
        nftMarketInstance.list(tokenId, nftPrice);
        //断言是否上架成功
        NFTMarket.Listing memory listing = nftMarketInstance.getNftByTokenId(
            tokenId
        );
        assertEq(listing.seller, nftSeller);
        assertEq(listing.price, nftPrice);
        vm.stopPrank();

        //管理员给买方转账
        vm.startPrank(admin);
        uint256 nftToBuyUserAmount = 10;
        baseERC20Instance.transfer(nftBuyer, nftToBuyUserAmount);
        assertEq(baseERC20Instance.balanceOf(nftBuyer), nftToBuyUserAmount);
        vm.stopPrank();

        // 买家购买NFT
        vm.startPrank(nftBuyer); //后续获取到的msg都是nftBuyer的
        //断言买家余额是否足够购买nft
        assertEq(baseERC20Instance.balanceOf(nftBuyer), nftToBuyUserAmount);
        //断言低于上市价格购买 判断错误是否等于
        vm.expectRevert("Insufficient amount"); //断言错误的方法
        baseERC20Instance.transferWithCallback(
            address(nftMarketInstance),
            nftPrice - 1,
            tokenId
        );

        //买家付款给交易所
        baseERC20Instance.transferWithCallback(
            address(nftMarketInstance),
            nftPrice,
            tokenId
        );
        //检查卖家是否收到款项
        assertEq(baseERC20Instance.balanceOf(nftSeller), nftPrice);
        //检查nft是否已经到了买家
        assertEq(myNFTInstance.ownerOf(tokenId), nftBuyer);

        //检查买家余额是否正确
        assertEq(
            baseERC20Instance.balanceOf(nftBuyer),
            nftToBuyUserAmount - nftPrice
        );

        //断言购买一个不存在的nft
        vm.expectRevert("does not exist");
        baseERC20Instance.transferWithCallback(
            address(nftMarketInstance),
            nftPrice,
            tokenId
        );
        //随机测试
        vm.startPrank(nftSeller);
        for (uint256 i = 0; i < 10; i++) {
            tokenId = myNFTInstance.mintNFT(randomUrl(i));
            myNFTInstance.approve(address(nftMarketInstance), tokenId);
            uint256 price = random(i);
            tokenIdsArr.push(tokenId);
            tokenIds[tokenId] = price;
            nftMarketInstance.list(tokenId, price);
        }
        vm.stopPrank();

        for (uint256 i = 0; i < tokenIdsArr.length; i++) {
            address nftBuyer2 = makeAddr(randomName(i));
            vm.startPrank(admin);
            baseERC20Instance.transfer(nftBuyer2, 100);
            assertEq(baseERC20Instance.balanceOf(nftBuyer2), 100);
            vm.stopPrank();

            vm.startPrank(nftBuyer2);
            tokenId = tokenIdsArr[i];
            uint256 nprice = tokenIds[tokenId];
            baseERC20Instance.transferWithCallback(
                address(nftMarketInstance),
                nprice,
                tokenId
            );
            assertEq(myNFTInstance.ownerOf(tokenId), nftBuyer2);
            vm.stopPrank();
        }
    }

    function randomUrl(uint256 seed) private view returns (string memory) {
        bytes
            memory alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory url = new bytes(16); // 生成长度为16的随机字符串
        for (uint256 i = 0; i < 16; i++) {
            url[i] = alphabet[random(seed + i) % alphabet.length];
        }
        return string(abi.encodePacked("https://www.myNFT.com/", url));
    }

    function randomName(uint256 seed) private view returns (string memory) {
        bytes
            memory alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory name = new bytes(4); // 生成长度为16的随机字符串
        for (uint256 i = 0; i < 4; i++) {
            name[i] = alphabet[random(seed + i) % alphabet.length];
        }
        return string(name);
    }

    function random(uint256 seed) private view returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(block.timestamp, seed))) %
                100) + 1;
    }
}
