// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LotteryTickets is ERC1155, Ownable {
    using Strings for uint256;

    string public baseURI;
    mapping(uint256 => bool) public ticketExists;

    constructor(string memory _baseURI) ERC1155("") Ownable(msg.sender) {
        baseURI = _baseURI;
    }

    // Только владелец может минтить
    function mintBatch(
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external onlyOwner {
        uint256 len = tokenIds.length;
        require(len == amounts.length, "Arrays length mismatch");
        for (uint256 i = 0; i < len; i++) {
            require(amounts[i] == 1, "Only 1 ticket per ID");
            require(!ticketExists[tokenIds[i]], "Ticket already exists");
            ticketExists[tokenIds[i]] = true;
            _mint(to, tokenIds[i], 1, "");
        }
    }

    // Обновление URI (для смены домена или хостинга)
    function setURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
        _setURI(newURI);
    }

    // Динамический URI: https://.../api/metadata/123
    function uri(uint256 tokenId) public view override returns (string memory) {
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : "";
    }
}