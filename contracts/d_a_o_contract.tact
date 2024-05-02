import "@stdlib/deploy";
import "./imports/structs.tact";
import "./imports/dao_wallet.tact";

contract DAOContract with Deployable, DAOWallet {
    // DAOWallet state
    totalSupply: Int as coins;
    mintable: true;
    owner: Address;
    max_supply: Int as coins;
    // End of DAOWallet state

    const dao_min_voting_delay: Int = 0; // start immidiately
    const dao_max_voting_delay: Int = (60 * 60 * 24 * 3); // 3 days
    const dao_min_execution_delay: Int = 0; // execute immidiately
    const dao_max_execution_delay: Int = (60 * 60 * 24 * 3); // 3 days
    const dao_min_voting_duration: Int = (60 * 60 * 24 * 3); // 3 days
    const dao_max_voting_duration: Int = (60 * 60 * 24 * 30); // 30 days
    const dao_min_quorum: Int = 51; // 51% of the total voters
    const dao_max_quorum: Int = 90; // 90% of the total voters

    // hash -> Proposal
    proposals: map<Int, Proposal>; 
    proposals_total: Int as uint14;
    dao_status: Int = 0; 
    /*
    -1: active, 
    0: not active, 
    1: paused
    */

    init(params: DeployNewDAO) {
        self.admin = params.admin;
        self.totalSupply = 0;
        self.mintable = true;
        self.owner = owner;
        self.max_supply = max_supply;
    }

    receive(params: NewAdmin){
        self.requireOwner();
        require(params.newAdmin != newAddress(0,0), "Invalid address");
        self.collectionAdmin = params.newAdmin;
    }

    get fun calculateAddress(address: Address): Address{
        let init: StateInit = initOf Certificate(self.certificatesCount, myAddress());

        return contractAddress(init);
    }

    fun hashProposal(params: ProposalParams): Int {
        require(params.targetsLength == params.valuesLength, 
            "Targets and Values length mismatch");

        let cb = beginCell();
        cb.storeInt(params.description_hash);
        cb.storeInt(params.vote_start);
        cb.storeInt(params.vote_end);
        cb.storeInt(params.quorum);
        cb.storeInt(params.execution_delay);
        
        let i: Int = params.targetsStart;
        repeat (params.targetsLength) {
            cb.storeAddress(params.targets[i]);
            i = i + 1;
        }
        
        i = params.valuesStart;
        repeat (params.valuesLength) {
            cb.storeInt(params.values[i]);
            i = i + 1;
        }
        cb.endCell();
        return cb.hash();
    }

    fun makeCall(){
        send(SendParameters{
            to: self.lastMintedCertificate,
            value: ton("0.1"),
            mode: SendIgnoreErrors,
            body: SetCertificateParams {link: params.link, owner: params.owner}.toCell(),
            bounce: false
        });
    }

    // ==================== DAOWallet functions ====================

    receive("Owner: MintClose") {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not Owner");
        self.mintable = false;
    }

    receive(msg: Mint) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not Owner");
        require(self.mintable, "Can't Mint Anymore");
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination)
    }

    receive("Mint: 100") { // Public Minting
        let ctx: Context = context();
        require(self.mintable, "Can't Mint Anymore");
        self.mint(ctx.sender, 100, self.owner);
    }
}
