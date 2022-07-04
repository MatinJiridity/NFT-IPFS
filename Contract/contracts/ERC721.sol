// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Address.sol";
import "./Context.sol";
import "./ERC165.sol";
import "./IERC721.sol";
import "./IERC165.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./String.sol";

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) private _Hash;

    uint256 public tokenIdCounter;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

   function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    
    function name() public view virtual override returns (string memory){
        return _name;
    }

    function symbol() public view virtual override returns (string memory){
        return _symbol;
    }

    function _exists(uint tokenId) public view virtual returns(bool){
        return _owners[tokenId] != address(0);
    }



    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_exists(tokenId), " URI query for not exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId)) : " ";
    }

    function _baseURI() internal view virtual returns(string memory) {
        return " ";
    }




    function isApprovedForAll(address owner, address operator) public  view virtual override returns (bool){
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId); // ERC721.ownerOf(tokenId) ===> msg.sender  it possible this token is not for msg.sender so we use ownerOf func so we didn't write msg.sender
        require(owner != to , " apploval to current owner");

        require (_msgSender() == owner || isApprovedForAll(owner, _msgSender()), " approve caller is not owner");
        _approve(to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual  {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function   getApproved (uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
 
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public  virtual override{
        require(_isApprovedOrOwner(to, tokenId), " caller is not owner");

        _transfer(from, to, tokenId);

    }



    // this is function for proof of caller 
    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns(bool){
        require(_exists(tokenId), "ERC721: oprator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId); // ERC721.ownerOf(tokenId) ===> msg.sender  it possible this token is not for msg.sender so we use ownerOf func so we didn't write msg.sender
        return(owner == spender || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual{
        require(from == ERC721.ownerOf(tokenId), " ERC721: transfer caller is not owner nor approved");
        require(to != address(0), "ERC721: owner query for nonexistent token");
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override{
        safeTransferFrom(from, to, tokenId, " ");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override{
        require(_isApprovedOrOwner(_msgSender(), tokenId));

        _safeTransfer(from, to, tokenId, _data);
    }


    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual{
        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data), " ERC721: safe transfer to non ERC721Receiver implementer");
    }


    function  _checkOnERC721Received(        
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
        ) private returns(bool) {
        if(to.isContract()){
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns(bytes4 retval){   // IERC721Receiver(to) => by "to" address we call IERC721Receiver contract
                return retval == IERC721Receiver.onERC721Received.selector;
            }catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }else{
            return true;
        }
    }


    function mint(address to, string memory _hash) public virtual{
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId, _hash);
    }


    function _safeMint(address to, uint256 tokenId, string memory _hash) internal virtual{
        _safeMint(to, tokenId, " ", _hash);
    }

    
    function _safeMint(address to, uint256 tokenId, bytes memory _data, string memory _hash) internal virtual{
        _mint(to, tokenId, _hash);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), " ERC721: safe mint to non ERC721Receiver implementer");
    }


    function _mint(address to, uint tokenId, string memory _hash) internal virtual{
        require(to != address(0) , " mint to zero address");
        require(!_exists(tokenId) , " token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _Hash[tokenId] = _hash;
        tokenIdCounter ++;
        emit Transfer(address(0), to, tokenId);
    }


    function burn(uint tokenId) public virtual{
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }


    function _burn(uint tokenId) internal virtual{
        address owner = ERC721.ownerOf(tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _Hash[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }


    function ShowNft(uint256 tokenId) public view returns(string memory){
        return _Hash[tokenId];
    }

}

 







