// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


interface IERC20 {
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);

//function for total supply
function totalSupply() external view returns (uint256); 
// function returns balance of a address 
function balanceOf(address account) external view returns (uint256);
//function transfer value of a token to a address
function transfer(address to, uint256 value) external returns (bool);
// function shows how much a tokens allowed to spender by a owner
function allowance(address owner, address spender) external view returns (uint256);
// function approves no. of tokens to spender from owner
function approve(address spender, uint256 value) external returns (bool);
//function transfers value of token from a user to another user
function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract MyToken is IERC20 {
    address public founder;
    uint public totalSupply = 1000000;         //Num of tokens 
    mapping (address=>uint) public balanceOfUser;  //mapping to maps balance of users address to no. of tokens
    mapping(address=>mapping(address=>uint))public allowedTokens;  //mapping to store data of no. of tokens a user a allowed to user b
    mapping (address=>bool) private freezedAccount;  //mappping to store whether the account is freeze or not
    mapping (address=>bool) private blacklistAddress; //mapping to store blacllist accounts
    uint public decimals = 18;
    bool isPause;
    bool isBlacklisted;
    constructor () {
        founder = msg.sender;
        balanceOfUser[founder]=totalSupply;   //Deployer will hold all token supply
    }
    modifier onlyFounder () {
        require(msg.sender == founder,"You're not founder");
        _;
    }
    function balanceOf(address account) external view returns (uint256) {
        return balanceOfUser[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
            require(isPause==false,"Transfer paused");
            require(to!= address(0),"Invalid address");
            require(balanceOfUser[msg.sender]>= value,"Insufficient Value");
            require(freezedAccount[msg.sender]==false,"You're not allowed");
            require(freezedAccount[to]==false,"This address is not allowed to receive tokens");
            balanceOfUser[msg.sender]-= value;  //balanceOfUser[msg.sender]= balanceOfUser[msg.value]-value;
            balanceOfUser[to]+=value;  //balanceOfUser[to]= balalceOfUser[to]+value;
            require(blacklistAddress[msg.sender]==false,"Account is blacklisted");
            require(blacklistAddress[to]==false,"Account is blacklisted");
            emit Transfer(msg.sender,to,value);
            return true;
    }

     function approve(address spender, uint256 value) external returns (bool) {
         require(spender!= address(0),"Invalid address");
         require(balanceOfUser[msg.sender]>= value,"Insufficient Value");
         allowedTokens[msg.sender][spender]=value;
         emit Approval(msg.sender, spender,value);
         return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
            return allowedTokens[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to==msg.sender,"Not authorised");
         require(from!= address(0),"Invalid address");
         require(to!= address(0),"Invalid address");
         require(allowedTokens[from][to]>= value,"Insufficient Value");
         require(freezedAccount[from]==false,"You're not allowed");
         require(freezedAccount[to]==false,"This address is not allowed to receive tokens");
         require(blacklistAddress[from]==false,"Account is blacklisted");
         require(blacklistAddress[to]==false,"Account is blacklisted");
         balanceOfUser[from]-=value; // balanceOfUser[from]=balanceOfUser[from]-value;
         balanceOfUser[to]+=value;   // balanceOfUser[to]=balanceOfUser[to]+value;
         allowedTokens[from][to]-=value; //allowedTokens[from][to]=allowedTokens[from][to]-value;
         emit Transfer(from,to,value);
         return true;
    }

    //mint(address to, uint256 amount): Mint new tokens to a specified address.
    function mint(address to, uint256 amount) external onlyFounder{
        totalSupply+=amount;        //totalSupply= totalSupply+amount;
        balanceOfUser[to]+=amount;  //balanceOfUser[to]=balanceOfUser
    }

    //burn(uint256 amount): Burn tokens from the caller's balance.
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOfUser[msg.sender] >= amount, "Insufficient balance to burn");
        balanceOfUser[msg.sender] -= amount;
        totalSupply -= amount; // Update total supply
        emit Transfer(msg.sender, address(0), amount); // Emit a burn event
    }

    /* freezeAccount(address account): Allows the owner to freeze accounts, 
        preventing them from transferring or receiving tokens. */

        function freezeAccount(address account) external onlyFounder {
            //mapping (address=>bool) private freezedAccount;
            freezedAccount[account]=true;
            
        }

        /*unfreezeAccount(address account): Allows the owner to unfreeze accounts,
         allowing them from transferring or receiving tokens. */

         function unfreezeAccount(address account) external onlyFounder  {
            freezedAccount[account]=false;
         }

         /* pause(): Adds a "pausable" feature that allows the owner to pause and unpause all token transfers. */

         function pause() external onlyFounder{
            isPause=true;
         }

         //unpause() : to unpause() the effect of pause
          function unpause() external onlyFounder{
            isPause=false;
         }

         //blacklist(address account)
         function blacklist(address account) external onlyFounder{
            blacklistAddress[account]=true;
         }
         /*unblacklist(address account): Allows the owner to add and remove addresses to a blacklist,
          preventing those addresses from transferring or receiving tokens. */
          function unblacklist(address account) external onlyFounder{
            blacklistAddress[account]=false;
         }

         /* transferOwnership(address newOwner):Allows the owner to transfer ownership to another address. */
         function transferOwnership(address newOwner) external onlyFounder{
            founder = newOwner;
         }








}
