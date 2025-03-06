## 签名

#### ECDSA 库
```sh
1.打包消息
把需要签名的消息内容通过 abi.encodePacked() 方法打包，然后通过 keccak256 生成哈希；

2.计算以太坊签名消息
消息可以是能被执行的交易，也可以是普通消息。为了避免用户被恶意合约签署交易的消息 EIP191 协议规定了在消息前面加上一串字符 "\x19Ethereum Signed Message:\n32" 然后做一次
keccak256() 哈希计算。这样的消息是不能被执行的交易的。可以直接使用 ECDSA库中的 toEthSignedMessageHash 方法来哈希消息。

快捷签名方式 通过钱包签名 直接在装有插件的浏览器 f12 执行签名

3.验证签名
验证者需要有至少三个参数才能验证签名 (消息，签名，公钥(address)) 可以通过 ESDSA 库中的 recover() 方法或者 tryRecover() 方法直接解析签名得到签名者的地址; 签名这里入参可以是多个，自己合约可以支持 传 r s v 格式的。也可以直接传签名。签名长度 65 bytes r = 32 bytes s = 32 bytes v = 1 bytes (v是uint8类型的)

注意：要防止重放，对签名要有过期时间
```

```sh
EIP712

1. domain 域分隔符 链id 有效时间戳 随机数 应用名 版本； 主要用来防止签名重放
2. message 消息 
3. hash计算
4. 签名与验证

Premit2 函数功能

允许 owner 通过签名授权某个 spender 花费指定代币。
permit(address owner,PermitSingle memory permitSingle,bytes calldata signature)

批量授权多个代币给多个 spender
permitBatch(address owner,PermitBatch memory permitBatch,bytes calldata signature)

通过签名直接从 owner 转账代币到指定地址
permitTransferFrom(PermitTransferFrom memory permit,SignatureTransferDetails calldata transferDetails,address owner,bytes calldata signature)

通过签名批量转账多个代币到多个目标地址
permitTransferFrom(PermitBatchTransferFrom memory permit,SignatureTransferDetails[] calldata transferDetails,address owner,bytes calldata signature)

直接从 from 转账代币到 to，无需签名，基于预先设置的授权
transferFrom(address from,address to,uint160 amount,address token)

批量转账多个金额到多个目标地址
transferFrom(TransferDetails[] calldata transferDetails,address from,address token)

直接授权某个 spender 花费指定代币，无需签名
approve(address token,address spender,uint160 amount,uint48 expiration)

使某些 nonce 失效，用于取消未排序的 nonce
invalidateUnorderedNonces(uint256 wordPos,uint256 mask)

查询某个 owner 对 spender 的授权状态
allowance(address owner,address token,address spender)

查询某个 owner 的 nonce 使用情况（位图形式）
nonceBitmap(address owner,uint256 word)

返回 EIP-712 签名的域分隔符
DOMAIN_SEPARATOR

总结
授权类（permit, permitBatch, approve）：设置代币授权，支持签名和直接调用。
转账类（permitTransferFrom, transferFrom）：通过签名或授权执行代币转账，支持单次和批量操作。
管理类（invalidateUnorderedNonces）：管理 nonce，增强安全性。
查询类（allowance, nonceBitmap, DOMAIN_SEPARATOR）：提供授权和状态查询。
```