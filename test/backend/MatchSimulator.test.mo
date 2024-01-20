import MatchSimulator "../../src/backend/stadium/MatchSimulator";
import { test } "mo:test";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import IterTools "mo:itertools/Iter";
import StadiumTypes "../../src/backend/stadium/Types";

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
    "tick",
    func() {
        let random = PseudoRandomX.LinearCongruentialGenerator(1);
        let state : StadiumTypes.InProgressMatch = {
            offenseTeamId = #team1;
            team1 = {
                id = Principal.fromText("sctyd-5qaaa-aaaag-aa5lq-cai");
                name = "Team 1";
                logoUrl = "Team1.png";
                offering = #shuffleAndBoost;
                positions = {
                    rightField = 0;
                    centerField = 1;
                    leftField = 2;
                    shortStop = 3;
                    thirdBase = 4;
                    secondBase = 5;
                    firstBase = 6;
                    pitcher = 7;
                };
                score = 0;
            };
            team2 = {
                id = Principal.fromText("dtwn5-4iaaa-aaaag-aa6da-cai");
                name = "Team 2";
                logoUrl = "Team2.png";
                offering = #shuffleAndBoost;
                positions = {
                    rightField = 8;
                    centerField = 9;
                    leftField = 10;
                    shortStop = 11;
                    thirdBase = 12;
                    secondBase = 13;
                    firstBase = 14;
                    pitcher = 15;
                };
                score = 0;
            };
            players : [StadiumTypes.PlayerStateWithId] = [
                {
                    id = 0;
                    name = "Player 0";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #rightField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 1;
                    name = "Player 1";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #centerField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 2;
                    name = "Player 2";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #leftField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 3;
                    name = "Player 3";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #shortStop;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 4;
                    name = "Player 4";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #thirdBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 5;
                    name = "Player 5";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #secondBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 6;
                    name = "Player 6";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #firstBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 7;
                    name = "Player 7";
                    condition = #ok;
                    energy = 100;
                    teamId = #team1;
                    position = #pitcher;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 8;
                    name = "Player 8";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #centerField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 9;
                    name = "Player 9";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #pitcher;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 10;
                    name = "Player 10";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #rightField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 11;
                    name = "Player 11";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #firstBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 12;
                    name = "Player 12";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #secondBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 13;
                    name = "Player 13";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #thirdBase;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 14;
                    name = "Player 14";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #shortStop;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
                {
                    id = 15;
                    name = "Player 15";
                    condition = #ok;
                    energy = 100;
                    teamId = #team2;
                    position = #leftField;
                    skills = {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        piety = 0;
                        speed = 0;
                        defense = 0;
                    };
                },
            ];
            bases = {
                atBat = 0;
                firstBase = null;
                secondBase = null;
                thirdBase = null;
            };
            round = 0;
            outs = 0;
            strikes = 0;
            aura = #lowGravity;
            log = [];
        };
        var team1Wins = 0;
        var team2Wins = 0;
        for (i in IterTools.range(0, 100)) {
            var currentState = state;
            label l loop {
                switch (MatchSimulator.tick(currentState, random)) {
                    case (#inProgress(newState)) {
                        currentState := newState;
                    };
                    case (#completed(c)) {
                        switch (c.winner) {
                            case (#team1) {
                                team1Wins += 1;
                            };
                            case (#team2) {
                                team2Wins += 1;
                            };
                            case (#tie) {
                                team1Wins += 1;
                                team2Wins += 1;
                            };
                        };
                        break l;
                    };
                };
            };
        };
        Debug.print("Team 1 wins: " # Nat.toText(team1Wins));
        Debug.print("Team 2 wins: " # Nat.toText(team2Wins));
    },
);
