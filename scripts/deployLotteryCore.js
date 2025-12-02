// scripts/deployLotteryCore.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying LotteryCore contract with account:", deployer.address);

    // === ВАЖНО: ВСТАВЬ СЮДА АДРЕСА ТВОИХ КОНТРАКТОВ ===
    const lottoTokenAddress = "0x1d783f2781a8673Eb8D7eeF3CB285fac409D0fdE"; // Адрес CryptoLotteryToken
    const lotteryTicketAddress = "0x96C453dcfd1042876B57Bf599E56495ef65b3e47"; // Адрес LotteryTicket

    const LotteryCore = await ethers.getContractFactory("LotteryCore");

    console.log("Deploying LotteryCore (Upgradable)...");

    // === Деплой Upgradable контракта ===
    const lotteryCore = await upgrades.deployProxy(
        LotteryCore,
        [lottoTokenAddress, lotteryTicketAddress], // Аргументы для функции initialize
        { initializer: 'initialize' } // Указываем, что инициализация происходит через функцию initialize
    );

    await lotteryCore.waitForDeployment();

    const lotteryCoreAddress = await lotteryCore.getAddress();

    console.log("✅ LotteryCore (Proxy) deployed to:", lotteryCoreAddress);
    console.log("   Implementation address:", await upgrades.erc1967.getImplementationAddress(lotteryCoreAddress));
    console.log("   Admin address:", await upgrades.erc1967.getAdminAddress(lotteryCoreAddress));

    // === Сохрани адрес для следующих шагов ===
    console.log("\n--- ВАЖНО: Сохрани этот адрес для следующих шагов ---");
    console.log("LotteryCore Proxy Address:", lotteryCoreAddress);
    console.log("--- ВАЖНО ---");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});