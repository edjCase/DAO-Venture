import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Option "mo:base/Option";
import IterTools "mo:itertools/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Flag "../models/Flag";
import Town "../models/Town";

module {

    public type StableData = {
        towns : [StableTownData];
    };

    public type StableTownData = {
        id : Nat;
        currency : Nat;
        name : Text;
        flagImage : Flag.FlagImage;
        motto : Text;
        entropy : Nat;
    };

    type MutableTownData = {
        id : Nat;
        var name : Text;
        var flagImage : Flag.FlagImage;
        var motto : Text;
        var entropy : Nat;
        var currency : Nat;
    };

    public class Handler<system>(
        data : StableData
    ) {

        var towns : HashMap.HashMap<Nat, MutableTownData> = toTownHashMap(data.towns);

        var nextTownId = towns.size(); // TODO change to check for the largest town id in the list

        public func toStableData() : StableData {
            {
                towns = towns.vals()
                |> Iter.map<MutableTownData, StableTownData>(
                    _,
                    toStableTownData,
                )
                |> Iter.toArray(_);
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
            ?{
                id = town.id;
                name = town.name;
                flagImage = town.flagImage;
                motto = town.motto;
                entropy = town.entropy;
                currency = town.currency;
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
            flagImage : Flag.FlagImage,
            motto : Text,
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
                var flagImage = flagImage;
                var motto = motto;
                var entropy = entropy;
                var currency = currency;
            };
            towns.put(townId, townData);

            return #ok(townId);
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

        public func updateFlag(townId : Nat, flagImage : Flag.FlagImage) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating flag image for town " # Nat.toText(townId));
            town.flagImage := flagImage;
            #ok;
        };

        public func updateMotto(townId : Nat, newMotto : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating motto for town " # Nat.toText(townId) # " to: " # newMotto);
            town.motto := newMotto;
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

        public func clear() {
            towns := HashMap.HashMap<Nat, MutableTownData>(0, Nat.equal, Nat32.fromNat);
        };

        private func toTown(town : MutableTownData) : Town.Town {
            {
                id = town.id;
                currency = town.currency;
                entropy = town.entropy;
                name = town.name;
                flagImage = town.flagImage;
                motto = town.motto;
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
            var flagImage = stableData.flagImage;
            var motto = stableData.motto;
            var entropy = stableData.entropy;
        };
    };

    private func toStableTownData(town : MutableTownData) : StableTownData {
        {
            id = town.id;
            currency = town.currency;
            entropy = town.entropy;
            name = town.name;
            flagImage = town.flagImage;
            motto = town.motto;
        };
    };

};