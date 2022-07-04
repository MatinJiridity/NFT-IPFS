// SPDX-License-Identifier: MIT

import "./IERC165.sol";

pragma solidity ^0.8.0;

// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v4.3.1


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);


    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);


    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    // If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
     
    // WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // Only a single account can be approved at a time, so approving the zero address clears previous approvals.
    // The caller must own the token or be an approved operator.
     
    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    /** -------------------------------
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     * - The `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);


    // If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
  
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


