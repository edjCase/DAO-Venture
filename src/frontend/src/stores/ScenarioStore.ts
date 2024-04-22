import { writable } from "svelte/store";
import { Scenario, ScenarioVote } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";
import { Subscriber } from "svelte/motion";
import { nanosecondsToDate } from "../utils/DateUtils";


export const scenarioStore = (() => {
    const { subscribe, set, update } = writable<Scenario[]>([]);
    let endTimers: NodeJS.Timeout[] = [];
    const votesWritable = writable<Record<number, ScenarioVote>>({});

    const refetch = async () => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.getScenarios();
        if ('ok' in result) {
            set(result.ok);
            refreshEndTimers(result.ok);
        } else {
            console.log("Error getting scenarios", result);
        }
    };

    const refetchById = async (scenarioId: bigint) => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.getScenario(scenarioId);
        if ('ok' in result) {
            update(scenarios => {
                const index = scenarios.findIndex(scenario => scenario.id === scenarioId);
                if (index !== -1) {
                    scenarios[index] = result.ok;
                } else {
                    scenarios.push(result.ok);
                }
                refreshEndTimers(scenarios);
                return scenarios;
            });
        } else {
            console.log("Error getting scenario", result);
        }
    };


    const fetchVote = async (scenarioId: bigint) => {
        let leagueAgent = await leagueAgentFactory();
        const request = { scenarioId };
        let result = await leagueAgent.getScenarioVote(request);
        if ('ok' in result) {
            votesWritable.update(votes => {
                votes[Number(scenarioId)] = result.ok;
                return votes;
            });
        } else {
            console.log("Error getting vote for scenario " + scenarioId, result);
        }
    };

    const refetchVotes = (scenarioIds: bigint[]) => {
        for (let scenarioId of scenarioIds) {
            fetchVote(scenarioId);
        }
    };

    const subscribeVotes = async (run: Subscriber<Record<string, ScenarioVote>>) => {
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
        subscribeVotes
    };
})();


