import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { DAOContract } from '../wrappers/DAOContract';
import '@ton/test-utils';

describe('DAOContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let dAOContract: SandboxContract<DAOContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        dAOContract = blockchain.openContract(await DAOContract.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await dAOContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: dAOContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and dAOContract are ready to use
    });
});
