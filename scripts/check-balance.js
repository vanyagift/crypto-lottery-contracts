const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  // Вставь адрес токена из BSCScan (после успешного деплоя)
  const tokenAddress = 0x3ade5f72bdf231a16abedf04241363ec200a0c0c; // ← замени на настоящий адрес токена

  // Подключись к провайдеру
  const provider = ethers.provider;

  // ABI для ERC-20 токена (минимальный набор)
  const tokenABI = [
    "function balanceOf(address account) view returns (uint256)",
    "function decimals() view returns (uint8)",
  ];

  // Создай экземпляр контракта
  const Token = new ethers.Contract(tokenAddress, tokenABI, provider);

  // Получи баланс deployer'а
  const balance = await Token.balanceOf(deployer.address);
  const decimals = await Token.decimals();

  console.log(
    `Баланс аккаунта ${deployer.address}: ${(
      balance /
      10 ** decimals
    ).toString()} LOTTO`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
