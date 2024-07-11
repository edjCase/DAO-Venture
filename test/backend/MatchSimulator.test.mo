// import MatchSimulator "../../src/backend/stadium/MatchSimulator";
// import { test } "mo:test";
// import Trie "mo:base/Trie";
// import Hash "mo:base/Hash";
// import Nat32 "mo:base/Nat32";
// import Debug "mo:base/Debug";
// import Principal "mo:base/Principal";
// import Int "mo:base/Int";
// import Nat "mo:base/Nat";
// import Iter "mo:base/Iter";
// import Buffer "mo:base/Buffer";
// import RandomX "mo:xtended-random/RandomX";
// import PseudoRandomX "mo:xtended-random/PseudoRandomX";
// import IterTools "mo:itertools/Iter";
// import StadiumTypes "../../src/backend/stadium/Types";
// import Season "../../src/backend//models/Season";
// import MutableState "../../src/backend/models/MutableState";
// type Prng = PseudoRandomX.PseudoRandomGenerator;

// func fromArray<TKey, TValue>(array : [(TKey, TValue)], hashKey : (TKey) -> Hash.Hash, equal : (TKey, TKey) -> Bool) : Trie.Trie<TKey, TValue> {
//     var trie = Trie.empty<TKey, TValue>();
//     for ((key, value) in array.vals()) {
//         let k : Trie.Key<TKey> = {
//             key = key;
//             hash = hashKey(key);
//         };
//         let (newTrie, _) = Trie.put<TKey, TValue>(trie, k, equal, value);
//         trie := newTrie;
//     };
//     return trie;
// };
// func getPlayers() : [StadiumTypes.PlayerStateWithId] {
//     [
//         {
//             id = 0;
//             name = "Player 0";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #rightField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 1;
//             name = "Player 1";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #centerField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 2;
//             name = "Player 2";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #leftField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 3;
//             name = "Player 3";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #shortStop;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 4;
//             name = "Player 4";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #thirdBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 5;
//             name = "Player 5";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #secondBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 6;
//             name = "Player 6";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #firstBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 7;
//             name = "Player 7";
//             condition = #ok;
//             currency = 100;
//             teamId = #team1;
//             position = #pitcher;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 8;
//             name = "Player 8";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #centerField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 9;
//             name = "Player 9";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #pitcher;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 10;
//             name = "Player 10";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #rightField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 11;
//             name = "Player 11";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #firstBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 12;
//             name = "Player 12";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #secondBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 13;
//             name = "Player 13";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #thirdBase;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 14;
//             name = "Player 14";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #shortStop;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//         {
//             id = 15;
//             name = "Player 15";
//             condition = #ok;
//             currency = 100;
//             teamId = #team2;
//             position = #leftField;
//             skills = {
//                 battingAccuracy = 0;
//                 battingPower = 0;
//                 throwingAccuracy = 0;
//                 throwingPower = 0;
//                 catching = 0;
//                 speed = 0;
//                 defense = 0;
//             };
//             matchStats = {
//                 battingStats = {
//                     atBats = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 catchingStats = {
//                     successfulCatches = 0;
//                     missedCatches = 0;
//                     throws = 0;
//                     throwOuts = 0;
//                 };
//                 pitchingStats = {
//                     pitches = 0;
//                     strikes = 0;
//                     hits = 0;
//                     runs = 0;
//                     strikeouts = 0;
//                     homeRuns = 0;
//                 };
//                 injuries = 0;
//             };
//         },
//     ];
// };

// test(
//     "tick",
//     func() {
//         let random = PseudoRandomX.LinearCongruentialGenerator(1);
//         let state : StadiumTypes.InProgressMatch = {
//             offenseTeamId = #team1;
//             team1 = {
//                 id = Principal.fromText("sctyd-5qaaa-aaaag-aa5lq-cai");
//                 name = "Team 1";
//                 logoUrl = "Team1.png";
//                 offering = #shuffleAndBoost;
//                 positions = {
//                     rightField = 0;
//                     centerField = 1;
//                     leftField = 2;
//                     shortStop = 3;
//                     thirdBase = 4;
//                     secondBase = 5;
//                     firstBase = 6;
//                     pitcher = 7;
//                 };
//                 score = 0;
//             };
//             team2 = {
//                 id = Principal.fromText("dtwn5-4iaaa-aaaag-aa6da-cai");
//                 name = "Team 2";
//                 logoUrl = "Team2.png";
//                 offering = #shuffleAndBoost;
//                 positions = {
//                     rightField = 8;
//                     centerField = 9;
//                     leftField = 10;
//                     shortStop = 11;
//                     thirdBase = 12;
//                     secondBase = 13;
//                     firstBase = 14;
//                     pitcher = 15;
//                 };
//                 score = 0;
//             };
//             players = getPlayers();
//             bases = {
//                 atBat = 0;
//                 firstBase = null;
//                 secondBase = null;
//                 thirdBase = null;
//             };
//             round = 0;
//             outs = 0;
//             strikes = 0;
//             anomoly = #lowGravity;
//             log = { rounds = [] };
//         };
//         let iterations = 10;

//         let completedMatches = Buffer.Buffer<Season.CompletedMatch>(iterations);
//         for (i in IterTools.range(0, iterations)) {
//             var currentState = state;
//             label l loop {
//                 switch (MatchSimulator.tick(currentState, random)) {
//                     case (#inProgress(newState)) {
//                         currentState := newState;
//                     };
//                     case (#completed(c)) {
//                         completedMatches.add(c);
//                         break l;
//                     };
//                 };
//             };
//         };

//         let avgPlayerStats : MutableState.MutablePlayerMatchStats = {
//             battingStats = {
//                 var atBats = 0;
//                 var hits = 0;
//                 var runs = 0;
//                 var strikeouts = 0;
//                 var homeRuns = 0;
//             };
//             catchingStats = {
//                 var successfulCatches = 0;
//                 var missedCatches = 0;
//                 var throws = 0;
//                 var throwOuts = 0;
//             };
//             pitchingStats = {
//                 var pitches = 0;
//                 var strikes = 0;
//                 var hits = 0;
//                 var runs = 0;
//                 var strikeouts = 0;
//                 var homeRuns = 0;
//             };
//             var injuries = 0;
//         };
//         var totalScore : Int = 0;
//         for (match in completedMatches.vals()) {
//             for (player in match.playerStats.vals()) {
//                 avgPlayerStats.battingStats.atBats += player.battingStats.atBats;
//                 avgPlayerStats.battingStats.hits += player.battingStats.hits;
//                 avgPlayerStats.battingStats.runs += player.battingStats.runs;
//                 avgPlayerStats.battingStats.strikeouts += player.battingStats.strikeouts;
//                 avgPlayerStats.battingStats.homeRuns += player.battingStats.homeRuns;
//                 avgPlayerStats.catchingStats.successfulCatches += player.catchingStats.successfulCatches;
//                 avgPlayerStats.catchingStats.missedCatches += player.catchingStats.missedCatches;
//                 avgPlayerStats.catchingStats.throws += player.catchingStats.throws;
//                 avgPlayerStats.catchingStats.throwOuts += player.catchingStats.throwOuts;
//                 avgPlayerStats.pitchingStats.pitches += player.pitchingStats.pitches;
//                 avgPlayerStats.pitchingStats.strikes += player.pitchingStats.strikes;
//                 avgPlayerStats.pitchingStats.hits += player.pitchingStats.hits;
//                 avgPlayerStats.pitchingStats.runs += player.pitchingStats.runs;
//                 avgPlayerStats.pitchingStats.strikeouts += player.pitchingStats.strikeouts;
//                 avgPlayerStats.pitchingStats.homeRuns += player.pitchingStats.homeRuns;
//                 avgPlayerStats.injuries += player.injuries;
//             };
//             totalScore += match.team1.score + match.team2.score;
//         };

//         Debug.print("Total score: " # Int.toText(totalScore) # " (" # Int.toText(totalScore / completedMatches.size()) # " per match)");

//         Debug.print("Batting:");
//         Debug.print("atBats: " # Nat.toText(avgPlayerStats.battingStats.atBats));
//         Debug.print("hits: " # Nat.toText(avgPlayerStats.battingStats.hits) # " (" # Nat.toText((avgPlayerStats.battingStats.hits * 100) / avgPlayerStats.battingStats.atBats) # "%)");
//         Debug.print("runs: " # Nat.toText(avgPlayerStats.battingStats.runs) # " (" # Nat.toText((avgPlayerStats.battingStats.runs * 100) / avgPlayerStats.battingStats.atBats) # "%)");
//         Debug.print("outs from catches: " # Nat.toText(avgPlayerStats.catchingStats.successfulCatches) # " (" # Nat.toText(((avgPlayerStats.catchingStats.successfulCatches) * 100) / avgPlayerStats.battingStats.atBats) # "%)");
//         Debug.print("outs from throws: " # Nat.toText(avgPlayerStats.catchingStats.throwOuts) # " (" # Nat.toText((avgPlayerStats.catchingStats.throwOuts * 100) / avgPlayerStats.battingStats.atBats) # "%)");
//         Debug.print("strikeouts: " # Nat.toText(avgPlayerStats.battingStats.strikeouts) # " (" # Nat.toText((avgPlayerStats.battingStats.strikeouts * 100) / avgPlayerStats.battingStats.atBats) # "%)");
//         Debug.print("homeRuns: " # Nat.toText(avgPlayerStats.battingStats.homeRuns) # " (" # Nat.toText((avgPlayerStats.battingStats.homeRuns * 100) / avgPlayerStats.battingStats.atBats) # "%)");

//         Debug.print("Catching:");
//         Debug.print("successfulCatches: " # Nat.toText(avgPlayerStats.catchingStats.successfulCatches) # " (" # Nat.toText((avgPlayerStats.catchingStats.successfulCatches * 100) / (avgPlayerStats.catchingStats.successfulCatches + avgPlayerStats.catchingStats.missedCatches)) # "%)");
//         Debug.print("missedCatches: " # Nat.toText(avgPlayerStats.catchingStats.missedCatches) # " (" # Nat.toText((avgPlayerStats.catchingStats.missedCatches * 100) / (avgPlayerStats.catchingStats.successfulCatches + avgPlayerStats.catchingStats.missedCatches)) # "%)");
//         Debug.print("throws: " # Nat.toText(avgPlayerStats.catchingStats.throws));
//         Debug.print("throwOuts: " # Nat.toText(avgPlayerStats.catchingStats.throwOuts) # " (" # Nat.toText((avgPlayerStats.catchingStats.throwOuts * 100) / avgPlayerStats.catchingStats.throws) # "%)");

//         Debug.print("Pitching:");
//         Debug.print("pitches: " # Nat.toText(avgPlayerStats.pitchingStats.pitches));
//         Debug.print("strikes: " # Nat.toText(avgPlayerStats.pitchingStats.strikes) # " (" # Nat.toText((avgPlayerStats.pitchingStats.strikes * 100) / avgPlayerStats.pitchingStats.pitches) # "%)");
//         Debug.print("hits: " # Nat.toText(avgPlayerStats.pitchingStats.hits) # " (" # Nat.toText((avgPlayerStats.pitchingStats.hits * 100) / avgPlayerStats.pitchingStats.pitches) # "%)");
//         Debug.print("runs: " # Nat.toText(avgPlayerStats.pitchingStats.runs) # " (" # Nat.toText((avgPlayerStats.pitchingStats.runs * 100) / avgPlayerStats.pitchingStats.pitches) # "%)");
//         Debug.print("strikeouts: " # Nat.toText(avgPlayerStats.pitchingStats.strikeouts) # " (" # Nat.toText((avgPlayerStats.pitchingStats.strikeouts * 100) / avgPlayerStats.pitchingStats.pitches) # "%)");
//         Debug.print("homeRuns: " # Nat.toText(avgPlayerStats.pitchingStats.homeRuns) # " (" # Nat.toText((avgPlayerStats.pitchingStats.homeRuns * 100) / avgPlayerStats.pitchingStats.pitches) # "%)");

//         Debug.print("injuries: " # Nat.toText(avgPlayerStats.injuries) # " (" # Nat.toText((avgPlayerStats.injuries * 100) / completedMatches.size()) # "%)");
//     },
// );
