import Dao "../Dao";
import Types "Types";
import LeagueTypes "../league/Types";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import CommonTypes "../Types";
import PlayersActor "canister:players";

module {

    public type StableData = {
        leagueId : Principal;
        teamId : Nat;
        dao : Dao.StableData<Types.ProposalContent>;
    };

    public class MultiHandler<system>(teams : [(Nat, StableData)]) {
        let handlers : HashMap.HashMap<Nat, Handler> = HashMap.HashMap<Nat, Handler>(teams.size(), Nat.equal, Nat32.fromNat);

        for ((id, stableData) in Iter.fromArray(teams)) {
            let handler = Handler(stableData);
            handler.onInit<system>();
            handlers.put(id, handler);
        };

        var nextTeamId = teams.size(); // TODO change to check for the largest team id in the list

        public func toStableData() : [(Nat, StableData)] {
            handlers.entries()
            |> Iter.map<(Nat, Handler), (Nat, StableData)>(
                _,
                func((teamId, handler) : (Nat, Handler)) : (Nat, StableData) {
                    (teamId, handler.toStableData());
                },
            )
            |> Iter.toArray(_);
        };

        public func get(teamId : Nat) : ?Handler {
            handlers.get(teamId);
        };

        public func create(leagueId : Principal) : (Nat, Handler) {
            let teamId = nextTeamId;
            nextTeamId += 1;
            let handler = Handler({
                leagueId = leagueId;
                teamId = teamId;
                dao = {
                    proposals = [];
                    proposalDuration = #days(3);
                    votingThreshold = #percent({
                        percent = 50;
                        quorum = ?20;
                    });
                };
                scenarioVoting = [];
            });
            handlers.put(teamId, handler);
            (teamId, handler);
        };
    };

    public class Handler(stableData : StableData) {
        let leagueId = stableData.leagueId;
        let teamId = stableData.teamId;

        func onExecute(proposal : Dao.Proposal<Types.ProposalContent>) : async* Dao.OnExecuteResult {
            switch (proposal.content) {
                case (#trainPlayer(trainPlayer)) {
                    // TODO
                    Debug.print("Training player: " # debug_show (trainPlayer));
                    #ok;
                };
                case (#changeName(n)) {
                    let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
                    let result = await leagueActor.createProposal({
                        content = #changeTeamName({
                            teamId = teamId;
                            name = n.name;
                        });
                    });
                    switch (result) {
                        case (#ok(_)) #ok;
                        case (#notAuthorized) #err("Not authorized to create change name proposal in league DAO");
                    };
                };
                case (#swapPlayerPositions(swap)) {
                    switch (await PlayersActor.swapTeamPositions(teamId, swap.position1, swap.position2)) {
                        case (#ok) #ok;
                        case (#notAuthorized) #err("Not authorized to swap player positions in players actor");
                    };
                };
            };
        };

        func onReject(proposal : Dao.Proposal<Types.ProposalContent>) : async* () {
            Debug.print("Rejected proposal: " # debug_show (proposal));
        };
        var dao = Dao.Dao<Types.ProposalContent>(stableData.dao, onExecute, onReject);

        public func onInit<system>() {
            dao.resetEndTimers<system>();
        };

        public func toStableData() : StableData {
            {
                leagueId = leagueId;
                teamId = teamId;
                dao = dao.toStableData();
            };
        };

        public func getProposal(id : Nat) : ?Dao.Proposal<Types.ProposalContent> {
            dao.getProposal(id);
        };

        public func getProposals(count : Nat, offset : Nat) : CommonTypes.PagedResult<Dao.Proposal<Types.ProposalContent>> {
            dao.getProposals(count, offset);
        };

        public func voteOnProposal(caller : Principal, request : Types.VoteOnProposalRequest) : async* Types.VoteOnProposalResult {
            await* dao.vote(request.proposalId, caller, request.vote);
        };

        public func createProposal<system>(caller : Principal, request : Types.CreateProposalRequest, members : [Dao.Member]) : Types.CreateProposalResult {
            dao.createProposal<system>(caller, request.content, members);
        };

    };
};
