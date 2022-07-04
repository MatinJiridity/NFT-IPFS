// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 
// Interface for any contract that wants to support safeTransfers

interface IERC721Receiver {

    // File @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol@v4.3.1

    /**
    * ERC721 token receiver interface
    * Interface for any contract that wants to support safeTransfers
    * from ERC721 asset contracts.
    */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}



