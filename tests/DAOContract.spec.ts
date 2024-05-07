import { Blockchain, SandboxContract, TreasuryContract, printTransactionFees } from '@ton/sandbox';
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
    let wallet2: SandboxContract<JettonDefaultWallet>;

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

        // console.log("tx: ", tx);
        console.log("Print Transaction Fees: ", printTransactionFees(tx.transactions));

        tx.events.forEach(event => {
            if(event.type === 'account_created') {
                wallet = blockchain.openContract(JettonDefaultWallet.fromAddress(event.account));
            }
        });

        // wallet = blockchain.openContract(await JettonDefaultWallet.fromAddress(certAddress));

        const walletData = await wallet.getGetWalletData();
        // expect(investorBalance).toEqual(toNano('1'));
        console.log("investorBalance 1: ", walletData.balance);
        console.log("Wallet Master address 1: ", walletData.master);
        console.log("DAO address 1: ", daoContract.address);
        console.log("Wallet owner 1: ", walletData.owner);
        console.log("investor address 1: ", investor.address);
        
        const tx2 = await daoContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            "Mint: 100"
        );

        tx2.events.forEach(event => {
            if(event.type === 'account_created') {
                wallet2 = blockchain.openContract(JettonDefaultWallet.fromAddress(event.account));
            }
        });

        const walletData2 = await wallet2.getGetWalletData();
        console.log("investorBalance 2: ", walletData.balance);
        console.log("Wallet Master address 2: ", walletData.master);
        console.log("DAO address 2: ", daoContract.address);
        console.log("Wallet owner 2: ", walletData.owner);
        console.log("investor address 2: ", investor.address);
    });

    it('Someone can create wallet', async () => {

    });
});
