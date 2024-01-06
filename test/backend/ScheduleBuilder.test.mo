import { test } "mo:test";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import IterTools "mo:itertools/Iter";
import Nat32 "mo:base/Nat32";
import ScheduleBuilder "../../src/backend/league/ScheduleBuilder";
import LeagueTypes "../../src/backend/league/Types";

test(
    "build",
    func() {
        let startTime = 0;
        let team1 = Principal.fromText("dzh22-nuaaa-aaaaa-qaaoa-cai");
        let team2 = Principal.fromText("dlbnd-beaaa-aaaaa-qaana-cai");
        let team3 = Principal.fromText("dfdal-2uaaa-aaaaa-qaama-cai");
        let team4 = Principal.fromText("cpmcr-yeaaa-aaaaa-qaala-cai");
        let team5 = Principal.fromText("cbopz-duaaa-aaaaa-qaaka-cai");
        let team6 = Principal.fromText("ctiya-peaaa-aaaaa-qaaja-cai");
        let team7 = Principal.fromText("d6g4o-amaaa-aaaaa-qaaoq-cai");
        let team8 = Principal.fromText("dmalx-m4aaa-aaaaa-qaanq-cai");
        let team9 = Principal.fromText("dccg7-xmaaa-aaaaa-qaamq-cai");
        let team10 = Principal.fromText("cinef-v4aaa-aaaaa-qaalq-cai");
        let team11 = Principal.fromText("cgpjn-omaaa-aaaaa-qaakq-cai");
        let team12 = Principal.fromText("cuj6u-c4aaa-aaaaa-qaajq-cai");
        let teamIds = [
            team1,
            team2,
            team3,
            team4,
            team5,
            team6,
            team7,
            team8,
            team9,
            team10,
            team11,
            team12,
        ];
        let result = ScheduleBuilder.build(startTime, teamIds, #weeks(1));

        let #ok(schedule) = result else Debug.trap("ScheduleBuilder.build failed");
        // Round robin schedule for 12 teams
        let expectedSchedule : ScheduleBuilder.SeasonSchedule = {
            matchGroups = [
                {
                    time = 0;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team12;
                        },
                        {
                            team1Id = team2;
                            team2Id = team11;
                        },
                        {
                            team1Id = team3;
                            team2Id = team10;
                        },
                        {
                            team1Id = team4;
                            team2Id = team9;
                        },
                        {
                            team1Id = team5;
                            team2Id = team8;
                        },
                        {
                            team1Id = team6;
                            team2Id = team7;
                        },
                    ];
                },
                {
                    time = 604_800_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team11;
                        },
                        {
                            team1Id = team12;
                            team2Id = team10;
                        },
                        {
                            team1Id = team2;
                            team2Id = team9;
                        },
                        {
                            team1Id = team3;
                            team2Id = team8;
                        },
                        {
                            team1Id = team4;
                            team2Id = team7;
                        },
                        {
                            team1Id = team5;
                            team2Id = team6;
                        },
                    ];
                },
                {
                    time = 1_209_600_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team10;
                        },
                        {
                            team1Id = team11;
                            team2Id = team9;
                        },
                        {
                            team1Id = team12;
                            team2Id = team8;
                        },
                        {
                            team1Id = team2;
                            team2Id = team7;
                        },
                        {
                            team1Id = team3;
                            team2Id = team6;
                        },
                        {
                            team1Id = team4;
                            team2Id = team5;
                        },
                    ];
                },
                {
                    time = 1_814_400_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team9;
                        },
                        {
                            team1Id = team10;
                            team2Id = team8;
                        },
                        {
                            team1Id = team11;
                            team2Id = team7;
                        },
                        {
                            team1Id = team12;
                            team2Id = team6;
                        },
                        {
                            team1Id = team2;
                            team2Id = team5;
                        },
                        {
                            team1Id = team3;
                            team2Id = team4;
                        },
                    ];
                },
                {
                    time = 2_419_200_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team8;
                        },
                        {
                            team1Id = team9;
                            team2Id = team7;
                        },
                        {
                            team1Id = team10;
                            team2Id = team6;
                        },
                        {
                            team1Id = team11;
                            team2Id = team5;
                        },
                        {
                            team1Id = team12;
                            team2Id = team4;
                        },
                        {
                            team1Id = team2;
                            team2Id = team3;
                        },
                    ];
                },
                {
                    time = 3_024_000_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team7;
                        },
                        {
                            team1Id = team8;
                            team2Id = team6;
                        },
                        {
                            team1Id = team9;
                            team2Id = team5;
                        },
                        {
                            team1Id = team10;
                            team2Id = team4;
                        },
                        {
                            team1Id = team11;
                            team2Id = team3;
                        },
                        {
                            team1Id = team12;
                            team2Id = team2;
                        },
                    ];
                },
                {
                    time = 3_628_800_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team6;
                        },
                        {
                            team1Id = team7;
                            team2Id = team5;
                        },
                        {
                            team1Id = team8;
                            team2Id = team4;
                        },
                        {
                            team1Id = team9;
                            team2Id = team3;
                        },
                        {
                            team1Id = team10;
                            team2Id = team2;
                        },
                        {
                            team1Id = team11;
                            team2Id = team12;
                        },
                    ];
                },
                {
                    time = 4_233_600_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team5;
                        },
                        {
                            team1Id = team6;
                            team2Id = team4;
                        },
                        {
                            team1Id = team7;
                            team2Id = team3;
                        },
                        {
                            team1Id = team8;
                            team2Id = team2;
                        },
                        {
                            team1Id = team9;
                            team2Id = team12;
                        },
                        {
                            team1Id = team10;
                            team2Id = team11;
                        },
                    ];
                },
                {
                    time = 4_838_400_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team4;
                        },
                        {
                            team1Id = team5;
                            team2Id = team3;
                        },
                        {
                            team1Id = team6;
                            team2Id = team2;
                        },
                        {
                            team1Id = team7;
                            team2Id = team12;
                        },
                        {
                            team1Id = team8;
                            team2Id = team11;
                        },
                        {
                            team1Id = team9;
                            team2Id = team10;
                        },
                    ];
                },
                {
                    time = 5_443_200_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team3;
                        },
                        {
                            team1Id = team4;
                            team2Id = team2;
                        },
                        {
                            team1Id = team5;
                            team2Id = team12;
                        },
                        {
                            team1Id = team6;
                            team2Id = team11;
                        },
                        {
                            team1Id = team7;
                            team2Id = team10;
                        },
                        {
                            team1Id = team8;
                            team2Id = team9;
                        },
                    ];
                },
                {
                    time = 6_048_000_000_000_000;
                    matches = [
                        {
                            team1Id = team1;
                            team2Id = team2;
                        },
                        {
                            team1Id = team3;
                            team2Id = team12;
                        },
                        {
                            team1Id = team4;
                            team2Id = team11;
                        },
                        {
                            team1Id = team5;
                            team2Id = team10;
                        },
                        {
                            team1Id = team6;
                            team2Id = team9;
                        },
                        {
                            team1Id = team7;
                            team2Id = team8;
                        },
                    ];
                },
            ];
        };
        var matchGroupIndex = 0;
        for ((matchGroup, expectedMatchGroup) in IterTools.zip(Iter.fromArray(schedule.matchGroups), Iter.fromArray(expectedSchedule.matchGroups))) {
            if (matchGroup.time != expectedMatchGroup.time) {
                Debug.trap("Match Group " # Nat.toText(matchGroupIndex) # " has wrong time.\nExpected:\n" # Int.toText(expectedMatchGroup.time) # "\nActual:\n" # Int.toText(matchGroup.time));
            };
            var matchIndex = 0;
            for ((match, expectedMatch) in IterTools.zip(Iter.fromArray(matchGroup.matches), Iter.fromArray(expectedMatchGroup.matches))) {
                if (match.team1Id != expectedMatch.team1Id) {
                    Debug.trap("Match Group " # Nat.toText(matchGroupIndex) # " Match " # Nat.toText(matchIndex) # " has wrong team1Id.\nExpected:\n" # Principal.toText(expectedMatch.team1Id) # "\nActual:\n" # Principal.toText(match.team1Id));
                };
                if (match.team2Id != expectedMatch.team2Id) {
                    Debug.trap("Match Group " # Nat.toText(matchGroupIndex) # " Match " # Nat.toText(matchIndex) # " has wrong team2Id.\nExpected:\n" # Principal.toText(expectedMatch.team2Id) # "\nActual:\n" # Principal.toText(match.team2Id));
                };
                matchIndex += 1;
            };
            matchGroupIndex += 1;
        };
    },
);
