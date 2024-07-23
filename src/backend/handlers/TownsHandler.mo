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
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Prelude "mo:base/Prelude";
import Flag "../models/Flag";
import Town "../models/Town";
import World "../models/World";

module {

    public type StableData = {
        towns : [StableTownData];
    };

    public type StableTownData = Town.Town;

    type MutableTownData = {
        id : Nat;
        var name : Text;
        var flagImage : Flag.FlagImage;
        var motto : Text;
        var entropy : Nat;
        var population : Nat;
        var size : Nat;
        genesisTime : Time.Time;
        jobs : Buffer.Buffer<Town.Job>;
        skills : MutableTownSkillList;
        resources : MutableTownResourceList;
    };

    type MutableTownResourceList = {
        var gold : Nat;
        var wood : Nat;
        var food : Nat;
        var stone : Nat;
    };

    type MutableTownSkillList = {
        woodCutting : MutableSkill;
        farming : MutableSkill;
        mining : MutableSkill;
    };

    type MutableSkill = {
        var techLevel : Nat;
        var proficiencyLevel : Nat;
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

        public func create<system>(
            name : Text,
            flagImage : Flag.FlagImage,
            motto : Text,
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
                var entropy = 0;
                var gold = 0;
                var population = 0;
                var size = 0;
                genesisTime = Time.now();
                jobs = Buffer.Buffer<Town.Job>(0);
                skills = {
                    woodCutting = {
                        var techLevel = 0;
                        var proficiencyLevel = 0;
                    };
                    farming = {
                        var techLevel = 0;
                        var proficiencyLevel = 0;
                    };
                    mining = {
                        var techLevel = 0;
                        var proficiencyLevel = 0;
                    };
                };
                resources = {
                    var gold = 0;
                    var wood = 0;
                    var food = 0;
                    var stone = 0;
                };
            };
            towns.put(townId, townData);

            return #ok(townId);
        };

        public func addResource(
            townId : Nat,
            resource : World.ResourceKind,
            amount : Nat,
        ) : Result.Result<(), { #townNotFound }> {
            switch (updateResource(townId, resource, amount, false)) {
                case (#ok) #ok;
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResource)) Prelude.unreachable();
            };
        };

        public func updateResource(
            townId : Nat,
            resource : World.ResourceKind,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResource }> {
            switch (updateResourceBulk(townId, [{ kind = resource; delta = delta }], allowBelowZero)) {
                case (#ok) #ok;
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResources(_))) #err(#notEnoughResource);
            };
        };

        public func updateResourceBulk(
            townId : Nat,
            resources : [{
                kind : World.ResourceKind;
                delta : Int;
            }],
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResources : [World.ResourceKind] }> {
            if (resources.size() == 0) {
                return #ok;
            };
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newResources = Buffer.Buffer<{ kind : World.ResourceKind; newValue : Nat }>(resources.size());
            let notEnoughResources : Buffer.Buffer<World.ResourceKind> = Buffer.Buffer<World.ResourceKind>(0);
            label l for (resource in resources.vals()) {
                if (resource.delta == 0) {
                    continue l;
                };
                let currentValue = switch (resource.kind) {
                    case (#gold) town.resources.gold;
                    case (#wood) town.resources.wood;
                    case (#food) town.resources.food;
                    case (#stone) town.resources.stone;
                };
                let newResource = currentValue + resource.delta;
                if (not allowBelowZero and newResource < 0) {
                    notEnoughResources.add(resource.kind);
                    continue l;
                };
                let newResourceNat = if (newResource <= 0) {
                    0;
                } else {
                    Int.abs(newResource);
                };
                newResources.add({
                    kind = resource.kind;
                    newValue = newResourceNat;
                });
            };
            if (notEnoughResources.size() > 0) {
                return #err(#notEnoughResources(Buffer.toArray(notEnoughResources)));
            };
            for (resource in newResources.vals()) {
                Debug.print("Updating resource " # debug_show (resource.kind) # " for town " # Nat.toText(townId) # " to " # Nat.toText(resource.newValue));
                switch (resource.kind) {
                    case (#gold) {
                        town.resources.gold := resource.newValue;
                    };
                    case (#wood) {
                        town.resources.wood := resource.newValue;
                    };
                    case (#food) {
                        town.resources.food := resource.newValue;
                    };
                    case (#stone) {
                        town.resources.stone := resource.newValue;
                    };
                };
            };
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

    };

    private func fromMutableTown(town : MutableTownData) : Town.Town {
        {
            id = town.id;
            entropy = town.entropy;
            name = town.name;
            flagImage = town.flagImage;
            motto = town.motto;
            genesisTime = town.genesisTime;
            population = town.population;
            size = town.size;
            jobs = Buffer.toArray<Town.Job>(town.jobs);
            skills = {
                woodCutting = fromMutableSkill(town.skills.woodCutting);
                farming = fromMutableSkill(town.skills.farming);
                mining = fromMutableSkill(town.skills.mining);
            };
            resources = {
                gold = town.resources.gold;
                wood = town.resources.wood;
                food = town.resources.food;
                stone = town.resources.stone;
            };
        };
    };

    private func fromMutableSkill(skill : MutableSkill) : Town.Skill {
        {
            techLevel = skill.techLevel;
            proficiencyLevel = skill.proficiencyLevel;
        };
    };

    private func toMutableTownData(stableData : StableTownData) : MutableTownData {
        {
            id = stableData.id;
            var name = stableData.name;
            var flagImage = stableData.flagImage;
            var motto = stableData.motto;
            var entropy = stableData.entropy;
            var population = stableData.population;
            var size = stableData.size;
            genesisTime = stableData.genesisTime;
            jobs = Buffer.Buffer<Town.Job>(0);
            skills = {
                woodCutting = toMutableSkill(stableData.skills.woodCutting);
                farming = toMutableSkill(stableData.skills.farming);
                mining = toMutableSkill(stableData.skills.mining);
            };
            resources = {
                var gold = stableData.resources.gold;
                var wood = stableData.resources.wood;
                var food = stableData.resources.food;
                var stone = stableData.resources.stone;
            };
        };
    };

    private func toMutableSkill(skill : Town.Skill) : MutableSkill {
        {
            var techLevel = skill.techLevel;
            var proficiencyLevel = skill.proficiencyLevel;
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
