На основе контракта Governor от OZ: https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor


Конструктор: 
launchpool_contract (Address)
hash (String)


Глобальные переменные:


Struct Proposal {
        description_hash (String) - хэш описания
        vote_start (int) - timestamp начала голосования (должен быть в будущем, и не ранее, чем через число дней, определённое в ланчпаде)
        vote_end (int) - timestamp окончания голосования (должно быть > voteStart, и не ранее, чем число дней определённое в ланчпаде)
        quorum (int) - не менее и не более определённого в ланчпаде
        execution_delay (int) - не менее и не более определённого в ланчпаде
        targets (Address[]) - адреса кошельков для перечислений
        values (int[]) - значения для перечисления
        calldatas (String[]) - данные для вызова
}


hash (String)
voted (bool)
executed (bool)
canceled (bool)
launchpool_contract (Address)
proposal (Proposal)


Get Функции:
hashProposal(desc_hash, vote_start, vote_end, quorum, execution_delay, targets[], values[], calldatas[]) (String) - вычисляет хэш из введённых данных
getProposalStatus(proposal_id) (int) - возвращает статус пропозала исходя из текущего статуса выполнения. Может быть Выполнен, Отменён, Ожидание, Голосование
getDeadline(proposal_id) (int) - возвращает proposal.vote_end
getVotes(account) (int) - возвращает voting power аккаунта
hasVoted(account) (bool) - показывает, отдал ли свой голос аккаунт


Set Функции:
setProposalParams(desc_hash, vote_start, vote_end, quorum, execution_delay, targets[], values[], calldatas[]) onlyLaunchPool - задаёт параметры пропосала после деплоя. Должна вычислисть хэш из введённых параметров, и получить тот же хэш, что был задан в конструкторе
cancel(proposal_id) onlyLaunchPool - может быть отменён только ланчпулом, но только в период до начала голосования (Ожидание)
execute(proposal_id) - вызывается кем угодно, исполняет пропозал, делает транзакции на указанные адреса. Требуется чтобы были достигнуты дедлайн (vote_end), quorum и execution_delay
castVote(prposal_id, support) - сохраняет голос участника с его voting power, минтит nft с голосом, и voting power


Ивенты:
ProposalCanceled(proposal_id)
ProposalExecuted(proposal_id)
VoteCast(proposal_id, account, voting_power, support)