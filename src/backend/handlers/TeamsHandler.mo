import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Option "mo:base/Option";
import IterTools "mo:itertools/Iter";
import Team "../models/Team";
import Result "mo:base/Result";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Array "mo:base/Array";
import Text "mo:base/Text";
import TextX "mo:xtended-text/TextX";
import Trait "../models/Trait";

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
        traitIds : [Text];
        links : [Team.Link];
    };
    public type EntropyData = {
        maxDividend : Nat;
        currentDividend : Nat;
        entropyThreshold : Nat;
        currentEntropy : Nat;
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
        links : Buffer.Buffer<Team.Link>;
    };

    public class Handler<system>(
        data : StableData
    ) {

        let teams : HashMap.HashMap<Nat, MutableTeamData> = toTeamHashMap(data.teams);
        let traits : HashMap.HashMap<Text, Trait.Trait> = toTraitsHashMap(data.traits);
        var entropyThreshold = data.entropyThreshold;

        var nextTeamId = teams.size(); // TODO change to check for the largest team id in the list

        public func toStableData() : StableData {
            {
                teams = teams.vals()
                |> Iter.map<MutableTeamData, StableTeamData>(
                    _,
                    toStableTeamData,
                )
                |> Iter.toArray(_);
                entropyThreshold = entropyThreshold;
                traits = traits.vals() |> Iter.toArray(_);
            };
        };

        public func getEntropyData() : EntropyData {
            let currentEntropy = Option.get(
                teams.vals()
                |> Iter.map<MutableTeamData, Nat>(
                    _,
                    func(team : MutableTeamData) : Nat = team.entropy,
                )
                |> IterTools.sum(_, func(x : Nat, y : Nat) : Nat = x + y),
                0,
            );

            let entropyLevel = Float.fromInt(currentEntropy) / Float.fromInt(entropyThreshold);
            let maxDividend = 30;

            let currentDividend = if (entropyLevel <= 0.25) {
                maxDividend;
            } else if (entropyLevel <= 0.5) {
                Int.abs(Float.toInt(Float.fromInt(maxDividend) * 0.8));
            } else if (entropyLevel <= 0.75) {
                Int.abs(Float.toInt(Float.fromInt(maxDividend) * 0.5));
            } else {
                Int.abs(Float.toInt(Float.fromInt(maxDividend) * 0.3));
            };
            {
                maxDividend = maxDividend;
                currentDividend = currentDividend;
                entropyThreshold = entropyThreshold;
                currentEntropy = currentEntropy;
            };
        };

        public func isOverEntropyThreshold() : Bool {
            let data = getEntropyData();
            data.currentEntropy >= data.entropyThreshold;
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
            name : Text,
            logoUrl : Text,
            motto : Text,
            description : Text,
            color : (Nat8, Nat8, Nat8),
        ) : Result.Result<Nat, { #nameTaken }> {
            Debug.print("Creating new team with name " # name);
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTeamData)) : Bool = v.name == name,
            );

            if (nameAlreadyTaken) {
                return #err(#nameTaken);
            };
            let teamId = nextTeamId;
            nextTeamId += 1;

            let teamData : MutableTeamData = {
                id = teamId;
                var name = name;
                var logoUrl = logoUrl;
                var motto = motto;
                var description = description;
                var color = color;
                var entropy = 0; // TODO?
                var energy = 0;
                traitIds = Buffer.Buffer<Text>(0);
                links = Buffer.Buffer<Team.Link>(0);
            };
            teams.put(teamId, teamData);

            return #ok(teamId);
        };

        public func getLinks(teamId : Nat) : Result.Result<[Team.Link], { #teamNotFound }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            #ok(Buffer.toArray(team.links));
        };

        public func modifyLink(teamId : Nat, name : Text, urlOrRemove : ?Text) : Result.Result<(), { #teamNotFound; #urlRequired }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            let index = IterTools.findIndex(team.links.vals(), func(link : Team.Link) : Bool { link.name == name });
            switch (index) {
                case (?i) {
                    switch (urlOrRemove) {
                        case (?url) {
                            team.links.put(
                                i,
                                {
                                    name = name;
                                    url = url;
                                },
                            );
                        };
                        // Remove link if URL is null
                        case (null) ignore team.links.remove(i);
                    };
                    #ok;
                };
                case (null) {
                    let ?url = urlOrRemove else return #err(#urlRequired);
                    team.links.add({
                        name = name;
                        url = url;
                    });
                    #ok;
                };
            };
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

        public func updateName(teamId : Nat, newName : Text) : Result.Result<(), { #teamNotFound; #nameTaken }> {
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTeamData)) : Bool = v.name == newName,
            );
            if (nameAlreadyTaken) {
                return #err(#nameTaken);
            };
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

        public func updateEntropy(teamId : Nat, delta : Int) : Result.Result<{ overThreshold : Bool }, { #teamNotFound }> {
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

            #ok({ overThreshold = isOverEntropyThreshold() });
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

        public func disperseEnergyDividends() {
            // Give team X energy that is divided purpotionally to how much relative entropy
            // (based on combined entropy of all teams) they have and +1 for each winning team
            type TeamInfo = {
                id : Nat;
                mutableData : MutableTeamData;
            };

            let proportionalWeights = teams.vals()
            |> Iter.map<MutableTeamData, Nat>(
                _,
                func(team : MutableTeamData) : Nat = team.entropy,
            )
            |> Iter.toArray(_)
            |> getProportionalEntropyWeights(_);

            let entropyData = getEntropyData();

            Debug.print("Giving energy to teams based on entropy. Total energy: " # Nat.toText(entropyData.currentDividend));

            for ((team, energyWeight) in IterTools.zip(teams.vals(), proportionalWeights.vals())) {
                var newEnergy = Float.toInt(Float.floor(Float.fromInt(entropyData.currentDividend) * energyWeight));
                team.energy += newEnergy;
                Debug.print("Team " # Nat.toText(team.id) # " share of the energy is: " # Int.toText(newEnergy) # " (weight: " # Float.toText(energyWeight) # ")");
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

            let weights = Iter.map<Nat, Float>(
                entropyValues.vals(),
                func(entropy : Nat) : Float {
                    let relativeEntropy = Float.fromInt(maxEntropy - entropy) / Float.fromInt(entropyRange);
                    return relativeEntropy + 1.0;
                },
            )
            |> Iter.toArray(_);

            let totalWeight = IterTools.fold<Float, Float>(
                weights.vals(),
                0.0,
                func(sum : Float, weight : Float) : Float {
                    return sum + weight;
                },
            );
            return Iter.map<Float, Float>(
                weights.vals(),
                func(weight : Float) : Float {
                    return weight / totalWeight;
                },
            )
            |> Iter.toArray(_);
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

    private func toStableTeamData(team : MutableTeamData) : StableTeamData {
        {
            id = team.id;
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

    private func toTraitsHashMap(traits : [Trait.Trait]) : HashMap.HashMap<Text, Trait.Trait> {
        traits.vals()
        |> Iter.map<Trait.Trait, (Text, Trait.Trait)>(
            _,
            func(trait : Trait.Trait) : (Text, Trait.Trait) = (trait.id, trait),
        )
        |> HashMap.fromIter<Text, Trait.Trait>(_, traits.size(), Text.equal, Text.hash);
    };

};
