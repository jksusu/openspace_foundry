pragma solidity ^0.8.28;

//合约接口
interface IERC2612 {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owner) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * 合约部署地址 0xd71f0f00cce985a29dd2d5757ddaa2b120c370ee
 */
contract TokenBank {
    IERC2612 public token; //需要实现的token
    bool public status = true; //合约状态
    address[] public owners; //合约管理员
    address[] public tokenContractAddressArr; //支持的合约数组
    mapping(address => mapping(uint256 => bool)) public tokenContractStatus; //合约是否开启交易 address -- 1存款 | 2提现 -> status
    mapping(address => mapping(address => uint256)) public tokenBalanceOf; //用户地址 -- 币种地址 ---> 币种余额

    event Deposit(address tokenAddress, address indexed user, uint256 amount); //存款事件
    event Withdrawal(address tokenAddress, address indexed user, uint256 amount); //取款事件

    error NoPermission(); //没有权限
    error ContractPause(); //合约暂停使用
    error TokenPause(); //token当前操作暂停
    error InsufficientBalance(); //余额不足
    error TheValIsInvalid(); //数值不合法
    error SignatureExpired(); //签名过期
    error TransferFailed(); //交易失败

    modifier ownerValid() {
        bool isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        if (!isOwner) revert NoPermission();
        _;
    }

    modifier contractStatus() {
        if (!status) revert ContractPause();
        _;
    }
    //token是否支持操作

    modifier tokenSupported(address tokenAddress, uint256 _type) {
        bool isSupported = tokenContractStatus[tokenAddress][_type];
        if (!isSupported) revert TokenPause();
        _;
    }

    modifier validValue(uint256 amount) {
        if (amount <= 0) revert TheValIsInvalid();
        _;
    }

    constructor() {
        owners.push(msg.sender);
    }

    /**
     * 暂停合约
     */
    function changeContractStatus(bool _status) external ownerValid {
        if (_status == status) return;
        status = _status;
    }

    /**
     * 暂停或者开启某个token提现或者存款功能
     */
    function changeTokenStatus(address _tokenAddress, uint256 _type, bool _status) public ownerValid {
        if (tokenContractStatus[_tokenAddress][_type] == _status) return;
        tokenContractStatus[_tokenAddress][_type] = _status;
    }

    //上架并开启业务存取款
    function listToken(address _tokenAddress) public contractStatus ownerValid {
        tokenContractAddressArr.push(_tokenAddress);
        changeTokenStatus(_tokenAddress, 1, true);
        changeTokenStatus(_tokenAddress, 2, true);
    }

    /**
     * 存款
     */
    function depositeByToken(address tokenAddress, uint256 amount) public contractStatus tokenSupported(tokenAddress, 1) validValue(amount) {
        tokenBalanceOf[msg.sender][tokenAddress] += amount;
        emit Deposit(tokenAddress, msg.sender, amount);
    }

    /**
     * 支持ERC2612的存款方式
     * @param tokenAddress 代币地址
     * @param from 签名者（代币持有者）的地址
     * @param amount 存款金额
     * @param deadline 签名有效时间
     * @param v 签名参数 v
     * @param r 签名参数 r
     * @param s 签名参数 s
     */
    function permitDeposit(address tokenAddress, address from, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external tokenSupported(tokenAddress, 1) validValue(amount) {
        if (block.timestamp > deadline) revert SignatureExpired();

        IERC2612 permitToken = IERC2612(tokenAddress); // 修改变量名
        permitToken.permit(from, address(this), amount, deadline, v, r, s);
        if (!permitToken.transferFrom(from, address(this), amount)) revert TransferFailed();

        tokenBalanceOf[msg.sender][tokenAddress] += amount;
        emit Deposit(tokenAddress, from, amount);
    }

    /**
     * 取款
     */
    function withdrawalByToken(address tokenAddress, uint256 amount) public contractStatus tokenSupported(tokenAddress, 2) validValue(amount) {
        if (tokenBalanceOf[msg.sender][tokenAddress] < amount) revert InsufficientBalance();
        tokenBalanceOf[msg.sender][tokenAddress] -= amount;
    }

    /**
     * 获取用户token余额
     */
    function getDepositByToken(address userAddress, address tokenAddress) external view returns (uint256) {
        return tokenBalanceOf[userAddress][tokenAddress];
    }

    /**
     * 获取用户所有余额
     */
    function getDepositAll(address userAddress) external view returns (address[] memory, uint256[] memory) {
        uint256 tokenCount = tokenContractAddressArr.length;
        address[] memory tempAddresses = new address[](tokenCount);
        uint256[] memory tempBalances = new uint256[](tokenCount);
        uint256 validCount = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            address _tokenAddress = tokenContractAddressArr[i];
            uint256 userBalance = tokenBalanceOf[userAddress][_tokenAddress];
            if (userBalance > 0) {
                tempAddresses[validCount] = _tokenAddress;
                tempBalances[validCount] = userBalance;
                validCount++;
            }
        }
        address[] memory tokenAddress = new address[](validCount);
        uint256[] memory balance = new uint256[](validCount);
        for (uint256 i = 0; i < validCount; i++) {
            tokenAddress[i] = tempAddresses[i];
            balance[i] = tempBalances[i];
        }
        return (tokenAddress, balance);
    }

    /**
     * 获取合约状态
     * @return 合约当前状态
     */
    function getContractStatus() external view returns (bool) {
        return status;
    }
}
