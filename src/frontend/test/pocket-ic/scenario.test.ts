import { describe, beforeEach, afterEach, it, expect, inject } from 'vitest';
import { init as leagueInit, idlFactory as leagueIdlFactory, type _SERVICE as LEAGUE_SERVICE, VoteOnScenarioResult } from '../../src/ic-agent/declarations/league';
import { init as teamsInit, idlFactory as teamsIdlFactory, type _SERVICE as TEAMS_SERVICE } from '../../src/ic-agent/declarations/teams';
import { init as playersInit, idlFactory as playersIdlFactory, type _SERVICE as PLAYERS_SERVICE } from '../../src/ic-agent/declarations/players';
import { init as usersInit, idlFactory as usersIdlFactory, type _SERVICE as USERS_SERVICE, AddTeamOwnerResult } from '../../src/ic-agent/declarations/users';
import { init as stadiumInit, idlFactory as stadiumIdlFactory, type _SERVICE as STADIUM_SERVICE } from '../../src/ic-agent/declarations/stadium';
import { teams as teamData } from "../../src/data/TeamData";
import { players as playerData } from "../../src/data/PlayerData";
import { teamTraits as traitData } from "../../src/data/TeamTraitData";
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
export const LEAGUE_WASM_PATH = resolve(basePath, "league", 'league.wasm');
export const TEAMS_WASM_PATH = resolve(basePath, "teams", 'teams.wasm');
export const PLAYERS_WASM_PATH = resolve(basePath, "players", 'players.wasm');
export const STADIUM_WASM_PATH = resolve(basePath, "stadium", 'stadium.wasm');
export const USERS_WASM_PATH = resolve(basePath, "users", 'users.wasm');


// The `describe` function is used to group tests together
// and is completely optional.
describe('Test suite name', () => {
    // Define variables to hold our PocketIC instance, canister ID,
    // and an actor to interact with our canister.
    let pic: PocketIc;
    let leagueActor: Actor<LEAGUE_SERVICE>;
    let teamsActor: Actor<TEAMS_SERVICE>;
    let playersActor: Actor<PLAYERS_SERVICE>;
    let stadiumActor: Actor<STADIUM_SERVICE>;
    let usersActor: Actor<USERS_SERVICE>;

    const usersPerTeam = 10;

    let teams: { userIds: Principal[] }[] = [];

    let bdfnPrincipal = Principal.fromText("zedmc-7yeiu-fmd5m-c7nun-r3unf-qap5y-drgdf-ozckp-gzuzn-wj4n4-6qe");
    const oneDayInNanos = BigInt(60 * 60 * 24 * 1_000_000_000);

    // The `beforeEach` hook runs before each test.
    //
    // This can be replaced with a `beforeAll` hook to persist canister
    // state between tests.
    beforeEach(async () => {
        // create a new PocketIC instance
        let url = inject('PIC_URL');
        pic = await PocketIc.create(url, {
            application: 1
        });
        pic.setTime(0);

        // Create empty canisters
        const leagueCanisterId = await pic.createCanister();
        const teamsCanisterId = await pic.createCanister();
        const playersCanisterId = await pic.createCanister();
        const stadiumCanisterId = await pic.createCanister();
        const usersCanisterId = await pic.createCanister();

        // Install League canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal, IDL.Principal, IDL.Principal, IDL.Principal], [usersCanisterId, teamsCanisterId, playersCanisterId, stadiumCanisterId]),
            canisterId: leagueCanisterId,
            wasm: LEAGUE_WASM_PATH
        })
        leagueActor = await pic.createActor(leagueIdlFactory, leagueCanisterId);
        leagueActor.setPrincipal(bdfnPrincipal);


        // Install Teams canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal, IDL.Principal], [leagueCanisterId, usersCanisterId]),
            canisterId: teamsCanisterId,
            wasm: TEAMS_WASM_PATH
        });

        teamsActor = await pic.createActor(teamsIdlFactory, teamsCanisterId);
        teamsActor.setPrincipal(bdfnPrincipal);


        // Install Players canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal], [leagueCanisterId]),
            canisterId: playersCanisterId,
            wasm: PLAYERS_WASM_PATH
        });

        playersActor = await pic.createActor(playersIdlFactory, playersCanisterId);
        playersActor.setPrincipal(bdfnPrincipal);


        // Install Stadium canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal], [leagueCanisterId]),
            canisterId: stadiumCanisterId,
            wasm: STADIUM_WASM_PATH
        });

        stadiumActor = await pic.createActor(stadiumIdlFactory, stadiumCanisterId);
        stadiumActor.setPrincipal(bdfnPrincipal);


        // Install Users canister
        await pic.installCode({
            arg: IDL.encode([IDL.Principal], [leagueCanisterId]),
            canisterId: usersCanisterId,
            wasm: USERS_WASM_PATH
        });

        usersActor = await pic.createActor(usersIdlFactory, usersCanisterId);
        usersActor.setPrincipal(bdfnPrincipal);


        const response = await leagueActor.claimBenevolentDictatorRole();

        expect(response).toEqual({ 'ok': null });

        await createPlayers();
        await createTeams();
        await createTeamTraits();
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

    let createTeams = async function (): Promise<void> {
        for (let i = 0; i < teamData.length; i++) {
            let team = teamData[i];
            let result = await leagueActor.createTeam(team);
            expect(result).toEqual({ 'ok': BigInt(i) });

            let userIds: Principal[] = [];
            for (let j = 0; j < usersPerTeam; j++) {
                let userIdentity = generateRandomIdentity();
                let userResult = await usersActor.addTeamOwner({
                    teamId: BigInt(i),
                    userId: userIdentity.getPrincipal(),
                    votingPower: BigInt(1)
                });
                expect(userResult).toEqual({ 'ok': null });
                userIds.push(userIdentity.getPrincipal());
            }
            teams.push({ userIds });
        }
    };


    let createTeamTraits = async function () {
        for (let i = 0; i < traitData.length; i++) {
            let trait = traitData[i];
            let result = await teamsActor.createTeamTrait(trait);
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

    // The `it` function is used to define individual tests
    it('adds a scenario', async () => {

        const scenarioResult = await leagueActor.addScenario({
            title: "Test Scenario",
            description: "A test scenario",
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
                noLeagueEffect: {
                    options: [
                        {
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
                        },
                        {
                            title: "Option 2",
                            description: "Option 2",
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

                        }
                    ]
                }
            }
        });

        expect(scenarioResult).toEqual({ 'ok': null });


        let getScenarioResult = await leagueActor.getScenario(BigInt(0));

        expect(getScenarioResult).toEqual({
            "ok": {
                "description": "A test scenario",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noLeagueEffect": {
                        "options": [
                            {
                                "allowedTeamIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "energyCost": 0n,
                                "teamEffect": {
                                    "energy": {
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
                                "allowedTeamIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "energyCost": 0n,
                                "teamEffect": {
                                    "energy": {
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
                "title": "Test Scenario",
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
        for (let i = 0; i < teams.length; i++) {
            let team = teams[i];
            for (let j = 0; j < team.userIds.length; j++) {
                let userId = team.userIds[j];
                leagueActor.setPrincipal(userId);
                let voteResult = await leagueActor.voteOnScenario({ scenarioId: BigInt(0), value: { 'id': BigInt(0) } });

                // Make sure its ok, or that the voting is not open due to the scenario ending from majority votes
                expect(voteResult).toSatisfy<VoteOnScenarioResult>((r) => {
                    if ('ok' in r) {
                        hasOneOk = true;
                        return true;
                    }
                    return hasOneOk && 'err' in r && 'votingNotOpen' in r.err;
                });

                let getVoteResult = await leagueActor.getScenarioVote({ scenarioId: BigInt(0) });

                expect(getVoteResult).toEqual({
                    "ok": {
                        "teamId": BigInt(i),
                        "teamOptions": {
                            'discrete': [
                                {
                                    "currentVotingPower": BigInt(j + 1),
                                    "description": "Option 1",
                                    "energyCost": 0n,
                                    "id": 0n,
                                    "title": "Option 1",
                                    "traitRequirements": [],
                                },
                                {
                                    "currentVotingPower": 0n,
                                    "description": "Option 2",
                                    "energyCost": 0n,
                                    "id": 1n,
                                    "title": "Option 2",
                                    "traitRequirements": [],
                                }
                            ]
                        },
                        "teamVotingPower": BigInt(usersPerTeam),
                        "votingPower": BigInt(1),
                        "value": [{ id: BigInt(0) }]
                    }
                });
            };
        }
        leagueActor.setPrincipal(bdfnPrincipal);

        pic.advanceTime(60 * 60 * 24 * 1_000_000_000);
        pic.tick(1000);
        pic.advanceTime(60 * 60 * 24 * 1_000_000_000);

        let getScenarioResult2 = await leagueActor.getScenario(BigInt(0));

        expect(getScenarioResult2).toEqual({
            "ok": {
                "description": "A test scenario",
                "endTime": 86400000000000n,
                "id": 0n,
                "kind": {
                    "noLeagueEffect": {
                        "options": [
                            {
                                "allowedTeamIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 1",
                                "energyCost": 0n,
                                "teamEffect": {
                                    "energy": {
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
                                "allowedTeamIds": [
                                    0n,
                                    1n,
                                    2n,
                                    3n,
                                    4n,
                                    5n
                                ],
                                "description": "Option 2",
                                "energyCost": 0n,
                                "teamEffect": {
                                    "energy": {
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
                    "notStarted": null
                },
                "title": "Test Scenario",
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

