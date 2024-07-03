import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Team "../models/Team";
import Types "../actors/Types";

module {
    public type StableData = {
        matchGroups : [MatchGroupPredictions];
    };

    public type MatchGroupPredictions = {
        matchGroupId : Nat;
        isOpen : Bool;
        matchPredictions : [[(Principal, Team.TeamId)]];
    };

    type MatchGroupPredictionInfo = {
        var isOpen : Bool;
        matchPredictions : Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>;
    };

    public class Handler(data : StableData) {
        // MatchGroupId => Match Array of UserId => TeamId votes
        public var matchGroupPredictions : HashMap.HashMap<Nat, MatchGroupPredictionInfo> = toPredictionsHashMap(data.matchGroups);

        public func toStableData() : StableData {
            let matchGroups = matchGroupPredictions.entries()
            |> Iter.map(
                _,
                func((matchGroupId, matchGroupInfo) : (Nat, MatchGroupPredictionInfo)) : MatchGroupPredictions = {
                    matchGroupId = matchGroupId;
                    isOpen = matchGroupInfo.isOpen;
                    matchPredictions = mapMatchPredictions(matchGroupInfo.matchPredictions);
                },
            )
            |> Iter.toArray(_);
            {
                matchGroups = matchGroups;
            };
        };

        // TODO archive vs delete
        public func clear() : () {
            matchGroupPredictions := HashMap.HashMap<Nat, MatchGroupPredictionInfo>(0, Nat.equal, Nat32.fromNat);
        };

        public func addMatchGroup(matchGroupId : Nat, matchCount : Nat) : () {
            let matchPredictions = Array.tabulate(matchCount, func(_ : Nat) : HashMap.HashMap<Principal, Team.TeamId> = HashMap.HashMap<Principal, Team.TeamId>(0, Principal.equal, Principal.hash));
            let matchGroupPredictionInfo : MatchGroupPredictionInfo = {
                var isOpen = true;
                matchPredictions = Buffer.fromArray(matchPredictions);
            };
            let null = matchGroupPredictions.replace(matchGroupId, matchGroupPredictionInfo) else Debug.trap("Match group predictions already exists for match group " # Nat.toText(matchGroupId));
        };

        public func closeMatchGroup(matchGroupId : Nat) : () {
            let ?matchGroupInfo = matchGroupPredictions.get(matchGroupId) else Debug.trap("Match group predictions not found for match group " # Nat.toText(matchGroupId));
            matchGroupInfo.isOpen := false;
        };

        public func predictMatchOutcome(
            matchGroupId : Nat,
            matchId : Nat,
            caller : Principal,
            prediction : ?Team.TeamId,
        ) : Types.PredictMatchOutcomeResult {
            if (Principal.isAnonymous(caller)) {
                return #err(#identityRequired);
            };
            let ?matchGroupInfo = matchGroupPredictions.get(matchGroupId) else return #err(#predictionsClosed);
            if (not matchGroupInfo.isOpen) {
                return #err(#predictionsClosed);
            };
            let ?matchPredictions = matchGroupInfo.matchPredictions.getOpt(matchId) else return #err(#matchNotFound);

            switch (prediction) {
                case (null) ignore matchPredictions.remove(caller);
                case (?winningTeamId) matchPredictions.put(caller, winningTeamId);
            };
            #ok;
        };

        public func getMatchGroup(matchGroupId : Nat) : ?[[(Principal, Team.TeamId)]] {
            let ?matchGroupInfo = matchGroupPredictions.get(matchGroupId) else return null;
            ?mapMatchPredictions(matchGroupInfo.matchPredictions);
        };

        public func getMatchGroupSummary(matchGroupId : Nat, userContext : ?Principal) : Types.GetMatchGroupPredictionsResult {
            let ?matchGroupInfo = matchGroupPredictions.get(matchGroupId) else return #err(#notFound);
            let predictionSummaryBuffer = Buffer.Buffer<Types.MatchPredictionSummary>(matchGroupInfo.matchPredictions.size());

            for (matchPredictions in matchGroupInfo.matchPredictions.vals()) {
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

    private func mapMatchPredictions(matchPredictions : Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>) : [[(Principal, Team.TeamId)]] {
        matchPredictions.vals()
        |> Iter.map<HashMap.HashMap<Principal, Team.TeamId>, [(Principal, Team.TeamId)]>(
            _,
            func(matchPrediction : HashMap.HashMap<Principal, Team.TeamId>) : [(Principal, Team.TeamId)] {
                matchPrediction.entries()
                |> Iter.toArray(_);
            },
        )
        |> Iter.toArray(_);
    };

    private func toPredictionsHashMap(predictions : [MatchGroupPredictions]) : HashMap.HashMap<Nat, MatchGroupPredictionInfo> {
        let hashMap = HashMap.HashMap<Nat, MatchGroupPredictionInfo>(predictions.size(), Nat.equal, Nat32.fromNat);
        for ({ matchGroupId; isOpen; matchPredictions } in Iter.fromArray(predictions)) {
            let buffer = Buffer.Buffer<HashMap.HashMap<Principal, Team.TeamId>>(matchPredictions.size());
            for (userPredictions in Iter.fromArray(matchPredictions)) {
                let userPredictionMap = HashMap.HashMap<Principal, Team.TeamId>(userPredictions.size(), Principal.equal, Principal.hash);
                for ((userId, teamId) in Iter.fromArray(userPredictions)) {
                    userPredictionMap.put(userId, teamId);
                };
                buffer.add(userPredictionMap);
            };
            let matchGroupPredictionInfo : MatchGroupPredictionInfo = {
                var isOpen = isOpen;
                matchPredictions = buffer;
            };
            hashMap.put(matchGroupId, matchGroupPredictionInfo);
        };
        hashMap;
    };
};
