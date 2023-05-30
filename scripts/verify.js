require ('@nomiclabs/hardhat-etherscan')
const hre = require( 'hardhat')


const _initBaseURI='ipfs://QmYG397NbS5FLxNbo2oavBSSid5MwJ6jXidxpDgQgDdJL9/'

async function main() {

  await hre.run('verify:verify', {
    address: '0xEd71cEb9962EFf5305B5990DA21070f8275C5647',
    constructorArguments: [_initBaseURI]
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })