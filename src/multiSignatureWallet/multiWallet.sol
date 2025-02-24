// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultWallet {
    address[] owners; //多签持有人
    uint256 public requiredNum; //最少签名人数

    struct TransactionInfo {
        address to;
        uint256 value;
        bytes data; //调用其他合约的数据
        bool executed;
        uint256 confirmations;
    }

    mapping(uint256 => TransactionInfo) public transactions; //提案列表
    mapping(uint256 => mapping(address => bool)) public transactionsConfirmed; //提案确定列表
    uint256 transactionId = 9999; //提案id, 每次提交一次开始递增

    error InvalidOwnersLength(); //必须是三个以上的持有人
    error InsufficientPermissions(); //权限不足
    error TransactionPeolpleMin(); //同意提案人数少
    error TransactionHasExecuted(); //提案已经执行
    error TransactionHasConfirmed(); //提案已经确认
    error TransactionHasExecFaild(); //提案执行失败

    event TransactionSubmitted(address indexed owner, uint256 indexed transactionId); //提案提交成功事件
    event TransactionConfirmed(address indexed owner, uint256 indexed transactionId); //合约确认事件
    event TransactionExecuted(address indexed owner, uint256 indexed transactionId); //合约执行操作事件

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        if (!isOwner) revert InsufficientPermissions();
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredNum) {
        if (_owners.length < 3) revert InvalidOwnersLength();
        if (requiredNum > _owners.length) revert TransactionPeolpleMin();
        owners = owners;
        requiredNum = _requiredNum;
    }

    /**
     *  发起多提案
     *
     *  1.检查提案人是否管理员
     *  2.检查提案是否已经执行
     *  3.检查提案是否已经确认
     */
    function submintTransaction(address _to, uint256 _value, bytes memory _data) public onlyOwner {
        transactionId = transactionId++;
        transactionsConfirmed[transactionId][msg.sender] = true;
        transactions[transactionId] = TransactionInfo({ to: _to, value: _value, data: _data, executed: false, confirmations: 1 });

        emit TransactionSubmitted(msg.sender, transactionId);
    }

    /**
     *  对多签提案进行签名
     *
     *  1.检查权限
     *  2.检查提案状态
     *  3.增加确定提案信息
     *  4.检查是否满足提案人数，满足则执行提案
     */
    function confirmTransaction(uint256 _transactionId) public onlyOwner {
        if (transactions[_transactionId].executed) revert TransactionHasExecuted();
        if (transactionsConfirmed[_transactionId][msg.sender]) revert TransactionHasConfirmed();

        transactionsConfirmed[_transactionId][msg.sender] = true;
        transactions[_transactionId].confirmations++;
        if (transactions[_transactionId].confirmations >= requiredNum) transactions[_transactionId].executed = true;

        emit TransactionConfirmed(msg.sender, _transactionId);
    }

    //获取提案信息
    function getTransactionById(uint256 _transactionId) public view returns (TransactionInfo memory) {
        return transactions[_transactionId];
    }

    /**
     *  执行提案
     *  1.检查提案是否已经执行
     *  2.执行提案
     */
    function execTransaction(uint256 _transactionId) public {
        if (transactions[_transactionId].executed) revert TransactionHasExecuted();
        if (transactions[_transactionId].confirmations < requiredNum) revert TransactionPeolpleMin();
        (bool success,) = transactions[_transactionId].to.call(transactions[_transactionId].data);
        if (!success) revert TransactionHasExecFaild();

        emit TransactionExecuted(msg.sender, _transactionId);
    }
}
