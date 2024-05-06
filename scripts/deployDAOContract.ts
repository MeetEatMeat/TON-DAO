import { toNano } from '@ton/core';
import { DAOContract } from '../wrappers/DAOContract';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const dAOContract = provider.open(await DAOContract.fromInit());

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
