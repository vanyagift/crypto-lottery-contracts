// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title LotteryCore
 * @dev Основной контракт логики лотереи. Upgradable.
 * Взаимодействует с контрактом NFT-билетов (LotteryTicket).
 */
contract LotteryCore is Initializable, OwnableUpgradeable {
    using Strings for uint256;

    // ============ СТРУКТУРЫ ДАННЫХ ============
    struct User {
        uint256 balance; // Баланс пользователя в LOTTO
    }

    // ============ НАСТРОЙКИ ============
    IERC20 public lottoToken;
    IERC721 public lotteryTicketNFT; // Интерфейс для взаимодействия с NFT-контрактом

    uint256 public constant TICKET_PRICE = 100 * 10**18; // Цена билета
    uint256 public constant WITHDRAWAL_FEE = 3 * 10**18;  // Комиссия за вывод

    // ============ ХРАНИЛИЩЕ ДАННЫХ ============
    mapping(address => User) public users;
    uint256[] public availableTickets; // Пул доступных билетов (ID)

    // ============ ИНИЦИАЛИЗАЦИЯ ============
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _lottoToken, address _lotteryTicketNFT) public initializer {
        __Ownable_init(msg.sender);
        require(_lottoToken != address(0), "Invalid LOTTO token address");
        require(_lotteryTicketNFT != address(0), "Invalid LotteryTicket NFT address");
        lottoToken = IERC20(_lottoToken);
        lotteryTicketNFT = IERC721(_lotteryTicketNFT);
    }

    // ============ ЛОГИКА ПОЛЬЗОВАТЕЛЯ ============
    // Вызывается off-chain сервисом после получения approve + deposit от пользователя
    function depositForUser(address user, uint256 amount) external onlyOwner {
        // В реальном сценарии, должна быть проверка transferFrom
        users[user].balance += amount;
    }

    function getUserBalance(address user) external view returns (uint256) {
        return users[user].balance;
    }

    // ============ ЛОГИКА ПОКУПКИ БИЛЕТА ============
    function buyTicket() external {
        User storage user = users[msg.sender];

        require(user.balance >= TICKET_PRICE, "Insufficient balance");
        require(availableTickets.length > 0, "No tickets available");

        user.balance -= TICKET_PRICE;

        // Выбрать случайный билет из пула
        uint256 randomSeed = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, gasleft(), availableTickets.length))
        );
        uint256 randomIndex = randomSeed % availableTickets.length;
        uint256 tokenId = availableTickets[randomIndex];

        // Удалить билет из пула
        availableTickets[randomIndex] = availableTickets[availableTickets.length - 1];
        availableTickets.pop();

        // Передать билет пользователю
        lotteryTicketNFT.transferFrom(address(this), msg.sender, tokenId);

        emit TicketPurchased(msg.sender, tokenId);
    }

    // ============ УПРАВЛЕНИЕ ПУЛОМ БИЛЕТОВ ============
    // Вызывается ownerом или автоматически, когда пул заканчивается
    function refillTicketPool(uint256[] memory ticketIds) external onlyOwner {
        for (uint256 i = 0; i < ticketIds.length; i++) {
            availableTickets.push(ticketIds[i]);
        }
        emit TicketPoolRefilled(ticketIds.length);
    }

    // ============ ВЫВОД СРЕДСТВ ============
    function withdraw(uint256 amount) external {
        User storage user = users[msg.sender];
        require(user.balance >= amount, "Insufficient balance");

        uint256 fee = WITHDRAWAL_FEE;
        require(amount > fee, "Amount must be greater than fee");
        uint256 netAmount = amount - fee;

        user.balance -= amount;

        require(lottoToken.transfer(msg.sender, netAmount), "Transfer failed");
        // Комиссия остается на балансе контракта

        emit Withdrawal(msg.sender, amount, netAmount, fee);
    }

    // ============ СОБЫТИЯ ============
    event TicketPurchased(address indexed buyer, uint256 indexed tokenId);
    event TicketPoolRefilled(uint256 amount);
    event Withdrawal(address indexed user, uint256 amount, uint256 netAmount, uint256 fee);
}