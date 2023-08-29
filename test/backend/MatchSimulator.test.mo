import MatchSimulator "../../src/backend/stadium/MatchSimulator";
import { test } "mo:test";
import Random "mo:base/Random";
import Trie "mo:base/Trie";
import Stadium "../../src/backend/Stadium";
import Hash "mo:base/Hash";
import Player "../../src/backend/Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";

type FieldPosition = Player.FieldPosition;
type PlayerState = Stadium.PlayerState;

func fromArray<TKey, TValue>(array : [(TKey, TValue)], hashKey : (TKey) -> Hash.Hash, equal : (TKey, TKey) -> Bool) : Trie.Trie<TKey, TValue> {
    var trie = Trie.empty<TKey, TValue>();
    for ((key, value) in array.vals()) {
        let k : Trie.Key<TKey> = {
            key = key;
            hash = hashKey(key);
        };
        let (newTrie, _) = Trie.put<TKey, TValue>(trie, k, equal, value);
        trie := newTrie;
    };
    return trie;
};

test(
    "MatchSimulator",
    func() {
        let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
        let random = Random.Finite(seed);
        let state : Stadium.InProgressMatchState = {
            offenseTeamId = #team1;
            team1 = {
                battingOrder = [
                    #rightField,
                    #centerField,
                    #leftField,
                    #shortStop,
                    #thirdBase,
                    #secondBase,
                    #firstBase,
                    #catcher,
                    #pitcher,
                ];
                currentBatter = #rightField;
                positions = fromArray<FieldPosition, Nat32>(
                    [
                        (#rightField, 0),
                        (#centerField, 1),
                        (#leftField, 2),
                        (#shortStop, 3),
                        (#thirdBase, 4),
                        (#secondBase, 5),
                        (#firstBase, 6),
                        (#catcher, 7),
                        (#pitcher, 8),
                    ],
                    Player.hashFieldPosition,
                    Player.equalFieldPosition,
                );
                score = 0;
                substitutes = [];
            };
            team2 = {
                battingOrder = [
                    #pitcher,
                    #catcher,
                    #firstBase,
                    #secondBase,
                    #thirdBase,
                    #shortStop,
                    #leftField,
                    #centerField,
                    #rightField,
                ];
                currentBatter = #pitcher;
                positions = fromArray<FieldPosition, Nat32>(
                    [
                        (#rightField, 9),
                        (#centerField, 10),
                        (#leftField, 11),
                        (#shortStop, 12),
                        (#thirdBase, 13),
                        (#secondBase, 14),
                        (#firstBase, 15),
                        (#catcher, 16),
                        (#pitcher, 17),
                    ],
                    Player.hashFieldPosition,
                    Player.equalFieldPosition,
                );
                score = 0;
                substitutes = [];
            };
            events = [];
            players = fromArray<Nat32, PlayerState>(
                [
                    (
                        0,
                        {
                            name = "Player 0";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #rightField;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        1,
                        {
                            name = "Player 1";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #centerField;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        2,
                        {
                            name = "Player 2";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #leftField;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        3,
                        {
                            name = "Player 3";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #shortStop;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        4,
                        {
                            name = "Player 4";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #thirdBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        5,
                        {
                            name = "Player 5";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #secondBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        6,
                        {
                            name = "Player 6";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #firstBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        7,
                        {
                            name = "Player 7";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #catcher;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        8,
                        {
                            name = "Player 8";
                            condition = #ok;
                            energy = 100;
                            teamId = #team1;
                            preferredPosition = #pitcher;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        9,
                        {
                            name = "Player 9";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #pitcher;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        10,
                        {
                            name = "Player 10";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #catcher;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        11,
                        {
                            name = "Player 11";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #firstBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        12,
                        {
                            name = "Player 12";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #secondBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        13,
                        {
                            name = "Player 13";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #thirdBase;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        14,
                        {
                            name = "Player 14";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #shortStop;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        15,
                        {
                            name = "Player 15";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #leftField;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                    (
                        16,
                        {
                            name = "Player 16";
                            condition = #ok;
                            energy = 100;
                            teamId = #team2;
                            preferredPosition = #centerField;
                            skills = {
                                batting = 0;
                                throwing = 0;
                                catching = 0;
                            };
                        },
                    ),
                ],
                func(v : Nat32) : Nat32 = v,
                Nat32.equal,
            );
            bases = Trie.empty();
            round = 0;
            outs = 0;
            strikes = 0;
        };
        let #inProgress(newState) = MatchSimulator.tick(state, random) else Debug.trap("MatchSimulator.tick failed");
        Debug.print(debug_show (newState.events));
    },
);
