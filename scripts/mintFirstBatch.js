// scripts/mintFirstBatch.js (обновлённая версия для 100 билетов)
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Minting batch of tickets with account:", deployer.address);

    // === ВАЖНО: УБЕДИСЬ, ЧТО АДРЕСА АКТУАЛЬНЫ ===
    const lotteryTicketAddress = "0x96C453dcfd1042876B57Bf599E56495ef65b3e47"; // Адрес LotteryTicket
    const lotteryCoreProxyAddress = "0x9469Fec51b21dCF48106f08AAc3B2633a65A0d18"; // Адрес прокси LotteryCore

    // Количество билетов для минта (изменили с 1000 на 100)
    const amountToMint = 100; // Было 1000

    // Получаем ABI контракта LotteryTicket (минимальный для вызова mintBatch)
    const lotteryTicketABI = [
        "function mintBatch(address to, uint256 amount) external"
    ];

    // Подключаемся к уже задеплоенному контракту LotteryTicket
    const lotteryTicket = new ethers.Contract(lotteryTicketAddress, lotteryTicketABI, deployer);

    console.log(`Minting ${amountToMint} tickets to LotteryCore (${lotteryCoreProxyAddress})...`);

    // Вызываем функцию mintBatch, отправляя билеты на адрес LotteryCore
    const tx = await lotteryTicket.mintBatch(lotteryCoreProxyAddress, amountToMint);

    console.log("Transaction sent. Hash:", tx.hash);
    console.log("Waiting for confirmation...");

    const receipt = await tx.wait();

    console.log("✅ Mint transaction confirmed!");
    console.log("   Transaction hash:", tx.hash);
    console.log("   Gas used:", receipt.gasUsed.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});