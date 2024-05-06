import "@stdlib/deploy";
import "./imports/structs.tact";
import "./imports/dao_wallet.tact";

contract DAOContract with Deployable, DAOWallet {
    // DAOWallet state
    totalSupply: Int as coins;
    mintable: Bool;
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
    proposals_total: Int as uint32;
    dao_status: Int = 0; 
    /*
    -1: active, 
    0: not active, 
    1: paused
    */

    init(params: DeployNewDAO) {
        self.owner = params.owner;
        self.totalSupply = 0;
        self.mintable = true;
        self.max_supply = params.max_supply;
        self.proposals_total = 0;
        self.dao_status = 0;
    }

    // receive(params: NewAdmin){
    //     self.requireOwner();
    //     require(params.newAdmin != newAddress(0,0), "Invalid address");
    //     self.collectionAdmin = params.newAdmin;
    // }

    get fun calculateWalletAddress(to: Address): Address{
        let init: StateInit = self.getJettonWalletInit(to);

        return contractAddress(init);
    }

    get fun hashProposal(params: ProposalParams): Int {
        return self.getHashProposal(params);
    }

    get fun getProposalStatus(proposal_id: Int): Int {
        let proposal: Proposal? = self.proposals.get(proposal_id);

        if (proposal == null) {
            return -2; // Proposal not found
        }

        let actualProposal: Proposal = proposal!!;

        if (actualProposal.canceled){
            return -1; //Canceled
        }
        if (actualProposal.executed){
            return 2; //Executed
        }
        if (actualProposal.vote_end > now() && actualProposal.vote_start <= now()){
            return 1; //Voting
        }
        return 0; //Not started
    }

    get fun getDeadline(proposal_id: Int): Int {
        let proposal: Proposal? = self.proposals.get(proposal_id);
        if (proposal == null) {
            return 0; // Proposal not found
        } else {
            let actualProposal: Proposal = proposal!!;
            return actualProposal.vote_end;
        }
    }

    get fun getMintable(): Bool {
        return self.mintable;
    }

    // get fun getVotes(user: Address): Int {
    //     let user_wallet = self.calculateWalletAddress(user);
    //     self.makeCall(CallParams{
    //         to: user_wallet,
    //         value: "0.1",
    //         mode: 0,
    //         body: "getWalletData".asComment(),
    //         bounce: false
    //     });
    // }

    fun getHashProposal(params: ProposalParams): Int {
        require(params.targetsLength == params.valuesLength, 
            "Targets and Values length mismatch");

        let cb: Builder = beginCell();
        cb.storeInt(params.description_hash, 32);
        cb.storeInt(params.vote_start, 32);
        cb.storeInt(params.vote_end, 32);
        cb.storeInt(params.quorum, 32);
        cb.storeInt(params.execution_delay, 32);
        
        let i: Int = params.targetsStart;
        repeat (params.targetsLength) {
            cb.storeAddress(params.targets.get(i)!!);
            i = i + 1;
        }
        
        i = params.valuesStart;
        repeat (params.valuesLength) {
            cb.storeInt(params.values.get(i)!!, 32);
            i = i + 1;
        }
        cb.endCell();
        return cb.asCell().hash();
    }

    // fun makeCall(params: CallParams){
    //     send(SendParameters{
    //         to: params.to,
    //         value: params.value,
    //         mode: params.mode,
    //         // body: SetCertificateParams {link: params.link, owner: params.owner}.toCell(),
    //         body: params.body,
    //         bounce: params.bounce
    //     });
    // }

    // ==================== DAOWallet functions ====================

    receive("Owner: DepositClose") {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not Owner");
        self.mintable = false;
    }

    receive("Owner: DepositOpen") {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not Owner");
        self.mintable = true;
    }

    receive(msg: Deposit) {
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
