// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC721Insomnia is ERC721, ERC721URIStorage, ERC721Burnable {
    uint256 private _nextTokenId;
    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs:";
    }

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // function _transfer(
    //     address from,
    //     address to,
    //     uint tokenId
    // ) internal virtual {
    //     require(ownerOf(tokenId) == from, "Not an owner!");
    //     require(to != address(0), "To cannot be zero!");
    //     _beforeTokenTransfer(from, to, tokenId);
    //     _balances[from]--;
    //     _balances[to]++;
    //     _owners[tokenId] = to;

    //     emit Transfer(from, to, tokenId);

    //     _afterTokenTransfer(from, to, tokenId);
    // }
     function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId, 
        bytes memory data
    ) public virtual override (ERC721, IERC721){
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "not an owner or approved!"
        );
        _safeTransfer(from, to, tokenId);
    }

     function _isApprovedOrOwner(
        address spender,
        uint tokenId
    ) internal view returns (bool) {
        address owner = ownerOf(tokenId);

        return(spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender
            // "not an owner or approved"
        );
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }


    modifier _requireMinted(uint tokenId) {
        require(_exists(tokenId), "Not minted");
        _;
    }
      function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
        function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual {}

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "not an owner or approved!"
        );
        _transfer(from, to, tokenId);
    }

     function approve(address to, uint tokenId) public override(ERC721, IERC721) {
        address _owner = ownerOf(tokenId);
        require(_owner == msg.sender || isApprovedForAll(_owner, msg.sender), "not an owner");
        require(to != _owner, "cannot approve to self");

        _tokenApprovals[tokenId] = to;

        emit Approval(_owner, to, tokenId);
    }
    function setApprovalForAll(address operator, bool approved) public virtual override(ERC721, IERC721){
        _setApprovalForAll(_msgSender(), operator, approved);
    }
}