import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Types "Types";

module {
    public type Vote = {
        userId : Principal;
        teamId : Nat;
        option : Nat;
        votingPower : Nat;
    };

    public type StableData = {
        scenarioId : Text;
        optionCount : Nat;
        votes : [Vote];
    };

    public class MultiHandler(data : [StableData]) {
        let iter = data.vals()
        |> Iter.map<StableData, (Text, Handler)>(
            _,
            func(d : StableData) : (Text, Handler) = (d.scenarioId, Handler(d)),
        );
        let handlers = HashMap.fromIter<Text, Handler>(iter, data.size(), Text.equal, Text.hash);

        public func getHandler(scenarioId : Text) : ?Handler {
            handlers.get(scenarioId);
        };

        public func add(scenarioId : Text, optionCount : Nat) {
            let data : StableData = {
                scenarioId = scenarioId;
                optionCount = optionCount;
                votes = [];
            };
            let null = handlers.get(scenarioId) else Debug.trap("Scenario already exists with id: " # scenarioId);
            handlers.put(scenarioId, Handler(data));
        };

        public func remove(scenarioId : Text) : { #ok; #notFound } {
            let ?_ = handlers.remove(scenarioId) else return #notFound;
            #ok;
        };

        public func toStableData() : [StableData] {
            handlers.entries()
            |> Iter.map<(Text, Handler), StableData>(
                _,
                func(e : (Text, Handler)) : StableData = e.1.toStableData(),
            )
            |> Iter.toArray(_);
        };
    };

    public class Handler(data : StableData) {
        let userVotes = data.votes.vals()
        |> Iter.map<Vote, (Principal, Vote)>(
            _,
            func(v : Vote) : (Principal, Vote) = (v.userId, v),
        );
        let votes = HashMap.fromIter<Principal, Vote>(userVotes, data.votes.size(), Principal.equal, Principal.hash);

        public func vote(
            voterId : Principal,
            teamId : Nat,
            votingPower : Nat,
            option : Nat,
        ) : { #ok; #invalidOption; #alreadyVoted } {

            let choiceExists = option < data.optionCount;
            if (not choiceExists) {
                return #invalidOption;
            };
            if (votes.get(voterId) != null) {
                return #alreadyVoted;
            };
            votes.put(
                voterId,
                {
                    userId = voterId;
                    teamId = teamId;
                    option = option;
                    votingPower = votingPower;
                },
            );
            #ok;
        };

        public func getVote(voterId : Principal) : ?Vote {
            votes.get(voterId);
        };

        public func calculateResults() : Types.ScenarioVotingResults {
            // TODO
            // if (caller != leagueId) {
            //     return #notAuthorized;
            // };
            // TeamId + Scenario Option Id -> Vote Count
            let optionVotes = HashMap.HashMap<(Nat, Nat), Nat>(
                data.optionCount,
                func(a : (Nat, Nat), b : (Nat, Nat)) = a == b,
                func(a : (Nat, Nat)) = Nat32.fromNat(a.0) + Nat32.fromNat(a.1), // TODO
            );
            for ((userId, vote) in votes.entries()) {
                let key = (vote.teamId, vote.option);
                let currentVotes = switch (optionVotes.get(key)) {
                    case (?v) v;
                    case (null) 0;
                };
                optionVotes.put(key, currentVotes + vote.votingPower);
            };
            var teamWinningOptions : HashMap.HashMap<Nat, (Nat, Nat)> = HashMap.HashMap(6, Nat.equal, Nat32.fromNat);
            for (((teamId, option), voteCount) in optionVotes.entries()) {
                switch (teamWinningOptions.get(teamId)) {
                    case (null) teamWinningOptions.put(teamId, (option, voteCount));
                    case (?currentWinner) {
                        if (currentWinner.1 < voteCount) {
                            teamWinningOptions.put(teamId, (option, voteCount));
                        };
                        // TODO what to do if there is a tie?
                    };
                };
            };
            let teamChoices = teamWinningOptions.entries()
            |> Iter.map(
                _,
                func((teamId, (option, _)) : (Nat, (Nat, Nat))) : {
                    teamId : Nat;
                    option : Nat;
                } = {
                    option = option;
                    teamId = teamId;
                },
            )
            |> Iter.toArray(_);
            {
                teamOptions = teamChoices;
            };
        };

        public func toStableData() : StableData {
            let voteData = votes.vals()
            |> Iter.toArray(_);
            {
                data with
                votes = voteData
            };
        };
    };
};
