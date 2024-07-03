import Dao "../Dao";
import Types "../actors/Types";
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
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";
import Team "../models/Team";
import Result "mo:base/Result";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Array "mo:base/Array";
import Text "mo:base/Text";
import TextX "mo:xtended-text/TextX";
import Season "../models/Season";
import Trait "../models/Trait";
import Skill "../models/Skill";

module {

    public type StableData = {
        entropyThreshold : Nat;
        teams : [StableTeamData];
        traits : [Trait.Trait];
    };

    public type StableTeamData = {
        id : Nat;
        energy : Int;
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        entropy : Nat;
        color : (Nat8, Nat8, Nat8);
        dao : Dao.StableData<Types.ProposalContent>;
        traitIds : [Text];
        links : [Types.Link];
    };

    type MutableTeamData = {
        id : Nat;
        var energy : Int;
        var name : Text;
        var logoUrl : Text;
        var motto : Text;
        var description : Text;
        var entropy : Nat;
        var color : (Nat8, Nat8, Nat8);
        traitIds : Buffer.Buffer<Text>;
        links : Buffer.Buffer<Types.Link>;
    };

    public class Handler<system>(data : StableData, leagueCanisterId : Principal, playersCanisterId : Principal) {

        let leagueActor = actor (Principal.toText(leagueCanisterId)) : LeagueTypes.LeagueActor;
        let playersActor = actor (Principal.toText(playersCanisterId)) : PlayerTypes.PlayerActor;

        let teams : HashMap.HashMap<Nat, MutableTeamData> = toTeamHashMap(data.teams);
        let daos : HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>> = toDaoHashMap<system>(data.teams, teams, leagueActor, playersActor);
        let traits : HashMap.HashMap<Text, Trait.Trait> = toTraitsHashMap(data.traits);
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
                traits = traits.vals() |> Iter.toArray(_);
            };
        };

        public func getEntropyThreshold() : Nat {
            entropyThreshold;
        };

        public func get(teamId : Nat) : ?Team.Team {
            let ?team = teams.get(teamId) else return null;
            let teamTraits = getTraitsByIds(team.traitIds.vals());
            ?{
                id = team.id;
                name = team.name;
                logoUrl = team.logoUrl;
                motto = team.motto;
                description = team.description;
                color = team.color;
                entropy = team.entropy;
                energy = team.energy;
                traits = teamTraits;
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
            request : Types.CreateTeamRequest
        ) : Types.CreateTeamResult {
            Debug.print("Creating new team with name " # request.name);
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTeamData)) : Bool = v.name == request.name,
            );

            if (nameAlreadyTaken) {
                return #err(#nameTaken);
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
                traitIds = Buffer.Buffer<Text>(0);
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
            let dao = buildDao<system>(daoData, teamData, leagueActor, playersActor);
            daos.put(teamId, dao);

            // TODO add retry populating team roster

            try {
                let populateResult = playerHandler.populateTeamRoster(teamId);

                switch (populateResult) {
                    case (#ok(_)) {};
                    case (#err(#notAuthorized)) {
                        Debug.print("Error populating team roster: League is not authorized to populate team roster for team: " # Nat.toText(teamId));
                    };
                    case (#err(#missingFluff)) {
                        Debug.print("Error populating team roster: No unused player fluff available");
                    };
                };
            } catch (err) {
                Debug.print("Error populating team roster: " # Error.message(err));
            };
            return #ok(teamId);
        };

        public func getProposal(teamId : Nat, id : Nat) : Result.Result<Dao.Proposal<Types.ProposalContent>, { #teamNotFound; #proposalNotFound }> {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            let ?proposal = dao.getProposal(id) else return #err(#proposalNotFound);
            #ok(proposal);
        };

        public func getProposals(teamId : Nat, count : Nat, offset : Nat) : Result.Result<CommonTypes.PagedResult<Dao.Proposal<Types.ProposalContent>>, { #teamNotFound }> {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            let proposals = dao.getProposals(count, offset);
            #ok(proposals);
        };

        public func voteOnProposal(teamId : Nat, caller : Principal, request : Types.VoteOnProposalRequest) : Types.VoteOnProposalResult {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            dao.vote(request.proposalId, caller, request.vote);
        };

        public func createProposal<system>(
            teamId : Nat,
            caller : Principal,
            request : Types.CreateProposalRequest,
            members : [Dao.Member],
        ) : Types.CreateProposalResult {
            let ?dao = daos.get(teamId) else return #err(#teamNotFound);
            Debug.print("Creating proposal for team " # Nat.toText(teamId) # " with content: " # debug_show (request.content));
            dao.createProposal<system>(caller, request.content, members);
        };

        public func getLinks(teamId : Nat) : Result.Result<[Types.Link], { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            #ok(Buffer.toArray(team.links));
        };

        public func updateEnergy(
            teamId : Nat,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #teamNotFound; #notEnoughEnergy }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            let newEnergy = team.energy + delta;
            if (not allowBelowZero and newEnergy < 0) {
                return #err(#notEnoughEnergy);
            };
            Debug.print("Updating energy for team " # Nat.toText(teamId) # " by " # Int.toText(delta));
            team.energy := newEnergy;
            #ok;
        };

        public func updateName(teamId : Nat, newName : Text) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating name for team " # Nat.toText(teamId) # " to: " # newName);
            team.name := newName;
            #ok;
        };

        public func updateColor(teamId : Nat, newColor : (Nat8, Nat8, Nat8)) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating color for team " # Nat.toText(teamId) # " to: " # debug_show (newColor));
            team.color := newColor;
            #ok;
        };

        public func updateLogo(teamId : Nat, newLogoUrl : Text) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating logo for team " # Nat.toText(teamId) # " to: " # newLogoUrl);
            team.logoUrl := newLogoUrl;
            #ok;
        };

        public func updateMotto(teamId : Nat, newMotto : Text) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating motto for team " # Nat.toText(teamId) # " to: " # newMotto);
            team.motto := newMotto;
            #ok;
        };

        public func updateDescription(teamId : Nat, newDescription : Text) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating description for team " # Nat.toText(teamId) # " to: " # newDescription);
            team.description := newDescription;
            #ok;
        };

        public func updateEntropy(teamId : Nat, delta : Int) : Result.Result<(), { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            Debug.print("Updating entropy for team " # Nat.toText(teamId) # " by " # Int.toText(delta));
            let newEntropyInt : Int = team.entropy + delta;
            let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                // Entropy cant be negative
                0;
            } else {
                Int.abs(newEntropyInt);
            };
            team.entropy := newEntropyNat;
            checkEntropy();
            #ok;
        };

        public func createTrait(trait : Trait.Trait) : Result.Result<(), { #idTaken; #invalid : [Text] }> {
            if (Option.isSome(traits.get(trait.id))) {
                return #err(#idTaken);
            };
            let validationErrors = Buffer.Buffer<Text>(0);
            if (TextX.isEmpty(trait.id)) {
                validationErrors.add("Id is required");
            };
            if (validationErrors.size() > 0) {
                return #err(#invalid(Buffer.toArray(validationErrors)));
            };
            Debug.print("Creating trait: " # debug_show (trait));
            traits.put(trait.id, trait);
            #ok;
        };

        public func getTraits() : [Trait.Trait] {
            traits.vals() |> Iter.toArray(_);
        };

        public func addTraitToTeam(teamId : Nat, traitId : Text) : Result.Result<{ hadTrait : Bool }, { #teamNotFound; #traitNotFound }> {
            Debug.print("Adding trait " # traitId # " to team " # Nat.toText(teamId));
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            let ?_ = traits.get(traitId) else return #err(#traitNotFound);
            let hadTrait = if (not IterTools.any(team.traitIds.vals(), func(id : Text) : Bool = id == traitId)) {
                team.traitIds.add(traitId);
                false;
            } else {
                true;
            };
            #ok({ hadTrait = hadTrait });
        };

        public func removeTraitFromTeam(teamId : Nat, traitId : Text) : Result.Result<{ hadTrait : Bool }, { #teamNotFound }> {
            Debug.print("Removing trait " # traitId # " from team " # Nat.toText(teamId));
            let ?team = teams.get(teamId) else return #err(#teamNotFound);

            let index = IterTools.findIndex(team.traitIds.vals(), func(id : Text) : Bool = id == traitId);
            let hadTrait = switch (index) {
                case (?i) {
                    ignore team.traitIds.remove(i);
                    true;
                };
                case (null) false;
            };
            #ok({ hadTrait = hadTrait });
        };

        public func onMatchGroupComplete(matchGroup : Season.CompletedMatchGroup) {
            // Give team X energy that is divided purpotionally to how much relative entropy
            // (based on combined entropy of all teams) they have and +1 for each winning team
            Debug.print("On match group complete event triggered for match group: " # debug_show (matchGroup));
            type TeamInfo = {
                id : Nat;
                score : Int;
                isWinner : Bool;
                mutableData : MutableTeamData;
            };

            let playingTeams = matchGroup.matches.vals()
            |> IterTools.fold(
                _,
                Buffer.Buffer<TeamInfo>(matchGroup.matches.size() * 2),
                func(acc : Buffer.Buffer<TeamInfo>, match : Season.CompletedMatch) : Buffer.Buffer<TeamInfo> {
                    let ?team1 = teams.get(match.team1.id) else Debug.trap("Team not found: " # Nat.toText(match.team1.id));
                    let ?team2 = teams.get(match.team2.id) else Debug.trap("Team not found: " # Nat.toText(match.team2.id));
                    acc.add({
                        match.team1 with
                        mutableData = team1;
                        isWinner = match.winner == #team1;
                    });
                    acc.add({
                        match.team2 with
                        mutableData = team2;
                        isWinner = match.winner == #team2;
                    });
                    return acc;
                },
            )
            |> Buffer.toArray(_);
            let energyToBeGiven = playingTeams.size() * 100; // TODO value?
            let proportionalWeights = playingTeams.vals()
            |> Iter.map<TeamInfo, Nat>(
                _,
                func(team : TeamInfo) : Nat = team.mutableData.entropy,
            )
            |> Iter.toArray(_)
            |> getProportionalEntropyWeights(_);

            for ((team, energyWeight) in IterTools.zip(playingTeams.vals(), proportionalWeights.vals())) {
                var newEnergy = energyToBeGiven * Float.toInt(Float.floor(energyWeight));
                if (team.isWinner) {
                    // Winning team gets +1 energy
                    newEnergy += 1;
                };
                team.mutableData.energy += newEnergy;
                Debug.print("Team " # Nat.toText(team.id) # " share of the energy is: " # Int.toText(team.mutableData.energy));
            };
        };
        private func getProportionalEntropyWeights(entropyValues : [Nat]) : [Float] {
            if (entropyValues.size() == 0) {
                return [];
            };
            let ?maxEntropy = IterTools.max<Nat>(entropyValues.vals(), Nat.compare) else Prelude.unreachable();
            let ?minEntropy = IterTools.min<Nat>(entropyValues.vals(), Nat.compare) else Prelude.unreachable();
            let entropyRange : Nat = maxEntropy - minEntropy;

            // If all entropy values are 0 or the total entropy is 0, return an array of equal weights
            if (maxEntropy == 0) {
                let equalWeight = 1.0 / Float.fromInt(entropyValues.size());
                return Array.tabulate<Float>(entropyValues.size(), func(_ : Nat) : Float { equalWeight });
            };

            // Calculate inverse entropy weights
            let inverseWeights = Iter.map<Nat, Float>(
                entropyValues.vals(),
                func(entropy : Nat) : Float {
                    let relativeEntropy = Float.fromInt(maxEntropy - entropy) / Float.fromInt(entropyRange);
                    return 1.0 - relativeEntropy;
                },
            )
            |> Iter.toArray(_);

            // Normalize weights
            let totalWeight = IterTools.fold<Float, Float>(
                inverseWeights.vals(),
                0.0,
                func(sum : Float, weight : Float) : Float {
                    return sum + weight;
                },
            );
            return Iter.map<Float, Float>(
                inverseWeights.vals(),
                func(weight : Float) : Float {
                    return weight / totalWeight;
                },
            )
            |> Iter.toArray(_);
        };

        private func checkEntropy() : () {
            let totalEntropy = teams.vals()
            |> Iter.map<MutableTeamData, Nat>(
                _,
                func(team : MutableTeamData) : Nat = team.entropy,
            )
            |> IterTools.sum(_, func(x : Nat, y : Nat) : Nat = x + y);
            Debug.print("Total entropy: " # Nat.toText(Option.get(totalEntropy, 0)));
            if (Option.get(totalEntropy, 0) >= entropyThreshold) {
                Debug.print("Entropy threshold reached, triggering league collapse");
                seasonHandler.onLeagueCollapse();
                scenarioHandler.onLeagueCollapse();
            };
        };

        private func getTraitsByIds(traitIds : Iter.Iter<Text>) : [Trait.Trait] {
            traitIds
            |> Iter.map(
                _,
                func(traitId : Text) : Trait.Trait {
                    let ?trait = traits.get(traitId) else Debug.trap("Missing trait with ID: " # traitId);
                    trait;
                },
            )
            |> Iter.toArray(_);
        };

        private func toTeam(team : MutableTeamData) : Team.Team {
            {
                id = team.id;
                traits = getTraitsByIds(team.traitIds.vals());
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
            var energy = stableData.energy;
            var name = stableData.name;
            var logoUrl = stableData.logoUrl;
            var motto = stableData.motto;
            var description = stableData.description;
            var entropy = stableData.entropy;
            var color = stableData.color;
            traitIds = Buffer.fromArray(stableData.traitIds);
            links = Buffer.fromArray(stableData.links);
        };
    };

    private func toStableTeamData(team : MutableTeamData, dao : Dao.StableData<Types.ProposalContent>) : StableTeamData {
        {
            id = team.id;
            dao = dao;
            traitIds = Buffer.toArray(team.traitIds);
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

    private func toDaoHashMap<system>(
        teams : [StableTeamData],
        mutableTeams : HashMap.HashMap<Nat, MutableTeamData>,
        leagueActor : LeagueTypes.LeagueActor,
        playersActor : PlayerTypes.PlayerActor,
    ) : HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>> {
        let daoMap = HashMap.HashMap<Nat, Dao.Dao<Types.ProposalContent>>(0, Nat.equal, Nat32.fromNat);
        for (team in teams.vals()) {
            let ?mutableTeam = mutableTeams.get(team.id) else Debug.trap("Missing mutable team data for team ID: " # Nat.toText(team.id));
            let dao = buildDao<system>(team.dao, mutableTeam, leagueActor, playersActor);
            daoMap.put(team.id, dao);
        };
        daoMap;
    };

    private func toTraitsHashMap(traits : [Trait.Trait]) : HashMap.HashMap<Text, Trait.Trait> {
        traits.vals()
        |> Iter.map<Trait.Trait, (Text, Trait.Trait)>(
            _,
            func(trait : Trait.Trait) : (Text, Trait.Trait) = (trait.id, trait),
        )
        |> HashMap.fromIter<Text, Trait.Trait>(_, traits.size(), Text.equal, Text.hash);
    };

    private func buildDao<system>(
        data : Dao.StableData<Types.ProposalContent>,
        team : MutableTeamData,
    ) : Dao.Dao<Types.ProposalContent> {

        func onExecute(proposal : Dao.Proposal<Types.ProposalContent>) : Result.Result<(), Text> {
            let createLeagueProposal = func(content : LeagueTypes.ProposalContent) : Result.Result<(), Text> {
                try {
                    let result = leagueHandler.createProposal({
                        content = content;
                    });
                    switch (result) {
                        case (#ok(_)) #ok;
                        case (#err(#notAuthorized)) #err("Not authorized to create change name proposal in league DAO");
                        case (#err(#invalid(errors))) {
                            let errorText = errors.vals()
                            |> IterTools.fold(
                                _,
                                "",
                                func(acc : Text, error : Text) : Text = acc # error # "\n",
                            );
                            #err("Invalid proposal:\n" # errorText);
                        };
                    };
                } catch (err) {
                    #err("Error creating proposal in league DAO: " # Error.message(err));
                };
            };
            switch (proposal.content) {
                case (#train(train)) {
                    try {
                        // TODO atomic operation
                        let player = switch (playersHandler.getPosition(team.id, train.position)) {
                            case (#ok(player)) player;
                            case (#err(e)) return #err("Error getting player in players actor: " # debug_show (e));
                        };
                        let trainCost = Skill.get(player.skills, train.skill);
                        if (team.energy < trainCost) {
                            return #err("Not enough energy to train player");
                        };
                        team.energy -= trainCost;
                        // TODO make the 'applyEffects' generic, not scenario specific
                        let trainSkillEffect : Scenario.PlayerEffectOutcome = #skill({
                            target = {
                                teamId = team.id;
                                position = train.position;
                            };
                            delta = 1;
                            duration = #indefinite;
                            skill = train.skill;
                        });
                        switch (playersHandler.applyEffects([trainSkillEffect])) {
                            case (#ok) #ok;
                            case (#err(#notAuthorized)) #err("Not authorized to train player in players actor");
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
                    createLeagueProposal(leagueProposal);
                };
                case (#swapPlayerPositions(swap)) {
                    try {
                        switch (playersHandler.swapTeamPositions(team.id, swap.position1, swap.position2)) {
                            case (#ok) #ok;
                            case (#err(#notAuthorized)) #err("Not authorized to swap player positions in players actor");
                        };
                    } catch (err) {
                        #err("Error swapping player positions in players actor: " # Error.message(err));
                    };
                };
                case (#changeColor(changeColor)) {
                    createLeagueProposal(#changeTeamColor({ teamId = team.id; color = changeColor.color }));
                };
                case (#changeLogo(changeLogo)) {
                    createLeagueProposal(#changeTeamLogo({ teamId = team.id; logoUrl = changeLogo.logoUrl }));
                };
                case (#changeMotto(changeMotto)) {
                    createLeagueProposal(#changeTeamMotto({ teamId = team.id; motto = changeMotto.motto }));
                };
                case (#changeDescription(changeDescription)) {
                    createLeagueProposal(#changeTeamDescription({ teamId = team.id; description = changeDescription.description }));
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

        func onReject(proposal : Dao.Proposal<Types.ProposalContent>) : () {
            Debug.print("Rejected proposal: " # debug_show (proposal));
        };
        func onValidate(_ : Types.ProposalContent) : Result.Result<(), [Text]> {
            #ok; // TODO
        };
        let dao = Dao.Dao<system, Types.ProposalContent>(data, onExecute, onReject, onValidate);
        dao;
    };
};
