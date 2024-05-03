message DeployNewDAO {
    admin: Address;
}

struct Proposal {
    // 17 total fields
    description_hash: Int; //хэш описания
    vote_start: Int; //timestamp начала голосования (должен быть в будущем, и не ранее, чем через число дней, определённое в ланчпаде)
    vote_end: Int;//timestamp окончания голосования (должно быть > voteStart, и не ранее, чем число дней определённое в ланчпаде)
    quorum: Int; //не менее и не более определённого в ланчпаде
    execution_delay: Int; // - не менее и не более определённого в ланчпаде
    voted: bool; // - завершился ли период голосования
    executed: bool; // - был ли исполнен пропозал
    canceled: bool; // - был ли отменен пропозал

    targets: map<Int, Address>; // - адреса для трансфера
    targetsLength: Int as uint8 = 0;
    targetsStart: Int as uint8 = 0;

    values: map<Int, Int>; // - значения для перечисления
    valuesLength: Int as uint8 = 0;
    valuesStart: Int as uint8 = 0;
}

message ProposalParams {
    description_hash: Int;
    vote_start: Int;
    vote_end: Int;
    quorum: Int;
    execution_delay: Int;
    targets: map<Int, Address>;
    targetsLength: Int;
    targetsStart: Int;
    values: map<Int, Int>;
    valuesLength: Int;
    valuesStart: Int;
}

// Jetton Structs

struct JettonWalletData {
    balance: Int;
    owner: Address;
    master: Address;
    walletCode: Cell;
}

message WalletData {
    balance: Int;
    owner: Address;
    master: Address;
}

struct CallParams{
    to: Address;
    value: String;
    mode: Int as uint8;
    body: Cell;
    bounce: Bool;
}

message(0xf8a7ea5) TokenTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    response_destination: Address;
    custom_payload: Cell?;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
}

message(0x178d4519) TokenTransferInternal {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    response_destination: Address;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
}

message(0x7362d09c) TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton 
}

message(0x595f07bc) TokenBurn {
    queryId: Int as uint64;
    amount: Int as coins;
    owner: Address;
    response_destination: Address;
}

message(0x7bdd97de) TokenBurnNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    owner: Address;
    response_destination: Address?;
}

message(0xd53276db) TokenExcesses {
    queryId: Int as uint64;
}

message TokenUpdateContent {
    content: Cell;
}

message Deposit {
    amount: Int;
    receiver: Address;
}

struct JettonData {
    totalSupply: Int;
    mintable: Bool;
    owner: Address;
    content: Cell;
    walletCode: Cell;
}
