pragma solidity ^0.4.22;

import "./DVCToken.sol";

/** 
 *
 *  @title DVCTokenSale
 */


contract DVCTokenSale {

  address admin;
  DVCToken public tokenContract;
  uint256 public tokenPrice;
  uint256 public tokensSold;
  bytes32 private secret;

  event Buy(
    address indexed _buyer,
    uint256 _amount
   );

  event Sell(
    address indexed _seller,
    uint256 _amount
   );

  
  mapping(address => bool) public claimedBonus;
  mapping(address => uint) public rewardAccount;

  /*
   * @dev Contract constructor
   */
  function DVCTokenSale(DVCToken _tokenContract, uint256 _tokenPrice, uint256 _tokensSold) public {
    admin = msg.sender;
    tokenContract = _tokenContract;
    tokenPrice = _tokenPrice;
    secret = bytes32(uint256(keccak256(block.blockhash(block.number), block.timestamp)));
    tokensSold = _tokensSold;
  }

  /*
   * @dev Multiplies two inputs
   */   
  function multiply(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y ) / y == x);
  }

  /*
   * @dev Allows to buy _numberOfTokens DVC tokens 
   */
  function buyTokens(uint256 _numberOfTokens) public payable {
  
    require(msg.value == multiply(_numberOfTokens, tokenPrice), 'Value not corresponding number of tokens');
    require(tokenContract.balanceOf(this) >= _numberOfTokens, 'The DVCTokenSale contract does not have enough tokens to sell');

  // We check if it is the first time the user buys a token. If that is the case, it duplicates the initial amount  
    if(claimedBonus[msg.sender] == false) {
	    rewardAccount[msg.sender] = multiply(_numberOfTokens, 2) ;
	    uint amountToBuy  = rewardAccount[msg.sender];

	    require(tokenContract.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, amountToBuy), 'The first transfer failed');

	    claimedBonus[msg.sender] = true;
	    tokensSold += amountToBuy;

	    Buy(msg.sender, amountToBuy);
	}  
	else {
  // We perform the normal buyTokens case
	  require(tokenContract.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, _numberOfTokens), 'The transfer failed'); 

	  tokensSold += _numberOfTokens;
    Buy(msg.sender, _numberOfTokens);
    }
  }
  
  /*
   *  @dev If it is called by an account, it transfers ETH to the Token wallet which will send back the funds to the wallet.
   */
  function sellTokens(uint256 _numberOfTokens) public {
    uint amountToWithdraw = multiply(_numberOfTokens, tokenPrice);  

    require(tokenContract.send(amountToWithdraw), 'Error:  sending money to DVCToken contract failed');
    require(tokenContract.withdraw(msg.sender, _numberOfTokens, amountToWithdraw), 'Error: calling withdraw () function on DVCToken contract failed');

    tokensSold -= _numberOfTokens;
    Sell(msg.sender, _numberOfTokens);
  }

  /*
   *  @dev Allows the administrator to update itself
   */
  function changeAdmin(address _admin, bytes32 _secret) {
    uint x;
    assembly {x := extcodesize(caller)}

    require(tx.origin != msg.sender, 'Origin is the same as msg.sender');
    require(x == 0, 'Caller cannot be a contract');
    require(_secret == secret , 'You shall not pass');

    admin = _admin;
  }


  /*
   * @dev Allows the administrator to end the Sale and transfer every remaining Token to its address.
   */
   
  function endSale() {
    require(msg.sender == admin);

    selfdestruct(admin);
  }

  function () payable {
    
  }

}
