import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Team "../models/Team";
import Types "Types";

module {
    public type StableData = {
        matchGroups : [MatchGroupPredictions];
    };

    public type MatchGroupPredictions = {
        matchGroupId : Nat;
        matchPredictions : [[MatchPrediction]];
    };

    public type MatchPrediction = {
        userId : Principal;
        teamId : Team.TeamId;
    };

    public class Handler(data : StableData) {
        // MatchGroupId => Match Array of UserId => TeamId votes
        public var matchGroupPredictions : HashMap.HashMap<Nat, Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>> = toPredictionsHashMap(data.matchGroups);

        public func toStableData() : StableData {
            let matchGroups = matchGroupPredictions.entries()
            |> Iter.map(
                _,
                func((matchGroupId, matchPredictions) : (Nat, Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>)) : MatchGroupPredictions = {
                    matchGroupId = matchGroupId;
                    matchPredictions = mapMatchPredictions(matchPredictions);
                },
            )
            |> Iter.toArray(_);
            {
                matchGroups = matchGroups;
            };
        };

        public func addMatchGroup(matchGroupId : Nat, matchCount : Nat) : () {
            let matchPredictions = Array.tabulate(matchCount, func(_ : Nat) : HashMap.HashMap<Principal, Team.TeamId> = HashMap.HashMap<Principal, Team.TeamId>(0, Principal.equal, Principal.hash));
            let null = matchGroupPredictions.replace(matchGroupId, Buffer.fromArray(matchPredictions)) else Debug.trap("Match group predictions already exists for match group " # Nat.toText(matchGroupId));
        };

        public func predictMatchOutcome(
            matchGroupId : Nat,
            matchId : Nat,
            caller : Principal,
            prediction : ?Team.TeamId,
        ) : Types.PredictMatchOutcomeResult {
            if (Principal.isAnonymous(caller)) {
                return #identityRequired;
            };
            let ?matchesPredictions = matchGroupPredictions.get(matchGroupId) else return #predictionsClosed;
            let ?matchPredictions = matchesPredictions.getOpt(matchId) else return #matchNotFound;

            switch (prediction) {
                case (null) ignore matchPredictions.remove(caller);
                case (?winningTeamId) matchPredictions.put(caller, winningTeamId);
            };
            #ok;
        };

        public func getMatchGroup(matchGroupId : Nat) : ?[[MatchPrediction]] {
            let ?matchPredictions = matchGroupPredictions.get(matchGroupId) else return null;
            ?mapMatchPredictions(matchPredictions);
        };

        public func getMatchGroupSummary(matchGroupId : Nat, userContext : ?Principal) : Types.GetMatchGroupPredictionsResult {
            let ?matchesPredictions = matchGroupPredictions.get(matchGroupId) else return #notFound;
            let predictionSummaryBuffer = Buffer.Buffer<Types.MatchPredictionSummary>(matchesPredictions.size());

            for (matchPredictions in matchesPredictions.vals()) {
                let matchPredictionSummary = {
                    var team1 = 0;
                    var team2 = 0;
                    var yourVote : ?Team.TeamId = null;
                };
                for ((userId, userPrediction) in matchPredictions.entries()) {
                    switch (userPrediction) {
                        case (#team1) matchPredictionSummary.team1 += 1;
                        case (#team2) matchPredictionSummary.team2 += 1;
                    };
                    if (?userId == userContext) {
                        matchPredictionSummary.yourVote := ?userPrediction;
                    };
                };
                predictionSummaryBuffer.add({
                    team1 = matchPredictionSummary.team1;
                    team2 = matchPredictionSummary.team2;
                    yourVote = matchPredictionSummary.yourVote;
                });
            };

            #ok({
                matches = Buffer.toArray(predictionSummaryBuffer);
            });
        };
    };

    private func mapMatchPredictions(matchPredictions : Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>) : [[MatchPrediction]] {
        matchPredictions.vals()
        |> Iter.map<HashMap.HashMap<Principal, Team.TeamId>, [MatchPrediction]>(
            _,
            func(matchPrediction : HashMap.HashMap<Principal, Team.TeamId>) : [MatchPrediction] {
                matchPrediction.entries()
                |> Iter.map(
                    _,
                    func((userId, teamId) : (Principal, Team.TeamId)) : MatchPrediction = {
                        userId = userId;
                        teamId = teamId;
                    },
                )
                |> Iter.toArray(_);
            },
        )
        |> Iter.toArray(_);
    };

    private func toPredictionsHashMap(predictions : [MatchGroupPredictions]) : HashMap.HashMap<Nat, Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>> {
        let hashMap = HashMap.HashMap<Nat, Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>>(predictions.size(), Nat.equal, Nat32.fromNat);
        for ({ matchGroupId; matchPredictions } in Iter.fromArray(predictions)) {
            let buffer = Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>(matchPredictions.size());
            for (userPredictions in Iter.fromArray(matchPredictions)) {
                let userPredictionMap = HashMap.HashMap<Principal, Team.TeamId>(userPredictions.size(), Principal.equal, Principal.hash);
                for ({ userId; teamId } in Iter.fromArray(userPredictions)) {
                    userPredictionMap.put(userId, teamId);
                };
                buffer.add(userPredictionMap);
            };
            hashMap.put(matchGroupId, buffer);
        };
        hashMap;
    };
};
