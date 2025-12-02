// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LotteryTicket is ERC721A, Ownable {
    using Strings for uint256;

    IERC20 public immutable lottoToken;
    string public baseTokenURI;

    constructor(address _lottoToken, string memory _baseTokenURI)
        ERC721A("CryptoLotteryTicket", "CLT")
        Ownable(msg.sender)
    {
        require(_lottoToken != address(0), "Invalid LOTTO token address");
        lottoToken = IERC20(_lottoToken);
        baseTokenURI = _baseTokenURI;
    }

    // Переопределяем tokenURI для поддержки метаданных
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for nonexistent token");
        // Генерируем URI: ipfs://<baseTokenURI>/common/12.json или /event/12.json и т.д.
        // Предполагаем, что мы определили редкость билета (например, через mapping)
        // В данном примере используем простую логику: если tokenId < 90, то Common; если < 99, то Event; иначе Legendary
        if (tokenId < 90) {
            return string(abi.encodePacked(baseTokenURI, "/common/", Strings.toString(tokenId), ".json"));
        } else if (tokenId < 99) {
            return string(abi.encodePacked(baseTokenURI, "/event/", Strings.toString(tokenId), ".json"));
        } else {
            return string(abi.encodePacked(baseTokenURI, "/legendary/", Strings.toString(tokenId), ".json"));
        }
    }

    // Минт на указанный адрес (будет вызываться из LotteryCore)
    function mintBatch(address to, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        _mint(to, amount);
        // Логика пула (availableTickets) теперь в LotteryCore
    }
}