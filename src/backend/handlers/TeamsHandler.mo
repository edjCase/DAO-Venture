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
import Text "mo:base/Text";
import TextX "mo:xtended-text/TextX";
import Trait "../models/Trait";

module {

    public type StableData = {
        teams : [StableTeamData];
        traits : [Trait.Trait];
    };

    public type StableTeamData = {
        id : Nat;
        currency : Nat;
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        entropy : Nat;
        color : (Nat8, Nat8, Nat8);
        traitIds : [Text];
        links : [Team.Link];
    };

    type MutableTeamData = {
        id : Nat;
        var currency : Nat;
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

        var nextTeamId = teams.size(); // TODO change to check for the largest team id in the list

        public func toStableData() : StableData {
            {
                teams = teams.vals()
                |> Iter.map<MutableTeamData, StableTeamData>(
                    _,
                    toStableTeamData,
                )
                |> Iter.toArray(_);
                traits = traits.vals() |> Iter.toArray(_);
            };
        };

        public func getCurrentEntropy() : Nat {
            Option.get(
                teams.vals()
                |> Iter.map<MutableTeamData, Nat>(
                    _,
                    func(team : MutableTeamData) : Nat = team.entropy,
                )
                |> IterTools.sum(_, func(x : Nat, y : Nat) : Nat = x + y),
                0,
            );
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
                currency = team.currency;
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
            entropy : Nat,
            currency : Nat,
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
                var entropy = entropy;
                var currency = currency;
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

        public func updateCurrency(
            teamId : Nat,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #teamNotFound; #notEnoughCurrency }> {
            if (delta == 0) {
                return #ok;
            };
            let ?team = teams.get(teamId) else return #err(#teamNotFound);
            let newCurrency = team.currency + delta;
            if (not allowBelowZero and newCurrency < 0) {
                return #err(#notEnoughCurrency);
            };
            let newCurrencyNat = if (newCurrency <= 0) {
                0;
            } else {
                Int.abs(newCurrency);
            };
            Debug.print("Updating currency for team " # Nat.toText(teamId) # " by " # Int.toText(delta) # " to " # Nat.toText(newCurrencyNat));
            team.currency := newCurrencyNat;
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
                currency = team.currency;
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
            var currency = stableData.currency;
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
            currency = team.currency;
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
