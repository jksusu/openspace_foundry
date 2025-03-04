## 签名
```
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