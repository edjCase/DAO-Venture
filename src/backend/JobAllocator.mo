import Town "models/Town";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import IterTools "mo:itertools/Iter";
import World "models/World";

module {

    public type TownWorkAllocation = {
        woodGatherers : Nat;
        foodGatherers : Nat;
        stoneGatherers : Nat;
        goldGatherers : Nat;
        woodProcessers : Nat;
        stoneProcessers : Nat;
    };

    public type ResourceLocationWorkAllocation = {
        locationId : Nat;
        kind : World.ResourceLocationKind;
        workers : Nat;
    };

    public func allocateWorkInTown(town : Town.Town) : TownWorkAllocation {
        let totalWeight = town.workPlan.gatherWood.weight + town.workPlan.gatherFood.weight + town.workPlan.gatherStone.weight + town.workPlan.gatherGold.weight + town.workPlan.processWood.weight + town.workPlan.processStone.weight;
        let woodGathererCount = town.workPlan.gatherWood.weight / totalWeight * Float.fromInt(town.population);
        let foodGathererCount = town.workPlan.gatherFood.weight / totalWeight * Float.fromInt(town.population);
        let stoneGathererCount = town.workPlan.gatherStone.weight / totalWeight * Float.fromInt(town.population);
        let goldGathererCount = town.workPlan.gatherGold.weight / totalWeight * Float.fromInt(town.population);
        let woodProcesserCount = town.workPlan.processWood.weight / totalWeight * Float.fromInt(town.population);
        let stoneProcesserCount = town.workPlan.processStone.weight / totalWeight * Float.fromInt(town.population);
        // TODO rounding errors?

        let toNat = func(f : Float) : Nat {
            let i = Float.toInt(f);
            if (i < 0) {
                Debug.trap("Negative not possible for worker allocation counts");
            };
            Int.abs(i);
        };
        {
            woodGatherers = toNat(woodGathererCount);
            foodGatherers = toNat(foodGathererCount);
            stoneGatherers = toNat(stoneGathererCount);
            goldGatherers = toNat(goldGathererCount);
            woodProcessers = toNat(woodProcesserCount);
            stoneProcessers = toNat(stoneProcesserCount);
        };
    };

    public func allocateWorkToResourceLocations(
        workPlan : {
            woodGatherers : Nat;
            foodGatherers : Nat;
            stoneGatherers : Nat;
            goldGatherers : Nat;
        },
        locations : [World.WorldLocation],
    ) : [ResourceLocationWorkAllocation] {

        let goldLocations = locations.vals()
        |> IterTools.mapFilter(
            _,
            func(loc : World.WorldLocation) : ?(Nat, World.GoldResourceInfo) {
                let #gold(gold) = loc.kind else return null;
                ?(loc.id, gold);
            },
        )
        |> Iter.toArray(_);

        let foodLocations = locations.vals()
        |> IterTools.mapFilter(
            _,
            func(loc : World.WorldLocation) : ?(Nat, World.FoodResourceInfo) {
                let #food(food) = loc.kind else return null;
                ?(loc.id, food);
            },
        )
        |> Iter.toArray(_);

        let woodLocations = locations.vals()
        |> IterTools.mapFilter(
            _,
            func(loc : World.WorldLocation) : ?(Nat, World.WoodResourceInfo) {
                let #wood(wood) = loc.kind else return null;
                ?(loc.id, wood);
            },
        )
        |> Iter.toArray(_);

        let stoneLocations = locations.vals()
        |> IterTools.mapFilter(
            _,
            func(loc : World.WorldLocation) : ?(Nat, World.StoneResourceInfo) {
                let #stone(stone) = loc.kind else return null;
                ?(loc.id, stone);
            },
        )
        |> Iter.toArray(_);

        // TODO rounding loss
        // TODO better allocation algorithm
        let goldWorkersPerLocation = workPlan.goldGatherers / goldLocations.size();
        let foodWorkersPerLocation = workPlan.foodGatherers / foodLocations.size();
        let woodWorkersPerLocation = workPlan.woodGatherers / woodLocations.size();
        let stoneWorkersPerLocation = workPlan.stoneGatherers / stoneLocations.size();

        goldLocations.vals()
        |> Iter.map(
            _,
            func((locId, goldInfo) : (Nat, World.GoldResourceInfo)) : ResourceLocationWorkAllocation {
                {
                    locationId = locId;
                    kind = #gold(goldInfo);
                    workers = goldWorkersPerLocation;
                };
            },
        )
        |> IterTools.chain(
            _,
            foodLocations.vals()
            |> Iter.map(
                _,
                func((locId, foodInfo) : (Nat, World.FoodResourceInfo)) : ResourceLocationWorkAllocation {
                    {
                        locationId = locId;
                        kind = #food(foodInfo);
                        workers = foodWorkersPerLocation;
                    };
                },
            ),
        )
        |> IterTools.chain(
            _,
            woodLocations.vals()
            |> Iter.map(
                _,
                func((locId, woodInfo) : (Nat, World.WoodResourceInfo)) : ResourceLocationWorkAllocation {
                    {
                        locationId = locId;
                        kind = #wood(woodInfo);
                        workers = woodWorkersPerLocation;
                    };
                },
            ),
        )
        |> IterTools.chain(
            _,
            stoneLocations.vals()
            |> Iter.map(
                _,
                func((locId, stoneInfo) : (Nat, World.StoneResourceInfo)) : ResourceLocationWorkAllocation {
                    {
                        locationId = locId;
                        kind = #stone(stoneInfo);
                        workers = stoneWorkersPerLocation;
                    };
                },
            ),
        )
        |> Iter.toArray(_);

    };
};
