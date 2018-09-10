pragma solidity ^0.4.24;

contract ERC721Base {
    // Required methods
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    event MoneyCreated(address owner, uint256 denominationm, uint256 code, uint256 dateOfCreation);
    event MoneySold(address owner, uint256 tokenId, uint256 dateOfSold);
}