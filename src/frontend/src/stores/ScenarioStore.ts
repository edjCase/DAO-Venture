import { writable } from "svelte/store";
import { Scenario, VotingData } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { Subscriber } from "svelte/motion";
import { nanosecondsToDate } from "../utils/DateUtils";


export const scenarioStore = (() => {
    const { subscribe, set, update } = writable<Scenario[] | undefined>();
    let endTimers: NodeJS.Timeout[] = [];
    const votesWritable = writable<Record<number, VotingData>>({});

    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getAllScenarios({ count: 999n, offset: 0n }); // TODO paging
        set(result.data);
        refreshEndTimers(result.data);
    };

    const refetchById = async (scenarioId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getScenario(scenarioId);
        if ('ok' in result) {
            let scenario = result.ok;
            update(scenarios => {
                if (!scenarios) {
                    scenarios = [scenario];
                } else {
                    const index = scenarios.findIndex(s => s.id === scenarioId);
                    if (index !== -1) {
                        scenarios[index] = scenario;
                    } else {
                        scenarios.push(scenario);
                    }
                }
                refreshEndTimers(scenarios);
                return scenarios;
            });
        } else {
            console.log("Error getting scenario", result);
        }
    };


    const fetchVote = async (scenarioId: bigint) => {
        let mainAgent = await mainAgentFactory();
        const request = { scenarioId };
        let result = await mainAgent.getScenarioVote(request);
        if ('ok' in result) {
            let scenario = result.ok;
            votesWritable.update(votes => {
                votes[Number(scenarioId)] = scenario;
                return votes;
            });
        } else {
            console.log("Error getting vote for scenario " + scenarioId, result);
        }
    };

    const refetchVotes = async (scenarioIds: bigint[]) => {
        for (let scenarioId of scenarioIds) {
            fetchVote(scenarioId);
        }
    };

    const subscribeVotingData = async (run: Subscriber<Record<string, VotingData>>) => {
        return votesWritable.subscribe(run);
    };


    const refreshEndTimers = async (scenarios: Scenario[]) => {
        endTimers.forEach(timer => clearTimeout(timer));
        endTimers = [];
        scenarios
            .filter(s => 'inProgress' in s.state)
            .forEach((scenario) => {
                const endTime = nanosecondsToDate(scenario.endTime);
                const currentTime = new Date();

                let millisTill = endTime.getTime() - currentTime.getTime() + 1000; // Delay 1 second to ensure the scenario is over
                if (millisTill < 500) {
                    millisTill = 500; // Minimum delay of 500ms
                }
                const timer = setTimeout(() => {
                    scenarioStore.refetchById(scenario.id);
                }, millisTill);
                endTimers.push(timer);
            });
    };

    refetch();

    return {
        refetch,
        refetchById,
        subscribe,
        refetchVotes,
        subscribeVotingData: subscribeVotingData
    };
})();


