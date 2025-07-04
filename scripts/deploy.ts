import hre from "hardhat"
import { setupAccounts } from "./utils/accounts"
import dotenv from "dotenv"
dotenv.config()

async function main() {
    const [owner, otherAccount] = await setupAccounts()

    // const PrivateStorageFactory = await hre.ethers.getContractFactory("PrivateStorage")
    // const privateStorage = await PrivateStorageFactory
    //     .connect(owner)
    //     .deploy()
    // await privateStorage.waitForDeployment()
    // console.log("Contract address for PrivateStorage:",await privateStorage.getAddress())

    //  const MyPrivateToken = await hre.ethers.getContractFactory("MyPrivateToken")
    //  const privateToken = await MyPrivateToken
    //     .connect(owner) 
    //     .deploy()
    
    // await privateToken.waitForDeployment()

    // console.log("Contract address for Private ERC20:",await privateToken.getAddress())

 const _tokenA = process.env.TOKENA_ADDRESS;
  const _tokenB = process.env.TOKENB_ADDRESS;
  if (!_tokenA || !_tokenB) {
  throw new Error("TOKENA_ADDRESS or TOKENB_ADDRESS is not defined properly in the .env file.");
}
     const PrivateSwap = await hre.ethers.getContractFactory("PrivateSwap")
     const privateSwap = await PrivateSwap
        .connect(owner) 
        .deploy(_tokenA as string,_tokenB as string )
    
    await privateSwap.waitForDeployment()

    console.log("Contract address for Private ERC20 swap:",await privateSwap.getAddress())
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})