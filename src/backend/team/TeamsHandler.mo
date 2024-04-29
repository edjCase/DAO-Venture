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
import Option "mo:base/Option";
import CommonTypes "../Types";
import PlayersActor "canister:players";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";
import Team "../models/Team";
import Result "mo:base/Result";

module {

    public type StableData = {
        entropyThreshold : Nat;
        teams : [StableTeamData];
    };

    public type StableTeamData = {
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

    type MutableTeamData = {
        id : Nat;
        var leagueId : Principal;
        var energy : Int;
        var name : Text;
        var logoUrl : Text;
        var motto : Text;
        var description : Text;
        var entropy : Nat;
        var color : (Nat8, Nat8, Nat8);
        links : Buffer.Buffer<Types.Link>;
    };

    public class Handler<system>(data : StableData) {
        let teams : HashMap.HashMap<Nat, MutableTeamData> = toTeamHashMap(data.teams);
        let daos : HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>> = toDaoHashMap<system>(data.teams, teams);
        var entropyThreshold = data.entropyThreshold;

        var nextTeamId = teams.size(); // TODO change to check for the largest team id in the list

        public func toStableData() : StableData {
            {
                teams = teams.vals()
                |> Iter.map<MutableTeamData, StableTeamData>(
                    _,
                    func(team : MutableTeamData) : StableTeamData {
                        let ?dao = daos.get(team.id) else Debug.trap("Missing DAO for team ID: " # Nat.toText(team.id));
                        let daoData = dao.toStableData();
                        toStableTeamData(team, daoData);
                    },
                )
                |> Iter.toArray(_);
                entropyThreshold = entropyThreshold;
            };
        };

        public func get(teamId : Nat) : ?Team.Team {
            let ?team = teams.get(teamId) else return null;
            ?{
                id = team.id;
                name = team.name;
                logoUrl = team.logoUrl;
                motto = team.motto;
                description = team.description;
                color = team.color;
                entropy = team.entropy;
                energy = team.energy;
                links = Buffer.toArray(team.links);
            };
        };

        public func getAll() : [Team.Team] {
            teams.vals()
            |> Iter.map<MutableTeamData, Team.Team>(
                _,
                toTeam,
            )
            |> Iter.toArray(_);
        };

        public func create<system>(
            leagueId : Principal, // TODO this should be part of the data, but we don't have a way to pass it in yet
            request : Types.CreateTeamRequest,
        ) : async* Types.CreateTeamResult {
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTeamData)) : Bool = v.name == request.name,
            );

            if (nameAlreadyTaken) {
                return #nameTaken;
            };
            let teamId = nextTeamId;
            nextTeamId += 1;

            let teamData : MutableTeamData = {
                id = teamId;
                var name = request.name;
                var logoUrl = request.logoUrl;
                var motto = request.motto;
                var description = request.description;
                var color = request.color;
                var entropy = 0; // TODO?
                var energy = 0;
                var leagueId = leagueId;
                links = Buffer.Buffer<Types.Link>(0);
            };
            teams.put(teamId, teamData);

            let daoData : Dao.StableData<Types.ProposalContent> = {
                proposals = [];
                proposalDuration = #days(3);
                votingThreshold = #percent({
                    percent = 50;
                    quorum = ?20;
                });
            };
            let dao = buildDao<system>(daoData, teamData);
            daos.put(teamId, dao);

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

        public func getProposal(teamId : Nat, id : Nat) : {
            #ok : Dao.Proposal<Types.ProposalContent>;
            #teamNotFound;
            #proposalNotFound;
        } {
            let ?dao = daos.get(teamId) else return #teamNotFound;
            let ?proposal = dao.getProposal(id) else return #proposalNotFound;
            #ok(proposal);
        };

        public func getProposals(teamId : Nat, count : Nat, offset : Nat) : {
            #ok : CommonTypes.PagedResult<Dao.Proposal<Types.ProposalContent>>;
            #teamNotFound;
        } {
            let ?dao = daos.get(teamId) else return #teamNotFound;
            let proposals = dao.getProposals(count, offset);
            #ok(proposals);
        };

        public func voteOnProposal(teamId : Nat, caller : Principal, request : Types.VoteOnProposalRequest) : async* Types.VoteOnProposalResult {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            await* dao.vote(request.proposalId, caller, request.vote);
        };

        public func createProposal<system>(teamId : Nat, caller : Principal, request : Types.CreateProposalRequest, members : [Dao.Member]) : Types.CreateProposalResult {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            dao.createProposal<system>(caller, request.content, members);
        };

        public func getLinks(teamId : Nat) : {
            #ok : [Types.Link];
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            #ok(Buffer.toArray(team.links));
        };

        public func updateEnergy(teamId : Nat, delta : Int, allowBelowZero : Bool) : {
            #ok;
            #teamNotFound;
            #notEnoughEnergy;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            let newEnergy = team.energy + delta;
            if (not allowBelowZero and newEnergy < 0) {
                return #notEnoughEnergy;
            };
            team.energy := newEnergy;
            #ok;
        };

        public func updateName(teamId : Nat, newName : Text) : {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            team.name := newName;
            #ok;
        };

        public func updateColor(teamId : Nat, newColor : (Nat8, Nat8, Nat8)) : {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            team.color := newColor;
            #ok;
        };

        public func updateLogo(teamId : Nat, newLogoUrl : Text) : {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            team.logoUrl := newLogoUrl;
            #ok;
        };

        public func updateMotto(teamId : Nat, newMotto : Text) : {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            team.motto := newMotto;
            #ok;
        };

        public func updateDescription(teamId : Nat, newDescription : Text) : {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            team.description := newDescription;
            #ok;
        };

        public func updateEntropy(teamId : Nat, delta : Int) : async* {
            #ok;
            #teamNotFound;
        } {
            let ?team = teams.get(teamId) else return #teamNotFound;
            let newEntropyInt : Int = team.entropy + delta;
            let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                // Entropy cant be negative
                0;
            } else {
                Int.abs(newEntropyInt);
            };
            team.entropy := newEntropyNat;
            await* checkEntropy();
            #ok;
        };

        private func checkEntropy() : async* () {
            let totalEntropy = teams.vals()
            |> Iter.map<MutableTeamData, Nat>(
                _,
                func(team : MutableTeamData) : Nat = team.entropy,
            )
            |> IterTools.sum(_, func(x : Nat, y : Nat) : Nat = x + y);
            if (Option.get(totalEntropy, 0) >= entropyThreshold) {

                // let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
                // try {
                //     let result = await leagueActor.onEntropy();
                //     switch (result) {
                //         case (#ok(_)) #ok;
                //         case (#notAuthorized) #err("Not authorized to create change name proposal in league DAO");
                //     };
                // } catch (err) {
                //     #err("Error creating change name proposal in league DAO: " # Error.message(err));
                // };
                // TODO implement
                Debug.print("Entropy threshold reached");
            };
        };
    };

    public func toTeamHashMap(teams : [StableTeamData]) : HashMap.HashMap<Nat, MutableTeamData> {
        teams.vals()
        |> Iter.map<StableTeamData, (Nat, MutableTeamData)>(
            _,
            func(team : StableTeamData) : (Nat, MutableTeamData) = (team.id, toMutableTeamData(team)),
        )
        |> HashMap.fromIter<Nat, MutableTeamData>(_, teams.size(), Nat.equal, Nat32.fromNat);
    };

    private func toMutableTeamData(stableData : StableTeamData) : MutableTeamData {
        {
            id = stableData.id;
            var leagueId = stableData.leagueId;
            var energy = stableData.energy;
            var name = stableData.name;
            var logoUrl = stableData.logoUrl;
            var motto = stableData.motto;
            var description = stableData.description;
            var entropy = stableData.entropy;
            var color = stableData.color;
            links = Buffer.fromArray(stableData.links);
        };
    };

    private func toStableTeamData(team : MutableTeamData, dao : Dao.StableData<Types.ProposalContent>) : StableTeamData {
        {
            leagueId = team.leagueId;
            id = team.id;
            dao = dao;
            links = Buffer.toArray(team.links);
            energy = team.energy;
            entropy = team.entropy;
            name = team.name;
            logoUrl = team.logoUrl;
            motto = team.motto;
            description = team.description;
            color = team.color;
        };
    };

    private func toTeam(team : MutableTeamData) : Team.Team {
        {
            leagueId = team.leagueId;
            id = team.id;
            links = Buffer.toArray(team.links);
            energy = team.energy;
            entropy = team.entropy;
            name = team.name;
            logoUrl = team.logoUrl;
            motto = team.motto;
            description = team.description;
            color = team.color;
        };
    };

    private func toDaoHashMap<system>(teams : [StableTeamData], mutableTeams : HashMap.HashMap<Nat, MutableTeamData>) : HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>> {
        let daoMap = HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>>(0, Nat.equal, Nat32.fromNat);
        for (team in teams.vals()) {
            let ?mutableTeam = mutableTeams.get(team.id) else Debug.trap("Missing mutable team data for team ID: " # Nat.toText(team.id));
            let dao = buildDao<system>(team.dao, mutableTeam);
            daoMap.put(team.id, dao);
        };
        daoMap;
    };

    private func buildDao<system>(data : Dao.StableData<Types.ProposalContent>, team : MutableTeamData) : Dao.Dao<Types.ProposalContent> {

        func onExecute(proposal : Dao.Proposal<Types.ProposalContent>) : async* Result.Result<(), Text> {
            let createLeagueProposal = func(content : LeagueTypes.ProposalContent) : async* Result.Result<(), Text> {
                let leagueActor = actor (Principal.toText(team.leagueId)) : LeagueTypes.LeagueActor;
                try {
                    let result = await leagueActor.createProposal({
                        content = content;
                    });
                    switch (result) {
                        case (#ok(_)) #ok;
                        case (#err(#notAuthorized)) #err("Not authorized to create change name proposal in league DAO");
                    };
                } catch (err) {
                    #err("Error creating change name proposal in league DAO: " # Error.message(err));
                };
            };
            switch (proposal.content) {
                case (#train(train)) {
                    try {
                        let trainCost = 1; // TODO
                        if (team.energy < trainCost) {
                            return #err("Not enough energy to train player");
                        };
                        team.energy -= trainCost;
                        // TODO make the 'applyEffects' generic, not scenario specific
                        let trainSkillEffect : Scenario.PlayerEffectOutcome = #skill({
                            target = #positions([{
                                teamId = team.id;
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
                        teamId = team.id;
                        name = n.name;
                    });
                    await* createLeagueProposal(leagueProposal);
                };
                case (#swapPlayerPositions(swap)) {
                    try {
                        switch (await PlayersActor.swapTeamPositions(team.id, swap.position1, swap.position2)) {
                            case (#ok) #ok;
                            case (#notAuthorized) #err("Not authorized to swap player positions in players actor");
                        };
                    } catch (err) {
                        #err("Error swapping player positions in players actor: " # Error.message(err));
                    };
                };
                case (#changeColor(changeColor)) {
                    await* createLeagueProposal(#changeTeamColor({ teamId = team.id; color = changeColor.color }));
                };
                case (#changeLogo(changeLogo)) {
                    await* createLeagueProposal(#changeTeamLogo({ teamId = team.id; logoUrl = changeLogo.logoUrl }));
                };
                case (#changeMotto(changeMotto)) {
                    await* createLeagueProposal(#changeTeamMotto({ teamId = team.id; motto = changeMotto.motto }));
                };
                case (#changeDescription(changeDescription)) {
                    await* createLeagueProposal(#changeTeamDescription({ teamId = team.id; description = changeDescription.description }));
                };
                case (#modifyLink(modifyLink)) {
                    let index = IterTools.findIndex(team.links.vals(), func(link : Types.Link) : Bool { link.name == modifyLink.name });
                    switch (index) {
                        case (?i) {
                            switch (modifyLink.url) {
                                case (?url) {
                                    team.links.put(
                                        i,
                                        {
                                            name = modifyLink.name;
                                            url = url;
                                        },
                                    );
                                };
                                // Remove link if URL is null
                                case (null) ignore team.links.remove(i);
                            };
                        };
                        case (null) {
                            let ?url = modifyLink.url else return #err("Link URL is required for adding a new link");
                            team.links.add({
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
        let dao = Dao.Dao<system, Types.ProposalContent>(data, onExecute, onReject);
        dao;
    };
};
