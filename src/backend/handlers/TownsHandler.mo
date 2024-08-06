import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Prelude "mo:base/Prelude";
import Order "mo:base/Order";
import Flag "../models/Flag";
import Town "../models/Town";
import World "../models/World";
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
        var color : (Nat8, Nat8, Nat8);
        var motto : Text;
        var population : Nat;
        var populationMax : Nat;
        var health : Nat;
        var upkeepCondition : Nat;
        var size : Nat;
        genesisTime : Time.Time;
        jobs : Buffer.Buffer<Town.Job>;
        resources : MutableTownResourceList;
        history : HashMap.HashMap<Nat, DaySnapshot>;
    };

    public type DaySnapshot = {
        day : Nat;
        work : DaySnapshotWork;
    };

    public type DaySnapshotWork = {
        wood : ResourceSnapshot;
        food : ResourceSnapshot;
        stone : ResourceSnapshot;
        gold : ResourceSnapshot;
    };

    public type ResourceSnapshot = {
        amount : Nat;
    };

    type MutableTownResourceList = {
        var gold : Nat;
        var wood : Nat;
        var food : Nat;
        var stone : Nat;
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
            color : (Nat8, Nat8, Nat8),
            motto : Text,
            resources : Town.ResourceList,
        ) : Nat {
            Debug.print("Creating new town with name " # name);
            let townId = nextTownId;
            nextTownId += 1;

            let townData : MutableTownData = {
                id = townId;
                var name = name;
                var flagImage = flagImage;
                var color = color;
                var motto = motto;
                var population = 10;
                var populationMax = 10;
                var health = 100;
                var upkeepCondition = 100;
                var size = 0;
                genesisTime = Time.now();
                jobs = Buffer.Buffer<Town.Job>(0);
                skills = {
                    woodCutting = {
                        var techLevel = 0;
                        var proficiencyMultiplier = 1;
                    };
                    farming = {
                        var techLevel = 0;
                        var proficiencyMultiplier = 1;
                    };
                    mining = {
                        var techLevel = 0;
                        var proficiencyMultiplier = 1;
                    };
                    carpentry = {
                        var techLevel = 0;
                        var proficiencyMultiplier = 1;
                    };
                    masonry = {
                        var techLevel = 0;
                        var proficiencyMultiplier = 1;
                    };
                };
                resources = {
                    var gold = resources.gold;
                    var wood = resources.wood;
                    var food = resources.food;
                    var stone = resources.stone;
                };
                var workPlan = {
                    gatherWood = {
                        weight = 1;
                        locationLimits = [];
                    };
                    gatherFood = {
                        weight = 2;
                        locationLimits = [];
                    };
                    gatherStone = {
                        weight = 1;
                        efficiencyMin = 0.0;
                    };
                    gatherGold = {
                        weight = 1;
                        efficiencyMin = 0.0;
                    };
                    processWood = {
                        weight = 0;
                        maxStorage = 0;
                    };
                    processStone = {
                        weight = 0;
                        maxStorage = 0;
                    };
                };
                history = HashMap.HashMap<Nat, DaySnapshot>(0, Nat.equal, Nat32.fromNat);
            };
            towns.put(townId, townData);

            return townId;
        };

        public func addDaySnapshot(townId : Nat, snapshot : DaySnapshot) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let null = town.history.replace(snapshot.day, snapshot) else Debug.trap("Day snapshot already exists for town " # Nat.toText(townId) # " on day " # Nat.toText(snapshot.day));
            #ok;
        };

        public func addResource(
            townId : Nat,
            resource : World.ResourceKind,
            amount : Nat,
        ) : Result.Result<(), { #townNotFound }> {
            switch (updateResource(townId, resource, amount, false)) {
                case (#ok) #ok;
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResource(_))) Prelude.unreachable();
            };
        };

        public func updateResource(
            townId : Nat,
            resource : World.ResourceKind,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResource : { defecit : Nat } }> {
            switch (updateResourceBulk(townId, [{ kind = resource; delta = delta }], allowBelowZero)) {
                case (#ok) #ok();
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResources(r))) #err(#notEnoughResource(r[0]));
            };
        };

        public func updateResourceBulk(
            townId : Nat,
            resources : [{
                kind : World.ResourceKind;
                delta : Int;
            }],
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResources : [{ defecit : Nat; kind : World.ResourceKind }] }> {
            if (resources.size() == 0) {
                return #ok;
            };
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newResources = Buffer.Buffer<{ kind : World.ResourceKind; delta : Int; newValue : Nat }>(resources.size());
            let notEnoughResources = Buffer.Buffer<{ defecit : Nat; kind : World.ResourceKind }>(0);
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

                    notEnoughResources.add({
                        kind = resource.kind;
                        defecit = Int.abs(newResource);
                    });
                    continue l;
                };
                let newResourceNat = if (newResource <= 0) {
                    0;
                } else {
                    Int.abs(newResource);
                };
                newResources.add({
                    kind = resource.kind;
                    delta = resource.delta;
                    newValue = newResourceNat;
                });
            };
            if (notEnoughResources.size() > 0) {
                return #err(#notEnoughResources(Buffer.toArray(notEnoughResources)));
            };
            for (resource in newResources.vals()) {
                Debug.print("Updating resource " # debug_show (resource.kind) # " for town " # Nat.toText(townId) # " by " # Int.toText(resource.delta) # " to " # Nat.toText(resource.newValue));
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

        public func updateMotto(townId : Nat, newMotto : Text) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            Debug.print("Updating motto for town " # Nat.toText(townId) # " to: " # newMotto);
            town.motto := newMotto;
            #ok;
        };

        public func addPopulation(townId : Nat, delta : Int) : Result.Result<Nat, { #townNotFound }> {
            switch (updatePopulation(townId, delta)) {
                case (#ok(newPopulation)) #ok(newPopulation);
                case (#err(#townNotFound)) #err(#townNotFound);
            };
        };

        public func updatePopulation(townId : Nat, delta : Int) : Result.Result<Nat, { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newPopulationInt : Int = town.population + delta;
            let newPopulationNat : Nat = if (newPopulationInt <= 0) {
                // Population cant be negative
                0;
            } else {
                Nat.min(town.populationMax, Int.abs(newPopulationInt));
            };
            if (town.population != newPopulationNat) {
                Debug.print("Updating population for town " # Nat.toText(townId) # " by " # Int.toText(delta) # " to " # Nat.toText(newPopulationNat));
                town.population := newPopulationNat;
            };
            #ok(newPopulationNat);
        };

        public func setPopulationMax(townId : Nat, newMax : Nat) : Result.Result<(), { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            if (town.populationMax != newMax) {
                Debug.print("Setting population max for town " # Nat.toText(townId) # " to " # Nat.toText(newMax));
                town.populationMax := newMax;
            };
            #ok;
        };

        public func updateHealth(townId : Nat, delta : Int) : Result.Result<Nat, { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newHealthInt : Int = town.health + delta;
            let newHealthNat : Nat = if (newHealthInt <= 0) {
                // Health cant be negative
                0;
            } else if (newHealthInt >= 100) {
                // Health cant be over 100
                100;
            } else {
                Int.abs(newHealthInt);
            };
            if (town.health != newHealthNat) {
                Debug.print("Updating health for town " # Nat.toText(townId) # " by " # Int.toText(delta) # " to " # Nat.toText(newHealthNat));
                town.health := newHealthNat;
            };
            #ok(newHealthNat);
        };

        public func updateUpkeepCondition(townId : Nat, delta : Int) : Result.Result<Nat, { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newUpkeepConditionInt : Int = town.upkeepCondition + delta;
            let newUpkeepConditionNat : Nat = if (newUpkeepConditionInt <= 0) {
                // Upkeep condition cant be negative
                0;
            } else if (newUpkeepConditionInt >= 100) {
                // Upkeep condition cant be over 100
                100;
            } else {
                Int.abs(newUpkeepConditionInt);
            };
            if (town.upkeepCondition != newUpkeepConditionNat) {
                Debug.print("Updating upkeep condition for town " # Nat.toText(townId) # " by " # Int.toText(delta) # " to " # Nat.toText(newUpkeepConditionNat));
                town.upkeepCondition := newUpkeepConditionNat;
            };
            #ok(newUpkeepConditionNat);
        };

        public func updateSize(townId : Nat, delta : Int) : Result.Result<Nat, { #townNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            let newSizeInt : Int = town.size + delta;
            let newSizeNat : Nat = if (newSizeInt <= 0) {
                // Size cant be negative
                0;
            } else {
                Int.abs(newSizeInt);
            };
            if (town.size != newSizeNat) {
                Debug.print("Updating size for town " # Nat.toText(townId) # " by " # Int.toText(delta) # " to " # Nat.toText(newSizeNat));
                town.size := newSizeNat;
            };
            #ok(newSizeNat);
        };

        public func addJob(townId : Nat, job : Town.Job) : Result.Result<Nat, { #townNotFound; #invalid : [Text] }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            switch (validateJob(job)) {
                case (#err(err)) return #err(err);
                case (#ok) ();
            };
            let jobId = town.jobs.size();
            Debug.print("Adding job " # debug_show (job) # " to town " # Nat.toText(townId) # " with id " # Nat.toText(jobId));
            town.jobs.add(job);
            #ok(jobId);
        };

        public func updateJob(townId : Nat, jobId : Nat, job : Town.Job) : Result.Result<(), { #townNotFound; #invalid : [Text]; #jobNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);
            switch (validateJob(job)) {
                case (#err(err)) return #err(err);
                case (#ok) ();
            };
            if (jobId >= town.jobs.size()) {
                return #err(#jobNotFound);
            };
            Debug.print("Updating job " # Nat.toText(jobId) # " for town " # Nat.toText(townId) # " to: " # debug_show (job));

            town.jobs.put(jobId, job);
            #ok;
        };

        public func removeJob(townId : Nat, jobId : Nat) : Result.Result<(), { #townNotFound; #jobNotFound }> {
            let ?town = towns.get(townId) else return #err(#townNotFound);

            if (jobId >= town.jobs.size()) {
                return #err(#jobNotFound);
            };
            Debug.print("Removing job " # Nat.toText(jobId) # " for town " # Nat.toText(townId));
            ignore town.jobs.remove(jobId);
            #ok;
        };

        public func clear() {
            towns := HashMap.HashMap<Nat, MutableTownData>(0, Nat.equal, Nat32.fromNat);
        };

        private func validateJob(job : Town.Job) : Result.Result<(), { #invalid : [Text] }> {
            let errors = Buffer.Buffer<Text>(0);
            switch (job) {
                case (#explore(_)) {

                    // TODO check if location is explored?
                };
            };
            if (errors.size() > 0) {
                return #err(#invalid(Buffer.toArray(errors)));
            };
            #ok;
        };

    };

    private func fromMutableTown(town : MutableTownData) : StableTownData {
        {
            id = town.id;
            name = town.name;
            flagImage = town.flagImage;
            color = town.color;
            motto = town.motto;
            genesisTime = town.genesisTime;
            population = town.population;
            populationMax = town.populationMax;
            health = town.health;
            upkeepCondition = town.upkeepCondition;
            size = town.size;
            jobs = Buffer.toArray<Town.Job>(town.jobs);
            resources = {
                gold = town.resources.gold;
                wood = town.resources.wood;
                food = town.resources.food;
                stone = town.resources.stone;
            };
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
            var color = stableData.color;
            var motto = stableData.motto;
            var population = stableData.population;
            var populationMax = stableData.populationMax;
            var health = stableData.health;
            var upkeepCondition = stableData.upkeepCondition;
            var size = stableData.size;
            genesisTime = stableData.genesisTime;
            jobs = Buffer.fromArray(stableData.jobs);
            resources = {
                var gold = stableData.resources.gold;
                var wood = stableData.resources.wood;
                var food = stableData.resources.food;
                var stone = stableData.resources.stone;
            };
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
