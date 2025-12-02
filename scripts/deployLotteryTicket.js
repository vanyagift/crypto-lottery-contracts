// scripts/deployLotteryTicket.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying LotteryTicket contract with account:", deployer.address);

    // === ВАЖНО: УКАЖИ РЕАЛЬНЫЙ АДРЕС ТВОЕГО ТОКЕНА ===
    const lottoTokenAddress = "0x1d783f2781a8673Eb8D7eeF3CB285fac409D0fdE"; // <- Замени

    // Базовый URI для метаданных (можно изменить позже, если добавить setBaseURI)
    const baseTokenURI = "ipfs://bafybeif6qmgw255kgoegb6b754irnugslz7hjcxsmep5acuezrvd32kthy"; // <- Замени на реальный CID

    const LotteryTicket = await ethers.getContractFactory("LotteryTicket");

    // === Используем стандартный deploy для НЕ upgradable контракта ===
    console.log("Deploying...");
    const lotteryTicket = await LotteryTicket.deploy(lottoTokenAddress, baseTokenURI);

    await lotteryTicket.waitForDeployment();

    const lotteryTicketAddress = await lotteryTicket.getAddress();

    console.log("✅ LotteryTicket deployed to:", lotteryTicketAddress);
    console.log("Using LOTTO token at:", lottoTokenAddress);
    console.log("Using baseTokenURI:", baseTokenURI);

    // Опционально: верифицируй контракт на BscScan
    // await hre.run("verify:verify", {
    //     address: lotteryTicketAddress,
    //     constructorArguments: [lottoTokenAddress, baseTokenURI],
    // });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
