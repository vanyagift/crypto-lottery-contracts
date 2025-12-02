module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const token = await deploy("CryptoLotteryToken", {
    contract: "CryptoLotteryToken",
    from: deployer,
    args: [],
    log: true,
  });

  console.log("✅ Token deployed to:", token.address);
};

module.exports.tags = ["CryptoLotteryToken"];