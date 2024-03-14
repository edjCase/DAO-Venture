import Dao "../Dao";
import Types "Types";
import LeagueTypes "../league/Types";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import ScenarioVoting "ScenarioVoting";
import UsersActor "canister:users";

module {

    public type StableData = {
        leagueId : Principal;
        teamId : Nat;
        scenarioVoting : [ScenarioVoting.StableData];
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
            };
        };

        func onReject(proposal : Dao.Proposal<Types.ProposalContent>) : async* () {
            Debug.print("Rejected proposal: " # debug_show (proposal));
        };
        var dao = Dao.Dao<Types.ProposalContent>(stableData.dao, onExecute, onReject);

        var scenarioVotingManager = ScenarioVoting.Manager(stableData.scenarioVoting);

        public func onInit<system>() {
            dao.resetEndTimers<system>();
        };

        public func voteOnScenario(caller : Principal, request : Types.VoteOnScenarioRequest) : async* Types.VoteOnScenarioResult {
            let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
            switch (await UsersActor.get(caller)) {
                case (#ok(user)) {
                    let ?team = user.team else return #notAuthorized;
                    if (team.id != teamId) {
                        return #notAuthorized;
                    };
                    let #owner(o) = team.kind else return #notAuthorized;
                    handler.vote(caller, o.votingPower, request.option);
                };
                case (#notFound or #notAuthorized) #notAuthorized;
            };
        };

        public func getScenarioVote(scenarioId : Text, caller : Principal) : Types.GetScenarioVoteResult {
            let ?handler = scenarioVotingManager.getHandler(scenarioId) else return #scenarioNotFound;
            #ok(handler.getVote(caller));
        };

        public func getWinningScenarioOption(scenarioId : Text) : Types.GetWinningScenarioOptionResult {
            let ?handler = scenarioVotingManager.getHandler(scenarioId) else return #scenarioNotFound;
            let ?winningOption = handler.calculateWinningOption() else return #noVotes;
            #ok(winningOption);
        };

        public func onNewScenario(request : Types.OnNewScenarioRequest) : Types.OnNewScenarioResult {

            scenarioVotingManager.add(request.scenarioId, request.optionCount);
            #ok;
        };

        public func onScenarioVoteComplete(request : Types.OnScenarioVoteCompleteRequest) : async Types.OnScenarioVoteCompleteResult {
            switch (scenarioVotingManager.remove(request.scenarioId)) {
                case (#ok) #ok;
                case (#notFound) #scenarioNotFound;
            };
        };

    };
};
