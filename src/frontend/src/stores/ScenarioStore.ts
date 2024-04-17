import { writable } from "svelte/store";
import { Scenario } from "../ic-agent/declarations/league";
import { leagueAgentFactory } from "../ic-agent/League";
import { Subscriber } from "svelte/motion";
import { teamsAgentFactory } from "../ic-agent/Teams";
import { ScenarioVote } from "../ic-agent/declarations/teams";


export const scenarioStore = (() => {
    const { subscribe, set } = writable<Scenario[]>([]);
    const votesWritable = writable<Record<number, ScenarioVote>>({});

    const refetch = async () => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.getScenarios();
        if ('ok' in result) {
            set(result.ok);
        } else {
            console.log("Error getting scenarios", result);
        }
    };
    const fetchVote = async (scenarioId: bigint) => {

        let teamsAgent = await teamsAgentFactory();
        const request = { scenarioId };
        let result = await teamsAgent.getScenarioVote(request);
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

    refetch();

    return {
        refetch,
        subscribe,
        refetchVotes,
        subscribeVotes
    };
})();