// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";
import "./libraries/StringUtils.sol";

contract ERC721 is IERC721Metadata {
    string public name;
    string public symbol;
    string public baseUri;
    uint256 internal price;
    uint256 internal currentTokenId;
    IERC20 public paymentToken;

    mapping(uint256 => address) internal owners;
    mapping(uint256 => address) internal approvals;
    mapping(address => uint256) internal balances;
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        IERC20 _paymentToken,
        uint256 initialTokenPrice
    ) {
        name = _name;
        symbol = _symbol;
        baseUri = _baseUri;
        price = initialTokenPrice;
        paymentToken = _paymentToken;
        currentTokenId = 1;
    }

    function mint(address to) external {
        emit Transfer(address(0), to, currentTokenId);
        paymentToken.transferFrom(to, address(0), price);
        owners[currentTokenId] = to;
        balances[to]++;
        currentTokenId++;
        price = price + (price * 10) / 100;
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return string(abi.encodePacked(baseUri, StringUtils.toString(_tokenId)));
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return owners[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        require(msg.sender == owners[_tokenId] || msg.sender == approvals[_tokenId], "not authorized");
        emit Transfer(_from, _to, _tokenId);
        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
    }

    function approve(address _approved, uint256 _tokenId) external {
        require(msg.sender == owners[_tokenId], "not authorized");
        emit Approval(owners[_tokenId], _approved, _tokenId);
        approvals[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return approvals[_tokenId];
    }

    // Bonus functions

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return interfaceID == 0x80ac58cd; 
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {}

    function setApprovalForAll(address _operator, bool _approved) external {}

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {}
}

// balanceOf Retrieve the number of tokens that a user owns
// ownerOf Retrieve the owner of a given token
// transferFrom Transfer a token to another address
// approve Approve another user to transfer a given token on the user’s behalf
// getApproved Retrieve the user approved to transfer a given token
// Like the ERC-20 standard, the ERC-721 standard also has some extensions. In this tutorial, we will also
// implement the metadata extension that defines the following other functions:
// name The name of the token
// symbol The symbol of the token
// tokenURI The URI of the given token. The URI typically points to a JSON file containing metadata about the
// token
// More information can be found in the ERC-721 standard.
// In addition to the ERC-721 standard, our token will have the following extra specs:
// • The constructor takes 5 arguments:
// 1. The name of the token (type: string memory)
// 2. The symbol of the token (type: string memory).
// 3. The base URI of the token (type: string memory). Typically, the base URI is an URL such as
// https://example.com/nft/
// 4. The ERC-20 token used pay for the ERC-721 token (type: IERC20)
// 5. The initial price (in terms of ERC-20 token) of a token (type: uint256)
// • To form the tokenURI, the base URI (passed in the constructor) should be concatenated with the token
// ID (using string.concat). A function to convert an integer to a string is provided in the src/libraries
// /StringUtils.sol of the skeleton.
// • No tokens exist initially
// • A new token can be minted by anyone by “burning” the amount of ERC-20 tokens corresponding to the
// current price. The price starts at the initial price passed in the constructor. To burn the ERC-20 tokens,
// this contract transfers the ERC-20 tokens from the user and sends them to the zero address. Note that
// this will revert if the user has not approved this contract to spend his ERC-20 tokens beforehand.
// • The first token has an id of 1 and the id is incremented each time a token is minted
// • Each time a token is minted, the price increases by 10%