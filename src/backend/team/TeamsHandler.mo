import Dao "../Dao";
import Types "Types";
import LeagueTypes "../league/Types";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import CommonTypes "../Types";
import PlayersActor "canister:players";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";

module {

    public type StableData = {
        leagueId : Principal;
        teamId : Nat;
        dao : Dao.StableData<Types.ProposalContent>;
        links : [Link];
    };

    public type Link = {
        name : Text;
        url : Text;
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
                links = [];
            });
            handlers.put(teamId, handler);
            (teamId, handler);
        };
    };

    public class Handler(stableData : StableData) {
        let leagueId = stableData.leagueId;
        let teamId = stableData.teamId;
        let links = Buffer.fromArray<Link>(stableData.links);

        func onExecute(proposal : Dao.Proposal<Types.ProposalContent>) : async* Dao.OnExecuteResult {
            let createLeagueProposal = func(content : LeagueTypes.ProposalContent) : async* Dao.OnExecuteResult {
                let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
                try {
                    let result = await leagueActor.createProposal({
                        content = content;
                    });
                    switch (result) {
                        case (#ok(_)) #ok;
                        case (#notAuthorized) #err("Not authorized to create change name proposal in league DAO");
                    };
                } catch (err) {
                    #err("Error creating change name proposal in league DAO: " # Error.message(err));
                };
            };
            switch (proposal.content) {
                case (#train(train)) {
                    try {
                        // TODO make the 'applyEffects' generic, not scenario specific
                        let trainSkillEffect : Scenario.PlayerEffectOutcome = #skill({
                            target = #positions([{
                                teamId = teamId;
                                position = train.position;
                            }]);
                            delta = 1;
                            duration = #indefinite;
                            skill = train.skill;
                        });
                        switch (await PlayersActor.applyEffects([trainSkillEffect])) {
                            case (#ok) #ok;
                            case (#notAuthorized) #err("Not authorized to train player in players actor");
                        };
                    } catch (err) {
                        #err("Error training player in players actor: " # Error.message(err));
                    };
                };
                case (#changeName(n)) {
                    let leagueProposal = #changeTeamName({
                        teamId = teamId;
                        name = n.name;
                    });
                    await* createLeagueProposal(leagueProposal);
                };
                case (#swapPlayerPositions(swap)) {
                    try {
                        switch (await PlayersActor.swapTeamPositions(teamId, swap.position1, swap.position2)) {
                            case (#ok) #ok;
                            case (#notAuthorized) #err("Not authorized to swap player positions in players actor");
                        };
                    } catch (err) {
                        #err("Error swapping player positions in players actor: " # Error.message(err));
                    };
                };
                case (#changeColor(changeColor)) {
                    await* createLeagueProposal(#changeTeamColor({ teamId = teamId; color = changeColor.color }));
                };
                case (#changeLogo(changeLogo)) {
                    await* createLeagueProposal(#changeTeamLogo({ teamId = teamId; logoUrl = changeLogo.logoUrl }));
                };
                case (#changeMotto(changeMotto)) {
                    await* createLeagueProposal(#changeTeamMotto({ teamId = teamId; motto = changeMotto.motto }));
                };
                case (#changeDescription(changeDescription)) {
                    await* createLeagueProposal(#changeTeamDescription({ teamId = teamId; description = changeDescription.description }));
                };
                case (#addLink(addLink)) {
                    if (IterTools.any(links.vals(), func(link : Link) : Bool { link.name == addLink.name })) {
                        return #err("Link with name '" # addLink.name # "' already exists");
                    };
                    links.add({
                        name = addLink.name;
                        url = addLink.url;
                    });
                    #ok;
                };
                case (#removeLink(removeLink)) {
                    links.filterEntries(func(i : Nat, link : Link) : Bool { link.name != removeLink.name });
                    // TODO do we care if the link was not found?
                    #ok;
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
                links = Buffer.toArray(links);
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
