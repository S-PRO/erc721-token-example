pragma solidity ^ 0.4.24;

import "./Token/ERC-721/ERC721.sol";
import "./Ownership/Ownable.sol";

contract Crowdsale is Ownable {
    ERC721 token;
    address administrator;
    uint256 percentageOfCommission = 5;
    
    event MoneyPaid(address owner, uint256 value, uint256 commission, uint256 surrender);
    
    /*
     * @notice constructor for crowdsale for setting params
     * @param _token address of ERC721 token
     * @param _administrator address of wallet of administrator where commission will be store
     */
    constructor(ERC721 _token, address _administrator) public {
        token = _token;
        administrator = _administrator;
    }
    
    /*
     * @notice creation of token for the ethe. 
     *  investor will send ether and params and token will be created for that denomination and investor will recieve delivery
     * @param _denomination denomination of token. how much ether it costs. number will be integer
     * @param _code the code of the token. integer number
     */
    function createToken(uint256 _denomination, uint256 _code) public payable {
        uint256 commission = _denomination * 1 ether * percentageOfCommission / 100;
        uint256 transferAmount = _denomination * 1 ether + commission;
        uint256 surrender = msg.value - transferAmount;
            
        require(msg.value >= transferAmount);
        
        token.createNewMoney(_denomination, _code, now, msg.sender);
        
        administrator.transfer(commission);
        (msg.sender).transfer(surrender);
        
        emit MoneyPaid(msg.sender, msg.value, commission, surrender);
    }
    
    /*
     * @notice user can't send ether to the contract without calling functions
     */
    function() public payable {
        revert();
    }
    
    /*
     * @notice sell tokens for their denomination. he will recieve all ether for that token
     *  only contract of token can call it
     * @param _value amount of wei for sending
     * @param _receiver address of ether receiver
     */
    function sellToken(uint256 _value, address _receiver) public {
        require(msg.sender == address(token));
        address(_receiver).transfer(_value);
    }
}