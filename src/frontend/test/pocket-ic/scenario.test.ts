import { describe, beforeEach, afterEach, it, expect, inject } from 'vitest';
import { idlFactory as leagueIdlFactory, type _SERVICE as LEAGUE_SERVICE } from '../../src/ic-agent/declarations/league';
import { idlFactory as teamsIdlFactory, type _SERVICE as TEAMS_SERVICE } from '../../src/ic-agent/declarations/teams';
import { idlFactory as playersIdlFactory, type _SERVICE as PLAYERS_SERVICE } from '../../src/ic-agent/declarations/players';
import { idlFactory as usersIdlFactor, type _SERVICE as USERS_SERVICE } from '../../src/ic-agent/declarations/users';
import { idlFactory as stadiumIdlFactory, type _SERVICE as STADIUM_SERVICE } from '../../src/ic-agent/declarations/stadium';
import { teams as teamData } from "../../src/data/TeamData";
import { players as playerData } from "../../src/data/PlayerData";
import { teamTraits as traitData } from "../../src/data/TeamTraitData";
import { resolve } from 'path';
import { Actor, PocketIc } from '@hadronous/pic';
import { Principal } from '@dfinity/principal';


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


        // Setup the canister and actor
        const leagueFixture = await pic.setupCanister<LEAGUE_SERVICE>({
            idlFactory: leagueIdlFactory,
            wasm: LEAGUE_WASM_PATH
        });

        // Save the actor and canister ID for use in tests
        leagueActor = leagueFixture.actor;
        leagueActor.setPrincipal(bdfnPrincipal);

        console.log("League cansiter id ", leagueFixture.canisterId.toString());

        pic
        const teamsFixture = await pic.setupCanister<TEAMS_SERVICE>({
            idlFactory: teamsIdlFactory,
            wasm: TEAMS_WASM_PATH
        });

        teamsActor = teamsFixture.actor;
        teamsActor.setPrincipal(bdfnPrincipal);

        console.log("Teams cansiter id ", teamsFixture.canisterId.toString());


        const playersFixture = await pic.setupCanister<PLAYERS_SERVICE>({
            idlFactory: playersIdlFactory,
            wasm: PLAYERS_WASM_PATH
        });

        playersActor = playersFixture.actor;
        playersActor.setPrincipal(bdfnPrincipal);

        console.log("Players cansiter id ", playersFixture.canisterId.toString());


        const stadiumFixture = await pic.setupCanister<STADIUM_SERVICE>({
            idlFactory: stadiumIdlFactory,
            wasm: STADIUM_WASM_PATH

        });

        stadiumActor = stadiumFixture.actor;
        stadiumActor.setPrincipal(bdfnPrincipal);

        console.log("Stadium cansiter id ", stadiumFixture.canisterId.toString());

        const usersFixture = await pic.setupCanister<USERS_SERVICE>({
            idlFactory: usersIdlFactor,
            wasm: USERS_WASM_PATH
        });

        usersActor = usersFixture.actor;
        usersActor.setPrincipal(bdfnPrincipal);

        console.log("Users cansiter id ", usersFixture.canisterId.toString());


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
    });
});

