async function main() {
  const [account] = await ethers.getSigners();
  console.log("Адрес deployer:", account.address);
}

main();
