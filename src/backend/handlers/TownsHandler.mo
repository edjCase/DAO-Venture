import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Order "mo:base/Order";
import Flag "../models/Flag";
import Town "../models/Town";
import IterTools "mo:itertools/Iter";
import CommonTypes "../CommonTypes";

module {

    public type StableData = {
        towns : [StableTownData];
    };

    public type StableTownData = Town.Town and {
        history : [DaySnapshot];
    };

    type MutableTownData = {
        id : Nat;
        var name : Text;
        var flagImage : Flag.FlagImage;
        history : HashMap.HashMap<Nat, DaySnapshot>;
    };

    public type DaySnapshot = {
        day : Nat;
        work : DaySnapshotWork;
    };

    public type DaySnapshotWork = {
        wood : Nat;
        food : Nat;
        stone : Nat;
        gold : Nat;
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
                    fromMutableTown,
                )
                |> Iter.toArray(_);
            };
        };

        public func get(townId : Nat) : ?Town.Town {
            let ?town = towns.get(townId) else return null;
            ?fromMutableTown(town);
        };

        public func getAll() : [Town.Town] {
            towns.vals()
            |> Iter.map<MutableTownData, Town.Town>(
                _,
                fromMutableTown,
            )
            |> Iter.toArray(_);
        };

        public func getHistory(townId : Nat, count : Nat, offset : Nat) : Result.Result<CommonTypes.PagedResult<DaySnapshot>, { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let history = town.history.vals()
            // Sort from newest to oldest
            |> Iter.sort(_, func(a : DaySnapshot, b : DaySnapshot) : Order.Order = Nat.compare(b.day, a.day))
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
            |> Iter.toArray(_);
            #ok({
                total = town.history.size();
                data = history;
                count = count;
                offset = offset;
            });
        };

        public func create<system>(
            name : Text,
            flagImage : Flag.FlagImage,
        ) : Nat {
            Debug.print("Creating new town with name " # name);
            let townId = nextTownId;
            nextTownId += 1;

            let townData : MutableTownData = {
                id = townId;
                var name = name;
                var flagImage = flagImage;
                history = HashMap.HashMap<Nat, DaySnapshot>(0, Nat.equal, Nat32.fromNat);
            };
            towns.put(townId, townData);

            return townId;
        };

        public func updateName(townId : Nat, newName : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
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

        public func clear() {
            towns := HashMap.HashMap<Nat, MutableTownData>(0, Nat.equal, Nat32.fromNat);
        };

    };

    private func fromMutableTown(town : MutableTownData) : StableTownData {
        {
            id = town.id;
            name = town.name;
            flagImage = town.flagImage;
            history = town.history.vals()
            |> Iter.sort(_, func(a : DaySnapshot, b : DaySnapshot) : Order.Order = Nat.compare(a.day, b.day))
            |> Iter.toArray(_);
        };
    };

    private func toMutableTownData(stableData : StableTownData) : MutableTownData {
        {
            id = stableData.id;
            var name = stableData.name;
            var flagImage = stableData.flagImage;
            history = stableData.history.vals()
            |> Iter.map<DaySnapshot, (Nat, DaySnapshot)>(
                _,
                func(snapshot : DaySnapshot) : (Nat, DaySnapshot) = (snapshot.day, snapshot),
            )
            |> HashMap.fromIter<Nat, DaySnapshot>(
                _,
                stableData.history.size(),
                Nat.equal,
                Nat32.fromNat,
            );
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
};
