// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    // File @openzeppelin/contracts/token/ERC721/ERC721.sol@v4.3.1


    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


