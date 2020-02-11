const etherlime = require('etherlime-lib')
const ethers = require('ethers')

require('dotenv').config()

const deploy = async (network, secret) => {
  console.log(``)
  console.log(`Initialize Deployer`)
  console.log(``)

  let defaultGas = ethers.utils.parseUnits('15', 'gwei')
  let deployer = await new etherlime.InfuraPrivateKeyDeployer(
    process.env.DEPLOYMENT_PRIV_KEY,
    network,
    process.env.INFURA_API_KEY,
    { gasPrice: defaultGas, etherscanApiKey: process.env.ETHERSCAN_API_KEY },
  )

  console.log(`Deployment Wallet: ${deployer.signer.address}`)

  // deploy template

  const multisig_template_artifact = require('../build/MultiSigWallet.json')
  const multisig_template = await deployer.deployAndVerify(
    multisig_template_artifact,
  )

  // deploy factory

  const multisig_factory_artifact = require('../build/MultiSigWallet_Factory.json')
  const multisig_factory = await deployer.deployAndVerify(
    multisig_factory_artifact,
    false,
    ethers.constants.AddressZero,
    multisig_template.contractAddress,
  )

  // deploy wallet manager

  // const MULTISIG_FACTORY_ADDRESS = {
  //   kovan: '0x4B0A1edf742b1117A31f820b135acB1Add45a6F0',
  //   mainnet: '0x789e3a833fab4A64CeF8864b1CC0BC1787c0Dc1f',
  // }

  const wallet_manager_artifact = require('../build/WalletManager.json')
  const wallet_manager = await deployer.deployAndVerify(
    wallet_manager_artifact,
    false,
    multisig_factory.contractAddress,
    // MULTISIG_FACTORY_ADDRESS[network],
  )

  const MULTISIG_ABI = multisig_template_artifact.abi
  const walletInterface = new ethers.utils.Interface(MULTISIG_ABI)
  const calldata = walletInterface.functions.initialize.encode([
    ['0x474C80E1e6Bfd3283c9F31979AAc920A0F89a7AA'],
    1,
  ])
  console.log('calldata', calldata)

  const createdirect = await multisig_factory.create(calldata)
  console.log('createdirect', createdirect)

  const _getInitCalldata = await wallet_manager._getInitCalldata()
  console.log('_getInitCalldata', _getInitCalldata)

  console.log(
    'decoded',
    ethers.utils.defaultAbiCoder.decode(
      ['address[]', 'uint256'],
      ethers.utils.hexDataSlice(_getInitCalldata, 4),
    ),
  )

  const create = await wallet_manager.create()
  await create.wait(2)
  console.log('create', create)

  // await wallet_manager
  //   .getSaltyInstance(ethers.utils.id('userID'))
  //   .then(console.log)
  // const createSalty = await (
  //   await wallet_manager.createSalty(ethers.utils.id('userID'))
  // ).wait(2)
  // console.log('createSalty', createSalty)
  // await wallet_manager
  //   .getSaltyInstance(ethers.utils.id('userID'))
  //   .then(console.log)

  // console.log('multisig_template', multisig_template.contractAddress)
  // console.log('multisig_factory', multisig_factory.contractAddress)
  console.log('wallet_manager', wallet_manager.contractAddress)
}

module.exports = { deploy }
