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
import Int "mo:base/Int";
import CommonTypes "../Types";
import PlayersActor "canister:players";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";
import Team "../models/Team";

module {

    public type StableData = {
        id : Nat;
        leagueId : Principal;
        energy : Int;
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        entropy : Nat;
        color : (Nat8, Nat8, Nat8);
        dao : Dao.StableData<Types.ProposalContent>;
        links : [Types.Link];
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

        public func getAll() : [(Nat, Handler)] {
            Iter.toArray(handlers.entries());
        };

        public func getTeams() : [Team.Team] {
            handlers.vals()
            |> Iter.map<Handler, Team.Team>(
                _,
                func(handler : Handler) : Team.Team = handler.get(),
            )
            |> Iter.toArray(_);
        };

        public func create(
            leagueId : Principal, // TODO this should be part of the data, but we don't have a way to pass it in yet
            request : Types.CreateTeamRequest,
        ) : async* Types.CreateTeamResult {
            let nameAlreadyTaken = handlers.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, Handler)) : Bool = v.get().name == request.name,
            );

            if (nameAlreadyTaken) {
                return #nameTaken;
            };
            let teamId = nextTeamId;
            nextTeamId += 1;
            let team : Team.Team = {
                id = teamId;
                name = request.name;
                logoUrl = request.logoUrl;
                motto = request.motto;
                description = request.description;
                color = request.color;
                entropy = 0; // TODO?
                energy = 0;
            };
            let handler = Handler({
                team with
                leagueId = leagueId;
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

            // TODO add retry populating team roster

            try {
                let populateResult = await PlayersActor.populateTeamRoster(teamId);

                switch (populateResult) {
                    case (#ok(_)) {};
                    case (#notAuthorized) {
                        Debug.print("Error populating team roster: League is not authorized to populate team roster for team: " # Nat.toText(teamId));
                    };
                    case (#missingFluff) {
                        Debug.print("Error populating team roster: No unused player fluff available");
                    };
                };
            } catch (err) {
                Debug.print("Error populating team roster: " # Error.message(err));
            };
            return #ok(teamId);
        };
    };

    public class Handler(stableData : StableData) {
        let leagueId = stableData.leagueId;
        let teamId = stableData.id;
        let links = Buffer.fromArray<Types.Link>(stableData.links);
        var energy = stableData.energy;
        var entropy = stableData.entropy;
        var name = stableData.name;
        var logoUrl = stableData.logoUrl;
        var motto = stableData.motto;
        var description = stableData.description;
        var color = stableData.color;

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
                        let trainCost = 1; // TODO
                        if (energy < trainCost) {
                            return #err("Not enough energy to train player");
                        };
                        energy -= trainCost;
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
                case (#modifyLink(modifyLink)) {
                    let index = IterTools.findIndex(links.vals(), func(link : Types.Link) : Bool { link.name == modifyLink.name });
                    switch (index) {
                        case (?i) {
                            switch (modifyLink.url) {
                                case (?url) {
                                    links.put(
                                        i,
                                        {
                                            name = modifyLink.name;
                                            url = url;
                                        },
                                    );
                                };
                                // Remove link if URL is null
                                case (null) ignore links.remove(i);
                            };
                        };
                        case (null) {
                            let ?url = modifyLink.url else return #err("Link URL is required for adding a new link");
                            links.add({
                                name = modifyLink.name;
                                url = url;
                            });
                        };
                    };
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
                id = teamId;
                dao = dao.toStableData();
                links = Buffer.toArray(links);
                energy = energy;
                entropy = entropy;
                name = name;
                logoUrl = logoUrl;
                motto = motto;
                description = description;
                color = color;
            };
        };
        public func get() : Team.Team {
            {
                id = teamId;
                name = name;
                logoUrl = logoUrl;
                motto = motto;
                description = description;
                color = color;
                entropy = entropy;
                energy = energy;
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

        public func getLinks() : [Types.Link] {
            Buffer.toArray(links);
        };

        public func updateEnergy(delta : Int, allowBelowZero : Bool) : {
            #ok;
            #notEnoughEnergy;
        } {
            let newEnergy = energy + delta;
            if (not allowBelowZero and newEnergy < 0) {
                return #notEnoughEnergy;
            };
            energy := newEnergy;
            #ok;
        };

        public func updateName(newName : Text) : () {
            name := newName;
        };

        public func updateColor(newColor : (Nat8, Nat8, Nat8)) : () {
            color := newColor;
        };

        public func updateLogo(newLogoUrl : Text) : () {
            logoUrl := newLogoUrl;
        };

        public func updateMotto(newMotto : Text) : () {
            motto := newMotto;
        };

        public func updateDescription(newDescription : Text) : () {
            description := newDescription;
        };

        public func updateEntropy(delta : Int) : () {
            let newEntropyInt : Int = entropy + delta;
            let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                // Entropy cant be negative
                0;
            } else {
                Int.abs(newEntropyInt);
            };
            entropy := newEntropyNat;
        };
    };
};
