import { Address, toNano } from '@ton/core';
import { DAOContract } from '../wrappers/DAOContract';
import { NetworkProvider } from '@ton/blueprint';


let workChain = 0; // fill in the workChain
let hash = Buffer.from(''); // fill in the hash
let deployer = new Address(workChain, hash);

export async function run(provider: NetworkProvider) {
    const dAOContract = provider.open(await DAOContract.fromInit({
        $$type: 'DeployNewDAO',
        owner: deployer,
        max_supply: toNano('1000000'),
    }));

    await dAOContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        }, 
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(dAOContract.address);

    // run methods on `dAOContract`
}
