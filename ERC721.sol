pragma solidity ^0.4.24;

import "./ERC721Base.sol";
import "./Ownable.sol";
import "./Crowdsale.sol";

contract ERC721 is ERC721Base, Ownable {
    struct money {
        uint256 denomination;
        uint256 code;
        uint256 dateOfCreation;
        bool isAvailable;
    }
    
    uint256 totalMoneyAmount;
    mapping(uint256 => money) public moneyByIndex;
    mapping(uint256 => address) ownersOfMoney;
    //address => money index => is available
    mapping(address => mapping(uint256 => bool)) moneyOfOwners;
    mapping(address => uint256) numberOfTokensOfUser;
    mapping(address => mapping(address => mapping(uint256 => bool))) allowed;
    address saleAgent;
    Crowdsale crowdsaleAddress;
    
    /**
     * @notice set the address of crowdsale for changing the state
     * @param _addressOfCrowdsale address of the crowdsale
     */
    function setCrowdsaleAddress(Crowdsale _addressOfCrowdsale) public onlyOwner {
        require(address(crowdsaleAddress) == 0x0);
        crowdsaleAddress = _addressOfCrowdsale;
    }
    
    /*
     * @notice creation of erc721 token with params
     * @param _denomination amount of wei of current token
     * @param _code code of the token. only integer number
     * @param _dateOfCreation date of creation of the token
     * @param _owner address of owner of the token
     */
    function createNewMoney(
        uint256 _denomination,
        uint256 _code,
        uint256 _dateOfCreation,
        address _owner
    ) public {
        require(msg.sender == saleAgent);
        
        money memory buf = money({
            denomination: _denomination,
            code: _code,
            dateOfCreation: _dateOfCreation,
            isAvailable: true
        });
        
        moneyByIndex[totalMoneyAmount] = buf;
        ownersOfMoney[totalMoneyAmount] = _owner;
        moneyOfOwners[_owner][totalMoneyAmount] = true;
        numberOfTokensOfUser[_owner]++;
        
        totalMoneyAmount++;
        
        emit MoneyCreated(_owner, _denomination, _code, _dateOfCreation);
    }
    
    /**
     * @notice set the sale agent, who can mint tokens
     * @param _newSaleAgent address of the sale agent
     */
    function setSaleAgent(address _newSaleAgent) onlyOwner public {
        require(saleAgent == 0x0);
        saleAgent = _newSaleAgent;
    }
    
    /*
     * @notice getter for total number of created tokens
     * @returns uint256 totalMoneyAmount, total number of created tokens
     */
    function totalSupply() view public returns (uint256) {
        return totalMoneyAmount;
    }
    
    /* 
     * @notice balance of the current user
     * @param _owner address of the owner of tokens
     * @returns uint256 number of tokens of the user
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return numberOfTokensOfUser[_owner];
    }
    
    /*
     * @notice getting the owner of the current token
     * @param _tokenId Id of the token 
     * @returns address address of the token's owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return ownersOfMoney[_tokenId];
    }
    
    /*
     * @notice approving another user to get your token
     * @param _to address of possible receiver of token
     * @param _tokenId Id of the token
     */
    function approve(address _to, uint256 _tokenId) external {
        require(ownersOfMoney[_tokenId] == msg.sender);
        require(msg.sender != _to);
        
        allowed[msg.sender][_to][_tokenId] = true;
    }
    
    /*
     * @notice changing the owner of the token
     * @param _to address of receiver of token
     * @param _tokenId Id of the token
     */
    function transfer(address _to, uint256 _tokenId) external {
        require(ownersOfMoney[_tokenId] == msg.sender);
        require(msg.sender != _to);
        
        ownersOfMoney[_tokenId] = _to;
        moneyOfOwners[msg.sender][_tokenId] = false;
        moneyOfOwners[_to][_tokenId] = false;
        numberOfTokensOfUser[msg.sender]--;
        numberOfTokensOfUser[_to]++;
    }
    
    /*
     * @notice transfer ownership from owner to receiver only with allowance
     * @param _from addres sow token's owner
     * @param _to address of receiver of token
     * @param _tokenId Id of the token
     */    
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(ownersOfMoney[_tokenId] == _from);
        require(_from != _to);
        require(allowed[_from][_to][_tokenId] == true);
        
        ownersOfMoney[_tokenId] = _to;
        moneyOfOwners[_from][_tokenId] = false;
        moneyOfOwners[_to][_tokenId] = false;
        numberOfTokensOfUser[_from]--;
        numberOfTokensOfUser[_to]++;
    }
    
    /*
     * @notice get the allowance for transfering of token from owner to possible receiver
     * @param _from address of owner of token
     * @param _to address of token possible receiver
     */
    function allowance(
        address _from, 
        address _to, 
        uint256 _tokenId
    ) view public returns (bool) {
        return allowed[_from][_to][_tokenId];
    }
    
    
    /*
     * @notice sell tokens for their denomination. he will recieve all ether for that token
     * @param _tokenId Id of token for selling. only owner can sell it
     */
    function sellToken(uint256 _tokenId) public {
        require(ownersOfMoney[_tokenId] == msg.sender);
        require(moneyByIndex[_tokenId].isAvailable == true);
        
        moneyByIndex[_tokenId].isAvailable = false;
        ownersOfMoney[_tokenId] = 0x0;
        moneyOfOwners[msg.sender][_tokenId] = false;
        numberOfTokensOfUser[msg.sender]--;
        
        crowdsaleAddress.sellToken(moneyByIndex[_tokenId].denomination * 1 finney, msg.sender);
        
        emit MoneySold(msg.sender, _tokenId, now);
    }
}