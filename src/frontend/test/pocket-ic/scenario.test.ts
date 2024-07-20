import { describe, beforeEach, afterEach, it, expect, inject } from 'vitest';
import { init as worldInit, idlFactory as worldIdlFactory, type _SERVICE as LEAGUE_SERVICE, VoteOnScenarioResult } from '../../src/ic-agent/declarations/main';
import { init as townsInit, idlFactory as townsIdlFactory, type _SERVICE as TEAMS_SERVICE } from '../../src/ic-agent/declarations/main';
import { init as playersInit, idlFactory as playersIdlFactory, type _SERVICE as PLAYERS_SERVICE } from '../../src/ic-agent/declarations/main';
import { init as usersInit, idlFactory as usersIdlFactory, type _SERVICE as USERS_SERVICE, AddTownOwnerResult } from '../../src/ic-agent/declarations/main';
import { init as stadiumInit, idlFactory as stadiumIdlFactory, type _SERVICE as STADIUM_SERVICE } from '../../src/ic-agent/declarations/main';
import { towns as townData } from "../../src/data/TownData";
import { players as playerData } from "../../src/data/PlayerData";
import { townTraits as traitData } from "../../src/data/TownTraitData";
import { resolve } from 'path';
import { Actor, PocketIc, generateRandomIdentity } from '@hadronous/pic';
import { Principal } from '@dfinity/principal';
import { IDL } from '@dfinity/candid';


// Define the path to your canister's WASM file using __dirname
const basePath = resolve(
    __dirname,
    '..',
    '..',
    '..',
    '..',
    '.dfx',
    'local',
    'canisters'
);
export const LEAGUE_WASM_PATH = resolve(basePath, "world", 'world.wasm');
export const TEAMS_WASM_PATH = resolve(basePath, "towns", 'towns.wasm');
export const PLAYERS_WASM_PATH = resolve(basePath, "players", 'players.wasm');
export const STADIUM_WASM_PATH = resolve(basePath, "stadium", 'stadium.wasm');
export const USERS_WASM_PATH = resolve(basePath, "users", 'users.wasm');


// The `describe` function is used to group tests together
// and is completely optional.
describe('Test suite name', () => {
    // Define variables to hold our PocketIC instance, canister ID,
    // and an actor to interact with our canister.
    let pic: PocketIc;
    let worldActor: Actor<LEAGUE_SERVICE>;
    let townsActor: Actor<TEAMS_SERVICE>;
    let playersActor: Actor<PLAYERS_SERVICE>;
    let stadiumActor: Actor<STADIUM_SERVICE>;
    let usersActor: Actor<USERS_SERVICE>;

    const usersPerTown = 10;

    let towns: { userIds: Principal[] }[] = [];

    let bdfnPrincipal = Principal.fromText("zedmc-7yeiu-fmd5m-c7nun-r3unf-qap5y-drgdf-ozckp-gzuzn-wj4n4-6qe");
    const oneDayInNanos = BigInt(60 * 60 * 24 * 1_000_000_000);

    // The `beforeEach` hook runs before each test.
    //
    // This can be replaced with a `beforeAll` hook to persist canister
    // state between tests.
    beforeEach(async () => {
        // create a new PocketIC instance
        let url = inject('PIC_URL');
        pic = await PocketIc.create(url);
        pic.setTime(0);

        // Create empty canisters
        const worldCanisterId = await pic.createCanister();
        const townsCanisterId = await pic.createCanister();
        const playersCanisterId = await pic.createCanister();
        const stadiumCanisterId = await pic.createCanister();
        const usersCanisterId = await pic.createCanister();

        // Install World canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal, IDL.Principal, IDL.Principal, IDL.Principal], [usersCanisterId, townsCanisterId, playersCanisterId, stadiumCanisterId]),
            canisterId: worldCanisterId,
            wasm: LEAGUE_WASM_PATH
        })
        worldActor = await pic.createActor(worldIdlFactory, worldCanisterId);
        worldActor.setPrincipal(bdfnPrincipal);


        // Install Towns canisterq
        await pic.installCode({
            arg: IDL.encode([IDL.Principal, IDL.Principal, IDL.Principal], [worldCanisterId, usersCanisterId, playersCanisterId]),
            canisterId: townsCanisterId,
            wasm: TEAMS_WASM_PATH
        });

        townsActor = await pic.createActor(townsIdlFactory, townsCanisterId);
        townsActor.setPrincipal(bdfnPrincipal);


        // Install Players canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal, IDL.Principal], [worldCanisterId, townsCanisterId]),
            canisterId: playersCanisterId,
            wasm: PLAYERS_WASM_PATH
        });

        playersActor = await pic.createActor(playersIdlFactory, playersCanisterId);
        playersActor.setPrincipal(bdfnPrincipal);


        // Install Stadium canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal], [worldCanisterId]),
            canisterId: stadiumCanisterId,
            wasm: STADIUM_WASM_PATH
        });

        stadiumActor = await pic.createActor(stadiumIdlFactory, stadiumCanisterId);
        stadiumActor.setPrincipal(bdfnPrincipal);


        // Install Users canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal], [worldCanisterId]),
            canisterId: usersCanisterId,
            wasm: USERS_WASM_PATH
        });

        usersActor = await pic.createActor(usersIdlFactory, usersCanisterId);
        usersActor.setPrincipal(bdfnPrincipal);


        const response = await worldActor.claimBenevolentDictatorRole();

        expect(response).toEqual({ 'ok': null });

        await createPlayers();
        await createTowns();
        await createTownTraits();
    });

    let createPlayers = async function () {
        for (let i = 0; i < playerData.length; i++) {
            let player = playerData[i];
            let result = await playersActor
                .addFluff({
                    name: player.name,
                    title: player.title,
                    description: player.description,
                    likes: player.likes,
                    dislikes: player.dislikes,
                    quirks: player.quirks,
                });
            expect(result).toEqual({ ok: null });
        }
    };

    let createTowns = async function (): Promise<void> {
        for (let i = 0; i < townData.length; i++) {
            let town = townData[i];
            let result = await worldActor.createTown(town);
            expect(result).toEqual({ 'ok': BigInt(i) });

            let userIds: Principal[] = [];
            for (let j = 0; j < usersPerTown; j++) {
                let userIdentity = generateRandomIdentity();
                let userResult = await usersActor.addTownOwner({
                    townId: BigInt(i),
                    userId: useruser.id,
                    votingPower: BigInt(1)
                });
                expect(userResult).toEqual({ 'ok': null });
                userIds.push(useruser.id);
            }
            towns.push({ userIds });
        }
    };


    let createTownTraits = async function () {
        for (let i = 0; i < traitData.length; i++) {
            let trait = traitData[i];
            let result = await townsActor.createTownTrait(trait);
            expect(result).toEqual({ 'ok': null });
        }
    };

    // The `afterEach` hook runs after each test.
    //
    // This should be replaced with an `afterAll` hook if you use
    // a `beforeAll` hook instead of a `beforeEach` hook.
    afterEach(async () => {
        // tear down the PocketIC instance
        await pic?.tearDown();
    });

    it('Scenario: No World Effect', async () => {

        const scenarioResult = await worldActor.addScenario({
            title: "Scenario No World Effect",
            description: "Scenario No World Effect",
            startTime: [],
            endTime: BigInt(oneDayInNanos),
            undecidedEffect: {
                entropy: {
                    delta: BigInt(1),
                    target: {
                        contextual: null
                    }
                }
            },
            kind: {
                noWorldEffect: {
                    options: [
                        {
                            title: "Option 1",
                            description: "Option 1",
                            traitRequirements: [],
                            currencyCost: BigInt(0),
                            townEffect: {
                                currency: {
                                    target: {
                                        contextual: null
                                    },
                                    value: {
                                        flat: BigInt(1)
                                    }
                                }
                            }
                        },
                        {
                            title: "Option 2",
                            description: "Option 2",
                            traitRequirements: [],
                            currencyCost: BigInt(0),
                            townEffect: {
                                currency: {
                                    target: {
                                        contextual: null
                                    },
                                    value: {
                                        flat: BigInt(1)
                                    }
                                }
                            }

                        }
                    ]
                }
            }
        });

        expect(scenarioResult).toEqual({ 'ok': null });


        let getScenarioResult = await worldActor.getScenario(BigInt(0));

        expect(getScenarioResult).toEqual({
            "ok": {
                "description": "Scenario No World Effect",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noWorldEffect": {
                        "options": [
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 1",
                                "traitRequirements": []
                            },
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 2",
                                "traitRequirements": []
                            }
                        ]
                    }
                },
                "startTime": 0n,
                "state": {
                    "inProgress": null
                },
                "title": "Scenario No World Effect",
                "undecidedEffect": {
                    "entropy": {
                        "delta": 1n,
                        "target": {
                            "contextual": null
                        }
                    }
                }
            }
        });


        let hasOneOk = false;
        for (let i = 0; i < towns.length; i++) {
            let town = towns[i];
            for (let j = 0; j < town.userIds.length; j++) {
                let userId = town.userIds[j];
                worldActor.setPrincipal(userId);
                let voteResult = await worldActor.voteOnScenario({ scenarioId: BigInt(0), value: { 'id': BigInt(0) } });

                // Make sure its ok, or that the voting is not open due to the scenario ending from majority votes
                expect(voteResult).toSatisfy<VoteOnScenarioResult>((r) => {
                    if ('ok' in r) {
                        hasOneOk = true;
                        return true;
                    }
                    return hasOneOk && 'err' in r && 'votingNotOpen' in r.err;
                });

                let getVoteResult = await worldActor.getScenarioVote({ scenarioId: BigInt(0) });

                expect(getVoteResult).toEqual({
                    "ok": {
                        "townId": BigInt(i),
                        "townOptions": {
                            'discrete': [
                                {
                                    "currentVotingPower": BigInt(j + 1),
                                    "description": "Option 1",
                                    "currencyCost": 0n,
                                    "id": 0n,
                                    "title": "Option 1",
                                    "traitRequirements": [],
                                },
                                {
                                    "currentVotingPower": 0n,
                                    "description": "Option 2",
                                    "currencyCost": 0n,
                                    "id": 1n,
                                    "title": "Option 2",
                                    "traitRequirements": [],
                                }
                            ]
                        },
                        "townVotingPower": BigInt(usersPerTown),
                        "votingPower": BigInt(1),
                        "value": [{ id: BigInt(0) }]
                    }
                });
            };
        }
        worldActor.setPrincipal(bdfnPrincipal);

        await pic.advanceTime(Number(oneDayInNanos) / 1_000_000);
        await pic.tick(3);

        let getScenarioResult2 = await worldActor.getScenario(BigInt(0));

        expect(getScenarioResult2).toEqual({
            "ok": {
                "description": "Scenario No World Effect",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noWorldEffect": {
                        "options": [
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 1",
                                "traitRequirements": []
                            },
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 2",
                                "traitRequirements": []
                            }
                        ]
                    }
                },
                "startTime": 0n,
                "state": {
                    "resolved": {
                        "scenarioOutcome": { "noWorldEffect": null },
                        "options": {
                            "discrete": [
                                {
                                    "id": 0n,
                                    "title": "Option 1",
                                    "townEffect": {
                                        "currency": {
                                            "value": { "flat": 1n },
                                            "target": { "contextual": null }
                                        }
                                    },
                                    "seenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "description": "Option 1",
                                    "traitRequirements": [],
                                    "chosenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "currencyCost": 0n
                                },
                                {
                                    "id": 1n,
                                    "title": "Option 2",
                                    "townEffect": {
                                        "currency": {
                                            "value": { "flat": 1n },
                                            "target": { "contextual": null }
                                        }
                                    },
                                    "seenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "description": "Option 2",
                                    "traitRequirements": [],
                                    "chosenByTownIds": [],
                                    "currencyCost": 0n
                                }
                            ]
                        },
                        "effectOutcomes": [
                            { "currency": { "townId": 0n, "delta": 1n } },
                            { "currency": { "townId": 1n, "delta": 1n } },
                            { "currency": { "townId": 2n, "delta": 1n } },
                            { "currency": { "townId": 3n, "delta": 1n } },
                            { "currency": { "townId": 4n, "delta": 1n } },
                            { "currency": { "townId": 5n, "delta": 1n } }
                        ]
                    }
                },
                "title": "Scenario No World Effect",
                "undecidedEffect": {
                    "entropy": {
                        "delta": 1n,
                        "target": {
                            "contextual": null
                        }
                    }
                }
            }
        });
    });

    it('Scenario: Lottery', async () => {

        const scenarioResult = await worldActor.addScenario({
            title: "Lottery Scenario",
            description: "Lottery Scenario",
            startTime: [],
            endTime: BigInt(oneDayInNanos),
            undecidedEffect: {
                entropy: {
                    delta: BigInt(1),
                    target: {
                        contextual: null
                    }
                }
            },
            kind: {
                lottery: {
                    minBid: BigInt(0),
                    prize: {
                        allOf: [
                            {
                                currency: {
                                    target: {
                                        contextual: null
                                    },
                                    value: {
                                        flat: BigInt(1)
                                    }
                                }
                            },
                            {
                                entropy: {
                                    target: {
                                        contextual: null
                                    },
                                    delta: BigInt(-1)
                                }
                            }
                        ]
                    }
                }
            }
        });

        expect(scenarioResult).toEqual({ 'ok': null });


        let getScenarioResult = await worldActor.getScenario(BigInt(0));

        expect(getScenarioResult).toEqual({
            "ok": {
                "description": "Lottery Scenario",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noWorldEffect": {
                        "options": [
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 1",
                                "traitRequirements": []
                            },
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 2",
                                "traitRequirements": []
                            }
                        ]
                    }
                },
                "startTime": 0n,
                "state": {
                    "inProgress": null
                },
                "title": "Lottery Scenario",
                "undecidedEffect": {
                    "entropy": {
                        "delta": 1n,
                        "target": {
                            "contextual": null
                        }
                    }
                }
            }
        });

        let hasOneOk = false;
        for (let i = 0; i < towns.length; i++) {
            let town = towns[i];
            for (let j = 0; j < town.userIds.length; j++) {
                let userId = town.userIds[j];
                worldActor.setPrincipal(userId);
                let voteResult = await worldActor.voteOnScenario({ scenarioId: BigInt(0), value: { 'id': BigInt(0) } });

                // Make sure its ok, or that the voting is not open due to the scenario ending from majority votes
                expect(voteResult).toSatisfy<VoteOnScenarioResult>((r) => {
                    if ('ok' in r) {
                        hasOneOk = true;
                        return true;
                    }
                    return hasOneOk && 'err' in r && 'votingNotOpen' in r.err;
                });

                let getVoteResult = await worldActor.getScenarioVote({ scenarioId: BigInt(0) });

                expect(getVoteResult).toEqual({
                    "ok": {
                        "townId": BigInt(i),
                        "townOptions": {
                            'discrete': [
                                {
                                    "currentVotingPower": BigInt(j + 1),
                                    "description": "Option 1",
                                    "currencyCost": 0n,
                                    "id": 0n,
                                    "title": "Option 1",
                                    "traitRequirements": [],
                                },
                                {
                                    "currentVotingPower": 0n,
                                    "description": "Option 2",
                                    "currencyCost": 0n,
                                    "id": 1n,
                                    "title": "Option 2",
                                    "traitRequirements": [],
                                }
                            ]
                        },
                        "townVotingPower": BigInt(usersPerTown),
                        "votingPower": BigInt(1),
                        "value": [{ id: BigInt(0) }]
                    }
                });
            };
        }
        worldActor.setPrincipal(bdfnPrincipal);

        await pic.advanceTime(60 * 60 * 24 * 1_000);
        await pic.tick(1000);

        let getScenarioResult2 = await worldActor.getScenario(BigInt(0));

        expect(getScenarioResult2).toEqual({
            "ok": {
                "description": "Lottery Scenario",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noWorldEffect": {
                        "options": [
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 1",
                                "traitRequirements": []
                            },
                            {
                                "allowedTownIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "currencyCost": 0n,
                                "townEffect": {
                                    "currency": {
                                        "target": {
                                            "contextual": null
                                        },
                                        "value": {
                                            "flat": 1n
                                        }
                                    }
                                },
                                "title": "Option 2",
                                "traitRequirements": []
                            }
                        ]
                    }
                },
                "startTime": 0n,
                "state": {
                    "resolved": {
                        "scenarioOutcome": { "noWorldEffect": null },
                        "options": {
                            "discrete": [
                                {
                                    "id": 0n,
                                    "title": "Option 1",
                                    "townEffect": {
                                        "currency": {
                                            "value": { "flat": 1n },
                                            "target": { "contextual": null }
                                        }
                                    },
                                    "seenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "description": "Option 1",
                                    "traitRequirements": [],
                                    "chosenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "currencyCost": 0n
                                },
                                {
                                    "id": 1n,
                                    "title": "Option 2",
                                    "townEffect": {
                                        "currency": {
                                            "value": { "flat": 1n },
                                            "target": { "contextual": null }
                                        }
                                    },
                                    "seenByTownIds": [0n, 1n, 2n, 3n, 4n, 5n],
                                    "description": "Option 2",
                                    "traitRequirements": [],
                                    "chosenByTownIds": [],
                                    "currencyCost": 0n
                                }
                            ]
                        },
                        "effectOutcomes": [
                            { "currency": { "townId": 0n, "delta": 1n } },
                            { "currency": { "townId": 1n, "delta": 1n } },
                            { "currency": { "townId": 2n, "delta": 1n } },
                            { "currency": { "townId": 3n, "delta": 1n } },
                            { "currency": { "townId": 4n, "delta": 1n } },
                            { "currency": { "townId": 5n, "delta": 1n } }
                        ]
                    }
                },
                "title": "Lottery Scenario",
                "undecidedEffect": {
                    "entropy": {
                        "delta": 1n,
                        "target": {
                            "contextual": null
                        }
                    }
                }
            }
        });
    });
});

