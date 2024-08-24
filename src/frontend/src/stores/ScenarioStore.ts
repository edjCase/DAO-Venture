import { writable, derived } from 'svelte/store';
import { type Scenario } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { currentGameStore } from './CurrentGameStore';

export const scenarioStore = (() => {
    const { set, update } = writable<Scenario[]>([]);

    // Create a derived store that updates scenarios when currentGameStore changes
    const derivedScenarioStore = derived<typeof currentGameStore, Scenario[]>(
        currentGameStore,
        ($currentGame, set) => {
            if ($currentGame) {
                mainAgentFactory().then(mainAgent => {
                    mainAgent.getScenarios({ gameId: $currentGame.id })
                        .then(result => {
                            if ('ok' in result) {
                                set(result.ok);
                            } else {
                                console.error("Failed to get scenarios", result.err);
                                set([]);
                            }
                        });
                });
            } else {
                set([]);
            }
        },
        [] // Initial value
    );

    return {
        subscribe: derivedScenarioStore.subscribe,
        refetchById: async (gameId: bigint, id: bigint) => {
            const mainAgent = await mainAgentFactory();
            const result = await mainAgent.getScenario({
                gameId: gameId,
                scenarioId: id
            });
            if ('ok' in result) {
                update((scenarios) => {
                    const index = scenarios.findIndex((s) => s.id === id);
                    if (index !== -1) {
                        scenarios[index] = result.ok;
                    }
                    return scenarios;
                });
            } else {
                console.error("Failed to get scenario " + id, result.err)
            }
        },
        refetchByGameId: async (gameId: bigint) => {
            const mainAgent = await mainAgentFactory();
            const result = await mainAgent.getScenarios({
                gameId
            });
            if ('ok' in result) {
                set(result.ok);
            } else {
                console.error("Failed to get scenarios", result.err);
            }
        }
    };
})();