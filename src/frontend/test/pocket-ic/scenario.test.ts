import { describe, beforeEach, afterEach, it, expect, inject } from 'vitest';
import { idlFactory, type _SERVICE } from '../../src/ic-agent/declarations/league';
import { leagueAgentFactory } from '../../src/ic-agent/League';
import { playersAgentFactory } from '../../src/ic-agent/Players';
import { CreatePlayerFluffResult } from '../../src/ic-agent/declarations/players';
import { teamsAgentFactory } from '../../src/ic-agent/Teams';
import { teams as teamData } from "../../src/data/TeamData";
import { players as playerData } from "../../src/data/PlayerData";
import { teamTraits as traitData } from "../../src/data/TeamTraitData";
import { resolve } from 'path';
import { Actor, PocketIc } from '@hadronous/pic';


// Define the path to your canister's WASM file using __dirname
export const WASM_PATH = resolve(
    __dirname,
    '..',
    '..',
    '..',
    '..',
    '.dfx',
    'local',
    'canisters',
    'league',
    'league.wasm',
);


// The `describe` function is used to group tests together
// and is completely optional.
describe('Test suite name', () => {
    // Define variables to hold our PocketIC instance, canister ID,
    // and an actor to interact with our canister.
    let pic: PocketIc;
    let actor: Actor<_SERVICE>;

    // The `beforeEach` hook runs before each test.
    //
    // This can be replaced with a `beforeAll` hook to persist canister
    // state between tests.
    beforeEach(async () => {
        // create a new PocketIC instance
        pic = await PocketIc.create(inject('PIC_URL'));

        // Setup the canister and actor
        const fixture = await pic.setupCanister<_SERVICE>({
            idlFactory,
            wasm: WASM_PATH,
        });

        // Save the actor and canister ID for use in tests
        actor = fixture.actor;


        const response = await actor.claimBenevolentDictatorRole();

        expect(response).toEqual({ 'ok': null });

        await createTeamTraits();
        await createTeams();
        await createPlayers();
    });

    // The `afterEach` hook runs after each test.
    //
    // This should be replaced with an `afterAll` hook if you use
    // a `beforeAll` hook instead of a `beforeEach` hook.
    afterEach(async () => {
        // tear down the PocketIC instance
        await pic.tearDown();
    });

    // The `it` function is used to define individual tests
    it('adds a scenario', async () => {

        const scenarioResult = await actor.addScenario({
            title: "Test Scenario",
            description: "A test scenario",
            startTime: [],
            endTime: BigInt(0),
            undecidedEffect: {
                entropy: {
                    delta: BigInt(1),
                    target: {
                        contextual: null
                    }
                }
            },
            kind: {
                noLeagueEffect: {
                    options: [{
                        title: "Option 1",
                        description: "Option 1",
                        traitRequirements: [],
                        energyCost: BigInt(0),
                        teamEffect: {
                            energy: {
                                target: {
                                    contextual: null
                                },
                                value: {
                                    flat: BigInt(1)
                                }
                            }
                        }
                    }]
                }
            }
        });

        expect(scenarioResult).toEqual({ 'ok': BigInt(0) });
    });
});


let createTeams = async function (): Promise<void> {
    let leagueAgent = await leagueAgentFactory();
    let promises: Promise<void>[] = [];
    for (let i = 0; i < teamData.length; i++) {
        let team = teamData[i];
        let promise = leagueAgent.createTeam(team).then(async (result) => {
            if ("ok" in result) {
                let teamId = result.ok;
                console.log("Created team: ", teamId);
            } else {
                console.log("Failed to make team: ", result);
            }
        });
        promises.push(promise);
    }
    await Promise.all(promises);
};

let createPlayers = async function () {
    let playersAgent = await playersAgentFactory();
    let promises: Promise<void>[] = [];
    // loop over count
    for (let player of playerData) {
        let promise = playersAgent
            .addFluff({
                name: player.name,
                title: player.title,
                description: player.description,
                likes: player.likes,
                dislikes: player.dislikes,
                quirks: player.quirks,
            })
            .then((result: CreatePlayerFluffResult) => {
                if ("ok" in result) {
                    console.log("Added player fluff: ", player.name);
                } else {
                    console.error("Failed to add player fluff: ", player.name, result);
                }
            });
        promises.push(promise);
    }
    await Promise.all(promises);
};

let createTeamTraits = async function () {
    let teamsAgent = await teamsAgentFactory();
    let promises: Promise<void>[] = [];
    for (let trait of traitData) {
        let promise = teamsAgent.createTeamTrait(trait).then(async (result) => {
            if ("ok" in result) {
                let traitId = result.ok;
                console.log("Created trait: ", traitId);
            } else {
                console.log("Failed to make trait: ", result);
            }
        });
        promises.push(promise);
    }
    await Promise.all(promises);
};