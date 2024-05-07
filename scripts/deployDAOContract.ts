import base64url from 'base64url';
import qs from 'qs';
import { Address, beginCell, storeStateInit, contractAddress, toNano } from 'ton-core';
import { DAOContract } from '../wrappers/DAOContract';
import { NetworkProvider } from '@ton/blueprint';
 
export async function run(provider: NetworkProvider){
    let owner = Address.parse("some-address");
    const max_supply = toNano("1000000");
    const dao = provider.open(await DAOContract.fromInit({
        $$type: 'DeployNewDAO', 
        owner, 
        max_supply
    }));
    let testnet = true;

    await dao.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(dao.address);
}