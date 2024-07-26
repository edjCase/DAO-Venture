import Town "models/Town";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import IterTools "mo:itertools/Iter";
import World "models/World";

module {
    type TownAvailableWork = {
        townId : Nat;
        var goldCanHarvest : Nat;
        var woodCanHarvest : Nat;
        var foodCanHarvest : Nat;
        var stoneCanHarvest : Nat;
    };
    type JobKey = {
        townId : Nat;
        jobId : Nat;
    };
    type Location = {
        resources : World.LocationResourceList;
    };

    public func buildLocationJobs(
        towns : [Town.Town],
        locations : [Location],
    ) : HashMap.HashMap<Nat, HashMap.HashMap<Nat, TownAvailableWork>> {
        let jobWorkerCountMap = buildJobWorkerCounts(towns);
        // Location Id -> Town Id -> TownAvailableWork
        let locationTownWorkMap = HashMap.HashMap<Nat, HashMap.HashMap<Nat, TownAvailableWork>>(locations.size(), Nat.equal, Nat32.fromNat);
        // Go through all the towns
        for (town in towns.vals()) {
            // And for each job, add the amount of resources that can be harvested
            // from that location for that town
            label j for ((jobId, job) in IterTools.enumerate(town.jobs.vals())) {
                let workerCount = Option.get(jobWorkerCountMap.get({ townId = town.id; jobId = jobId }), 0);
                switch (job) {
                    case (#gatherResource(gatherResourceJob)) {
                        let location = locations.get(gatherResourceJob.locationId);

                        let calculateAmountWithDifficulty = func(workerCount : Int, proficiencyLevel : Nat, techLevel : Nat, difficulty : Nat) : Nat {
                            let baseAmount = workerCount + proficiencyLevel + techLevel;
                            let difficultyScalingFactor = 0.001; // Adjust this value to change the steepness of the linear decrease

                            let scaledDifficulty = Float.fromInt(difficulty) * difficultyScalingFactor;
                            let amountFloat = Float.fromInt(baseAmount) - scaledDifficulty;

                            let amountInt = Float.toInt(amountFloat);
                            if (amountInt <= 1) {
                                1;
                            } else {
                                Int.abs(amountInt);
                            };
                        };

                        let amountCanHarvest : Nat = switch (gatherResourceJob.resource) {
                            case (#wood) workerCount + town.skills.woodCutting.proficiencyLevel + town.skills.woodCutting.techLevel;
                            case (#food) workerCount + town.skills.farming.proficiencyLevel + town.skills.farming.techLevel;
                            case (#gold) calculateAmountWithDifficulty(
                                workerCount,
                                town.skills.mining.proficiencyLevel,
                                town.skills.mining.techLevel,
                                location.resources.gold.difficulty,
                            );
                            case (#stone) calculateAmountWithDifficulty(
                                workerCount,
                                town.skills.mining.proficiencyLevel,
                                town.skills.mining.techLevel,
                                location.resources.stone.difficulty,
                            );
                        };

                        let townWorkMap : HashMap.HashMap<Nat, TownAvailableWork> = switch (locationTownWorkMap.get(gatherResourceJob.locationId)) {
                            case (?townWorkMap) townWorkMap;
                            case (null) {
                                let newTownWorkMap = HashMap.HashMap<Nat, TownAvailableWork>(1, Nat.equal, Nat32.fromNat);
                                locationTownWorkMap.put(gatherResourceJob.locationId, newTownWorkMap);
                                newTownWorkMap;
                            };
                        };
                        let townWork : TownAvailableWork = switch (townWorkMap.get(town.id)) {
                            case (?townWork) townWork;
                            case (null) {
                                let newTownWork : TownAvailableWork = {
                                    townId = town.id;
                                    var goldCanHarvest = 0;
                                    var woodCanHarvest = 0;
                                    var foodCanHarvest = 0;
                                    var stoneCanHarvest = 0;
                                };
                                townWorkMap.put(town.id, newTownWork);
                                newTownWork;
                            };
                        };
                        switch (gatherResourceJob.resource) {
                            case (#gold) townWork.goldCanHarvest += amountCanHarvest;
                            case (#wood) townWork.woodCanHarvest += amountCanHarvest;
                            case (#food) townWork.foodCanHarvest += amountCanHarvest;
                            case (#stone) townWork.stoneCanHarvest += amountCanHarvest;
                        };
                    };
                    case (#processResource(_)) {};
                };
            };
        };

        for ((locationId, townWorkMap) in locationTownWorkMap.entries()) {
            adjustAmountsForScarcity(locations.get(locationId), townWorkMap);
        };
        locationTownWorkMap;
    };

    private func adjustAmountsForScarcity(
        location : Location,
        townWorkMap : HashMap.HashMap<Nat, TownAvailableWork>,
    ) {
        // Readjust the amount of resources that can be harvested from the location
        // based on all the workers in that location and resource scarcity

        // Calculate total resource requests
        var totalWoodRequest = 0;
        var totalFoodRequest = 0;

        for ((_, townWork) in townWorkMap.entries()) {
            totalWoodRequest += townWork.woodCanHarvest;
            totalFoodRequest += townWork.foodCanHarvest;
        };

        let calculateProportion = func(value : Nat, total : Nat) : Float {
            if (total == 0) {
                return 0;
            };
            Float.min(1, Float.fromInt(value) / Float.fromInt(total));
        };

        // Calculate proportions if requests exceed available resources
        let woodProportion = calculateProportion(location.resources.wood.amount, totalWoodRequest);
        let foodProportion = calculateProportion(location.resources.food.amount, totalFoodRequest);

        let calculatePropotionValue = func(value : Nat, proportion : Float) : Nat {
            let adjustedValueInt = Float.toInt(Float.fromInt(value) * proportion);
            if (adjustedValueInt < 0) {
                Debug.trap("Adjusted value is less than 0");
            };
            Int.abs(adjustedValueInt);
        };

        // Readjust the amount of resources that can be harvested
        for ((townId, townWork) in townWorkMap.entries()) {
            townWork.woodCanHarvest := calculatePropotionValue(townWork.woodCanHarvest, woodProportion);
            townWork.foodCanHarvest := calculatePropotionValue(townWork.foodCanHarvest, foodProportion);
        };
    };

    private func buildJobWorkerCounts(
        towns : [Town.Town]
    ) : HashMap.HashMap<JobKey, Nat> {
        let jobKeyEqual = func(a : JobKey, b : JobKey) : Bool = a.townId == b.townId and a.jobId == b.jobId;
        let jobKeyHash = func(k : JobKey) : Nat32 = Nat32.fromNat(k.townId) ^ Nat32.fromNat(k.jobId);
        let jobWorkerCountMap = HashMap.HashMap<JobKey, Nat>(1, jobKeyEqual, jobKeyHash);

        // Go through all the towns
        for (town in towns.vals()) {
            var remainingPopulation = town.population;
            var totalQuota : Nat = 0;

            let getJobWorkerQuota = func(job : Town.Job) : Nat {
                switch (job) {
                    case (#gatherResource(gatherResourceJob)) gatherResourceJob.workerQuota;
                    case (#processResource(processResourceJob)) processResourceJob.workerQuota;
                };
            };

            // First, calculate the total quota for all jobs in the town
            for (job in town.jobs.vals()) {
                totalQuota += getJobWorkerQuota(job);
            };

            // Now distribute workers proportionally
            label f for ((jobId, job) in IterTools.enumerate(town.jobs.vals())) {
                if (totalQuota == 0) {
                    // Handle the case where total quota is 0 to avoid division by zero
                    jobWorkerCountMap.put({ townId = town.id; jobId = jobId }, 0);
                    continue f;
                };

                // Calculate the proportional number of workers for this job
                let workerQuota = getJobWorkerQuota(job);
                let workerCount = (workerQuota * remainingPopulation) / totalQuota;
                jobWorkerCountMap.put({ townId = town.id; jobId = jobId }, workerCount);

                // Update remaining population and total quota
                remainingPopulation -= workerCount;
                totalQuota -= workerQuota;
            };

            // If there's any remaining population due to rounding, assign it to the last job
            if (remainingPopulation > 0 and town.jobs.size() > 0) {
                let lastJobId : Nat = town.jobs.size() - 1;
                let currentCount = jobWorkerCountMap.get({
                    townId = town.id;
                    jobId = lastJobId;
                });
                switch (currentCount) {
                    case (?count) {
                        jobWorkerCountMap.put({ townId = town.id; jobId = lastJobId }, count + remainingPopulation);
                    };
                    case (null) {
                        // This case should not occur if the code is correct, but handle it just in case
                        jobWorkerCountMap.put({ townId = town.id; jobId = lastJobId }, remainingPopulation);
                    };
                };
            };
        };

        jobWorkerCountMap;
    };
};
