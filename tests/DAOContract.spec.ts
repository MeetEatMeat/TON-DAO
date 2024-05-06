import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { DAOContract } from '../wrappers/DAOContract';
import { JettonDefaultWallet } from '../wrappers/JettonDefaultWallet';
import '@ton/test-utils';
import { bigint } from 'zod';

describe('DAOContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let investor: SandboxContract<TreasuryContract>;
    let daoContract: SandboxContract<DAOContract>;
    let wallet: SandboxContract<JettonDefaultWallet>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
        deployer = await blockchain.treasury('deployer');
        investor = await blockchain.treasury('investor');

        daoContract = blockchain.openContract(await DAOContract.fromInit({
            $$type: 'DeployNewDAO',
            owner: deployer.address,
            max_supply: toNano('1000000'),
        }));

        const deployResult = await daoContract.send(
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
            to: daoContract.address,
            deploy: true,
            success: true,
        });
    });

    it('Owner can create wallet for someone', async () => {

        // const mintableBefore = await daoContract.getGetMintable();

        await daoContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            "Owner: DepositOpen"
        );

        // const mintableAfter = await daoContract.getGetMintable();

        // expect(mintableBefore).not.toEqual(mintableAfter);

        const tx = await daoContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deposit',
                amount: toNano('1337'),
                receiver: investor.address
            }
        );

        expect(tx.transactions).toHaveTransaction({
            from: deployer.address,
            to: daoContract.address,
            success: true,
        });

        console.log("tx: ", tx);

        tx.events.forEach(event => {
            if(event.type === 'account_created') {
                wallet = blockchain.openContract(JettonDefaultWallet.fromAddress(event.account));
            }
        });

        // wallet = blockchain.openContract(await JettonDefaultWallet.fromAddress(certAddress));

        const walletData = await wallet.getGetWalletData();
        // expect(investorBalance).toEqual(toNano('1337'));
        console.log("investorBalance: ", walletData.balance);
        console.log("Wallet owner: ", walletData.owner);
        console.log("investor address: ", investor.address);
        console.log("toNano('1337'): ", toNano('1337'));
    });

    it('Someone can create wallet', async () => {

    });
});
