// SPDX-License-Identifier: MIT

import "./IERC721.sol";

pragma solidity ^0.8.0;

// File @openzeppelin/contracts/utils/Address.sol@v4.3.1

interface IERC721Metadata is IERC721 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
