import Town "models/Town";
import HashMap "mo:base/HashMap";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
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

    type JobWithWorkers = {
        town : Town.Town;
        jobId : Nat;
        workers : Nat;
        job : Town.Job;
    };

    public type CalculatedJob = JobWithWorkers and {
        amount : Nat;
    };

    public func calculateJobNumbers(
        towns : [Town.Town],
        locations : HashMap.HashMap<Nat, World.WorldLocation>,
    ) : [CalculatedJob] {
        towns.vals()
        |> Iter.map(_, buildJobsWithWorkerCount)
        |> IterTools.flatten<JobWithWorkers>(_)
        |> Iter.map(
            _,
            func(job : JobWithWorkers) : CalculatedJob {
                let amount = switch (job.job) {
                    // TODO handle case where workers extract more than the resource
                    case (#gatherResource(gatherResourceJob)) getGatherResourceAmount(job.town, job.workers, gatherResourceJob, locations);
                    case (#processResource(processResourceJob)) getProcessResourceAmount(job.town, job.workers, processResourceJob);
                    case (#explore(exploreJob)) getExploreAmount(job.town, job.workers, exploreJob, locations);
                };
                {
                    job with
                    amount = amount;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func getExploreAmount(
        _ : Town.Town,
        workerCount : Nat,
        _ : Town.ExploreJob,
        _ : HashMap.HashMap<Nat, World.WorldLocation>,
    ) : Nat {
        // TODO proficiency and tech levels?
        workerCount;
    };

    private func getProcessResourceAmount(
        town : Town.Town,
        workerCount : Nat,
        processResourceJob : Town.ProcessResourceJob,
    ) : Nat {
        let (proficiency, techLevel, baseRate) = switch (processResourceJob.resource) {
            case (#wood) (town.skills.carpentry.proficiencyLevel, town.skills.carpentry.techLevel, 2);
            case (#stone) (town.skills.masonry.proficiencyLevel, town.skills.masonry.techLevel, 2);
        };
        // Step 1: Calculate extraction based on number of workers
        let workerExtraction : Nat = workerCount * baseRate;

        // Step 2: Apply proficiency modifier
        let proficiencyModifier : Float = 1 + (Float.fromInt(proficiency) * 0.1); // TODO

        // Step 3: Apply tech level modifier
        let techModifier : Float = 1 + (Float.fromInt(techLevel) * 0.2); // TODO

        // Calculate total extraction
        let totalExtraction : Float = Float.fromInt(workerExtraction) * proficiencyModifier * techModifier;

        // Round and convert back to Nat
        return Int.abs(Float.toInt(Float.floor(totalExtraction)));
    };

    private func getGatherResourceAmount(
        town : Town.Town,
        workerCount : Nat,
        gatherResourceJob : Town.GatherResourceJob,
        locations : HashMap.HashMap<Nat, World.WorldLocation>,
    ) : Nat {
        let ?location = locations.get(gatherResourceJob.locationId) else Debug.trap("Location not found: " # Nat.toText(gatherResourceJob.locationId));

        switch (location.kind) {
            case (#unexplored(_)) Debug.trap("Location is unexplored: " # Nat.toText(gatherResourceJob.locationId));
            case (#standard(standardLocation)) {

                let calculateAmountWithEfficiency = func(
                    workerCount : Int,
                    proficiencyLevel : Nat,
                    techLevel : Nat,
                    efficiency : Float,
                ) : Nat {
                    let baseAmount = workerCount + proficiencyLevel + techLevel;

                    let amountFloat = Float.fromInt(baseAmount) * efficiency;

                    let amountInt = Float.toInt(amountFloat);
                    if (amountInt <= 1) {
                        1;
                    } else {
                        Int.abs(amountInt);
                    };
                };

                let calculateResourceExtraction = func(
                    workerCount : Nat,
                    proficiency : Nat,
                    techLevel : Nat,
                    baseRate : Nat,
                ) : Nat {
                    // Step 1: Calculate extraction based on number of workers
                    let workerExtraction : Nat = workerCount * baseRate;

                    // Step 2: Apply proficiency modifier
                    let proficiencyModifier : Float = 1 + (Float.fromInt(proficiency) * 0.1); // TODO

                    // Step 3: Apply tech level modifier
                    let techModifier : Float = 1 + (Float.fromInt(techLevel) * 0.2); // TODO

                    // Calculate total extraction
                    let totalExtraction : Float = Float.fromInt(workerExtraction) * proficiencyModifier * techModifier;

                    // Round and convert back to Nat
                    return Int.abs(Float.toInt(Float.floor(totalExtraction)));
                };

                switch (gatherResourceJob.resource) {
                    case (#wood) calculateResourceExtraction(
                        workerCount,
                        town.skills.woodCutting.proficiencyLevel,
                        town.skills.woodCutting.techLevel,
                        2,
                    );
                    case (#food) calculateResourceExtraction(
                        workerCount,
                        town.skills.farming.proficiencyLevel,
                        town.skills.farming.techLevel,
                        2,
                    );
                    case (#gold) calculateAmountWithEfficiency(
                        workerCount,
                        town.skills.mining.proficiencyLevel,
                        town.skills.mining.techLevel,
                        standardLocation.resources.gold.efficiency,
                    );
                    case (#stone) calculateAmountWithEfficiency(
                        workerCount,
                        town.skills.mining.proficiencyLevel,
                        town.skills.mining.techLevel,
                        standardLocation.resources.stone.efficiency,
                    );
                };
            };
        };

    };

    private func buildJobsWithWorkerCount(town : Town.Town) : Iter.Iter<JobWithWorkers> {
        var remainingPopulation = town.population;
        var totalQuota : Nat = 0;

        let getJobWorkerQuota = func(job : Town.Job) : Nat {
            switch (job) {
                case (#gatherResource(gatherResourceJob)) gatherResourceJob.workerQuota;
                case (#processResource(processResourceJob)) processResourceJob.workerQuota;
                case (#explore(exploreJob)) exploreJob.workerQuota;
            };
        };

        // First, calculate the total quota for all jobs in the town
        for (job in town.jobs.vals()) {
            totalQuota += getJobWorkerQuota(job);
        };

        town.jobs.vals()
        |> IterTools.enumerate(_)
        |> Iter.map<(Nat, Town.Job), JobWithWorkers>(
            _,
            func((jobId, job) : (Nat, Town.Job)) : JobWithWorkers {
                if (totalQuota == 0) {
                    // Handle the case where total quota is 0 to avoid division by zero
                    return {
                        town = town;
                        jobId = jobId;
                        job = job;
                        workers = 0;
                    };
                };

                // Calculate the proportional number of workers for this job
                let workerQuota = getJobWorkerQuota(job);
                // TODO what about rounding?
                let workerCount = (workerQuota * remainingPopulation) / totalQuota;

                // Update remaining population and total quota
                remainingPopulation -= workerCount;
                totalQuota -= workerQuota;

                {
                    town = town;
                    jobId = jobId;
                    job = job;
                    workers = workerCount;
                };
            },
        );
    };
};
