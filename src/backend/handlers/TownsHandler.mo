import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Option "mo:base/Option";
import IterTools "mo:itertools/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TextX "mo:xtended-text/TextX";
import ImageFile "../models/ImageFile";

module {

    public type StableData = {
        towns : [StableTownData];
    };

    public type StableTownData = {
        id : Nat;
        currency : Nat;
        name : Text;
        image : ImageFile.ImageFile;
        motto : Text;
        entropy : Nat;
        links : [Town.Link];
    };

    type MutableTownData = {
        id : Nat;
        var currency : Nat;
        var name : Text;
        var logoUrl : Text;
        var motto : Text;
        var description : Text;
        var entropy : Nat;
        var color : (Nat8, Nat8, Nat8);
        traitIds : Buffer.Buffer<Text>;
        links : Buffer.Buffer<Town.Link>;
    };

    public class Handler<system>(
        data : StableData
    ) {

        var towns : HashMap.HashMap<Nat, MutableTownData> = toTownHashMap(data.towns);
        var traits : HashMap.HashMap<Text, Trait.Trait> = toTraitsHashMap(data.traits);

        var nextTownId = towns.size(); // TODO change to check for the largest town id in the list

        public func toStableData() : StableData {
            {
                towns = towns.vals()
                |> Iter.map<MutableTownData, StableTownData>(
                    _,
                    toStableTownData,
                )
                |> Iter.toArray(_);
                traits = traits.vals() |> Iter.toArray(_);
            };
        };

        public func getCurrentEntropy() : Nat {
            Option.get(
                towns.vals()
                |> Iter.map<MutableTownData, Nat>(
                    _,
                    func(town : MutableTownData) : Nat = town.entropy,
                )
                |> IterTools.sum(_, func(x : Nat, y : Nat) : Nat = x + y),
                0,
            );
        };

        public func get(townId : Nat) : ?Town.Town {
            let ?town = towns.get(townId) else return null;
            let townTraits = getTraitsByIds(town.traitIds.vals());
            ?{
                id = town.id;
                name = town.name;
                logoUrl = town.logoUrl;
                motto = town.motto;
                description = town.description;
                color = town.color;
                entropy = town.entropy;
                currency = town.currency;
                traits = townTraits;
                links = Buffer.toArray(town.links);
            };
        };

        public func getAll() : [Town.Town] {
            towns.vals()
            |> Iter.map<MutableTownData, Town.Town>(
                _,
                toTown,
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
            Debug.print("Creating new town with name " # name);
            let nameAlreadyTaken = towns.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTownData)) : Bool = v.name == name,
            );

            if (nameAlreadyTaken) {
                return #err(#nameTaken);
            };
            let townId = nextTownId;
            nextTownId += 1;

            let townData : MutableTownData = {
                id = townId;
                var name = name;
                var logoUrl = logoUrl;
                var motto = motto;
                var description = description;
                var color = color;
                var entropy = entropy;
                var currency = currency;
                traitIds = Buffer.Buffer<Text>(0);
                links = Buffer.Buffer<Town.Link>(0);
            };
            towns.put(townId, townData);

            return #ok(townId);
        };

        public func getLinks(townId : Nat) : Result.Result<[Town.Link], { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            #ok(Buffer.toArray(town.links));
        };

        public func modifyLink(townId : Nat, name : Text, urlOrRemove : ?Text) : Result.Result<(), { #townNotFound; #urlRequired }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let index = IterTools.findIndex(town.links.vals(), func(link : Town.Link) : Bool { link.name == name });
            switch (index) {
                case (?i) {
                    switch (urlOrRemove) {
                        case (?url) {
                            town.links.put(
                                i,
                                {
                                    name = name;
                                    url = url;
                                },
                            );
                        };
                        // Remove link if URL is null
                        case (null) ignore town.links.remove(i);
                    };
                    #ok;
                };
                case (null) {
                    let ?url = urlOrRemove else return #err(#urlRequired);
                    town.links.add({
                        name = name;
                        url = url;
                    });
                    #ok;
                };
            };
        };

        public func updateCurrency(
            townId : Nat,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughCurrency }> {
            if (delta == 0) {
                return #ok;
            };
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newCurrency = town.currency + delta;
            if (not allowBelowZero and newCurrency < 0) {
                return #err(#notEnoughCurrency);
            };
            let newCurrencyNat = if (newCurrency <= 0) {
                0;
            } else {
                Int.abs(newCurrency);
            };
            Debug.print("Updating currency for town " # Nat.toText(townId) # " by " # Int.toText(delta) # " to " # Nat.toText(newCurrencyNat));
            town.currency := newCurrencyNat;
            #ok;
        };

        public func updateName(townId : Nat, newName : Text) : Result.Result<(), { #townNotFound; #nameTaken }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let nameAlreadyTaken = towns.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, MutableTownData)) : Bool = v.name == newName,
            );
            if (nameAlreadyTaken) {
                return #err(#nameTaken);
            };
            Debug.print("Updating name for town " # Nat.toText(townId) # " to: " # newName);
            town.name := newName;
            #ok;
        };

        public func updateColor(townId : Nat, newColor : (Nat8, Nat8, Nat8)) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating color for town " # Nat.toText(townId) # " to: " # debug_show (newColor));
            town.color := newColor;
            #ok;
        };

        public func updateLogo(townId : Nat, newLogoUrl : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating logo for town " # Nat.toText(townId) # " to: " # newLogoUrl);
            town.logoUrl := newLogoUrl;
            #ok;
        };

        public func updateMotto(townId : Nat, newMotto : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating motto for town " # Nat.toText(townId) # " to: " # newMotto);
            town.motto := newMotto;
            #ok;
        };

        public func updateDescription(townId : Nat, newDescription : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating description for town " # Nat.toText(townId) # " to: " # newDescription);
            town.description := newDescription;
            #ok;
        };

        public func updateEntropy(townId : Nat, delta : Int) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating entropy for town " # Nat.toText(townId) # " by " # Int.toText(delta));
            let newEntropyInt : Int = town.entropy + delta;
            let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                // Entropy cant be negative
                0;
            } else {
                Int.abs(newEntropyInt);
            };
            town.entropy := newEntropyNat;

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

        public func addTraitToTown(townId : Nat, traitId : Text) : Result.Result<{ hadTrait : Bool }, { #townNotFound; #traitNotFound }> {
            Debug.print("Adding trait " # traitId # " to town " # Nat.toText(townId));
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let ?_ = traits.get(traitId) else return #err(#traitNotFound);
            let hadTrait = if (not IterTools.any(town.traitIds.vals(), func(id : Text) : Bool = id == traitId)) {
                town.traitIds.add(traitId);
                false;
            } else {
                true;
            };
            #ok({ hadTrait = hadTrait });
        };

        public func removeTraitFromTown(townId : Nat, traitId : Text) : Result.Result<{ hadTrait : Bool }, { #townNotFound }> {
            Debug.print("Removing trait " # traitId # " from town " # Nat.toText(townId));
            let ?town = towns.get(townId) else return #err(#townNotFound);

            let index = IterTools.findIndex(town.traitIds.vals(), func(id : Text) : Bool = id == traitId);
            let hadTrait = switch (index) {
                case (?i) {
                    ignore town.traitIds.remove(i);
                    true;
                };
                case (null) false;
            };
            #ok({ hadTrait = hadTrait });
        };

        public func clear() {
            towns := HashMap.HashMap<Nat, MutableTownData>(0, Nat.equal, Nat32.fromNat);
            traits := HashMap.HashMap<Text, Trait.Trait>(0, Text.equal, Text.hash);
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

        private func toTown(town : MutableTownData) : Town.Town {
            {
                id = town.id;
                traits = getTraitsByIds(town.traitIds.vals());
                links = Buffer.toArray(town.links);
                currency = town.currency;
                entropy = town.entropy;
                name = town.name;
                logoUrl = town.logoUrl;
                motto = town.motto;
                description = town.description;
                color = town.color;
            };
        };
    };

    public func toTownHashMap(towns : [StableTownData]) : HashMap.HashMap<Nat, MutableTownData> {
        towns.vals()
        |> Iter.map<StableTownData, (Nat, MutableTownData)>(
            _,
            func(town : StableTownData) : (Nat, MutableTownData) = (town.id, toMutableTownData(town)),
        )
        |> HashMap.fromIter<Nat, MutableTownData>(_, towns.size(), Nat.equal, Nat32.fromNat);
    };

    private func toMutableTownData(stableData : StableTownData) : MutableTownData {
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

    private func toStableTownData(town : MutableTownData) : StableTownData {
        {
            id = town.id;
            traitIds = Buffer.toArray(town.traitIds);
            links = Buffer.toArray(town.links);
            currency = town.currency;
            entropy = town.entropy;
            name = town.name;
            logoUrl = town.logoUrl;
            motto = town.motto;
            description = town.description;
            color = town.color;
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
