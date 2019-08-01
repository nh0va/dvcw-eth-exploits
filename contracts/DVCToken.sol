pragma solidity ^0.4.22;

/*
 * @title DVCToken
 */
contract DVCToken {
  string public name = "Damn Vulnerable Contract";
  string public symbol = "DVC";
  string public standard = "DVC Token";
  uint256 public totalSupply;

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value
  );

  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256  _value
  );
  
  event Withdraw(
    address indexed _account,
    uint256  _value
  );  
  
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  /*
   * @dev Contract constructor
   */
  function DVCToken (uint256 _initialSupply) public payable {
    balanceOf[msg.sender] = _initialSupply;
    totalSupply = _initialSupply;
  }	

  /*
   * @dev transfer DVCTokens from an the sender to other account
   */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value, "Not enough funds");   

    balanceOf[_to] += _value;

    if(balanceOf[msg.sender] != 0){
      balanceOf[msg.sender] -= _value;
    }
    
    Transfer(msg.sender, _to, _value);
     
    return true;

  }
  
  /*
   * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);
    return true;
  }

  /*
   * @dev Transfers _value amount of tokens from address _from to address _to .
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[_from] - _value >= 0 ,  "Not enough funds");
    require(_value <= allowance[_from][msg.sender], "There is not allowance to transfer these funds");

    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;

    Transfer(msg.sender, _to, _value);
    return true;
  }

  /*
   * @dev Allows a token holder to sell part or their entire tokens.
   */  

  function withdraw(address _to, uint256 _tokens, uint256 _value) public returns (bool success ) {
    uint256 amountToWithdraw = _tokens * 1000000000000000000;

    require(_value == amountToWithdraw, "Error, value is not correct");
    require(balanceOf[_to] >= _tokens, 'Error: Amount to sell is bigger than wallet balance');

    _to.call.value(_value)();
    balanceOf[_to] -= _tokens;

    Withdraw(_to, _tokens);
    return true;
    }  

  
  function () payable {
    
  }
}
