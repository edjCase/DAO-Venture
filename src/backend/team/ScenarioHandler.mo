import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Types "Types";
import IterTools "mo:itertools/Iter";

module {

    public type VoterInfo = {
        teamId : Nat;
        id : Principal;
        votingPower : Nat;
    };

    public type Vote = VoterInfo and {
        option : ?Nat;
    };

    public type StableData = {
        scenarioId : Text;
        optionCount : Nat;
        votes : [Vote];
    };

    public type GetVoteResult = {
        #ok : Vote;
        #notEligible;
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

        public func add(scenarioId : Text, optionCount : Nat, eligibleVoters : [VoterInfo]) {
            // TODO validate that no voter is repeated?
            let votes = eligibleVoters.vals()
            |> Iter.map(
                _,
                func(v : VoterInfo) : Vote = {
                    v with
                    option = null;
                },
            )
            |> Iter.toArray(_);

            let data : StableData = {
                scenarioId = scenarioId;
                optionCount = optionCount;
                votes = votes;
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
            func(v : Vote) : (Principal, Vote) = (v.id, v),
        );
        let votes = HashMap.fromIter<Principal, Vote>(userVotes, data.votes.size(), Principal.equal, Principal.hash);

        public func vote(
            voterId : Principal,
            option : Nat,
        ) : { #ok; #invalidOption; #alreadyVoted; #notAuthorized } {

            let choiceExists = option < data.optionCount;
            if (not choiceExists) {
                return #invalidOption;
            };
            let ?vote = votes.get(voterId) else return #notAuthorized;
            if (vote.option != null) {
                return #alreadyVoted;
            };
            votes.put(
                voterId,
                {
                    vote with
                    option = ?option;
                },
            );
            type Stats = {
                teams : [{
                    totalVotingPower : Nat;
                    optionCounts : [Nat];
                }];
            };
            let stats : Stats = Array.foldLeft(
                votes.vals(),
                {
                    totalVotingPower = 0;
                    optionCounts = Array.init<Nat>(data.optionCount, 0);
                },
                func(stats : Stats, vote : Vote) : Stats {
                    let option = Option.get(vote.option, 0);
                    {
                        totalVotingPower = stats.totalVotingPower + vote.votingPower;
                        optionCounts = Array.update(stats.optionCounts, option, stats.optionCounts[option] + vote.votingPower);
                    };
                },
            );
            let allTeamsHaveConsensus = IterTools.any(stats.optionCounts, func(c : Nat) : Bool = c > stats.totalVotingPower / 2);
            if (allTeamsHaveConsensus) {
                execute scenario;
            };
            #ok;
        };

        public func getVote(voterId : Principal) : {
            #ok : { option : ?Nat; votingPower : Nat };
            #notEligible;
        } {
            switch (votes.get(voterId)) {
                case (null) #notEligible;
                case (?v) #ok(v);
            };
        };

        public func calculateResults() : Types.ScenarioVotingResults {
            // TeamId + Scenario Option Id -> Vote Count
            let optionVotes = HashMap.HashMap<(Nat, Nat), Nat>(
                data.optionCount,
                func(a : (Nat, Nat), b : (Nat, Nat)) = a == b,
                func(a : (Nat, Nat)) = Nat32.fromNat(a.0) + Nat32.fromNat(a.1), // TODO
            );
            label f for ((userId, vote) in votes.entries()) {
                let ?option = vote.option else continue f;
                let key = (vote.teamId, option);
                let currentVotes = Option.get(optionVotes.get(key), 0);
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
