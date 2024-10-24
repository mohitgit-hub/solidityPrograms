// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// CA- 0xd9145CCE52D386f254917e481eB44e9943F39138
contract SimpleWallet {
    address owner;
    string public str; 
    struct Transaction {
        address from;
        address to;
        uint timestamp;
        uint amount;
    }

    Transaction [] public transactionHistory;

    event Transfer (address receiver, uint amount);
    event Receive (address sender, uint amount);
    event Details (address sender, address receiver,uint amount);
    bool public stop;
    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner () {
       require(msg.sender == owner,"You're not owner");
       _; 
    }

    function changeOwner (address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function toggleStop () external onlyOwner {
        stop = !stop;
    }

    modifier isEmergencyDeclared () {
        require(stop == false,"Emergency Declared");
        _;
    }
    function transferToContract ( ) external payable{
        transactionHistory.push(Transaction({
            from: msg.sender,
            to:address(this),
            amount:msg.value,
            timestamp:block.timestamp
        }));
    }

    function transferToUserViaContract (address payable _to, uint _weiAmount) external onlyOwner{
         require(address(this).balance>= _weiAmount,"Insufficient Balance");   
         require(_to != address(0),"Burner address not allowed");
         _to.transfer(_weiAmount);
             transactionHistory.push(Transaction({
            from: msg.sender,
            to:_to,
            amount:_weiAmount,
            timestamp:block.timestamp
        }));
         emit Transfer(_to, _weiAmount);
    }

    function getContractBalanceInWei () external view returns (uint) {
        return address(this).balance;
    }

    function withdrawFromContract (uint _weiAmount) external onlyOwner {
        require(address(this).balance >= _weiAmount,"Insufficient Balance to withdraw");
        payable(owner).transfer(_weiAmount);
          transactionHistory.push(Transaction({
            from: address(this),
            to:owner,
            amount:_weiAmount,
            timestamp:block.timestamp
        }));
    }
        
       


    function transferToUserViaMsgValue (address payable _to) external payable {
        require(address(this).balance>= msg.value,"Insufficient Balance");
        _to.transfer(msg.value);
          transactionHistory.push(Transaction({
            from: msg.sender,
            to:_to,
            amount:msg.value,
            timestamp:block.timestamp
        }));
        }


    //User calls this function and send funds to owner prev receive from user function
    //event- sender,receiver,emit
    function sendToOwner () external payable{
        require(msg.value >0,"Insufficient Balance");
        payable (owner).transfer(msg.value);
        emit Details(msg.sender,owner,msg.value);
          transactionHistory.push(Transaction({
            from: msg.sender,
            to:owner,
            amount:msg.value,
            timestamp:block.timestamp
        }));
    }    

    function getOwnerBalanceInWei () view external returns (uint) {
        return owner.balance;
    }     

    function getTransactionHistory () view external returns(Transaction [] memory) {
        return transactionHistory;
    }
    receive() external payable { 
        emit Receive(msg.sender, msg.value);
          transactionHistory.push(Transaction({
            from: msg.sender,
            to:address(this),
            amount:msg.value,
            timestamp:block.timestamp
        }));
    }
    
    fallback() external payable {
        str = "Fallback function is called";
    }
}
