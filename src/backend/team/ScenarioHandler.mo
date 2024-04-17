import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Prelude "mo:base/Prelude";
import Types "Types";

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
        scenarioId : Nat;
        optionCount : Nat;
        votes : [Vote];
    };

    public type GetVoteResult = {
        #ok : Vote;
        #notEligible;
    };

    public class MultiHandler(data : [StableData]) {
        let iter = data.vals()
        |> Iter.map<StableData, (Nat, Handler)>(
            _,
            func(d : StableData) : (Nat, Handler) = (d.scenarioId, Handler(d)),
        );
        let handlers = HashMap.fromIter<Nat, Handler>(iter, data.size(), Nat.equal, Nat32.fromNat);

        public func getHandler(scenarioId : Nat) : ?Handler {
            handlers.get(scenarioId);
        };

        public func add(scenarioId : Nat, optionCount : Nat, eligibleVoters : [VoterInfo]) {
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
            let null = handlers.get(scenarioId) else Debug.trap("Scenario already exists with id: " # Nat.toText(scenarioId));
            handlers.put(scenarioId, Handler(data));
        };

        public func remove(scenarioId : Nat) : { #ok; #notFound } {
            let ?_ = handlers.remove(scenarioId) else return #notFound;
            #ok;
        };

        public func toStableData() : [StableData] {
            handlers.entries()
            |> Iter.map<(Nat, Handler), StableData>(
                _,
                func(e : (Nat, Handler)) : StableData = e.1.toStableData(),
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
            switch (calculateResultsInternal(false)) {
                case (#noConsensus) ();
                case (#consensus(_)) {
                    // TODO close voting early
                };
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
            let #consensus(teamOptions) = calculateResultsInternal(true) else Prelude.unreachable();
            {
                teamOptions = teamOptions;
            };
        };

        private func calculateResultsInternal(votingClosed : Bool) : {
            #consensus : [Types.ScenarioTeamVotingResult];
            #noConsensus;
        } {
            type TeamStats = {
                var totalVotingPower : Nat;
                optionVotingPowers : [var Nat];
            };
            let teamStats = HashMap.HashMap<Nat, TeamStats>(0, Nat.equal, Nat32.fromNat);

            for (vote in votes.vals()) {
                let stats : TeamStats = switch (teamStats.get(vote.teamId)) {
                    case (null) {
                        let initStats : TeamStats = {
                            var totalVotingPower = 0;
                            optionVotingPowers = Array.init<Nat>(data.optionCount, 0);
                        };
                        teamStats.put(vote.teamId, initStats);
                        initStats;
                    };
                    case (?voterTeamStats) voterTeamStats;
                };
                stats.totalVotingPower += vote.votingPower;
                switch (vote.option) {
                    case (?option) stats.optionVotingPowers[option] += vote.votingPower;
                    case (null) ();
                };
            };
            let teamResults = Buffer.Buffer<Types.ScenarioTeamVotingResult>(teamStats.size());
            for ((teamId, stats) in teamStats.entries()) {
                var optionWithMostVotes : (Nat, Nat) = (0, 0);
                for (option in stats.optionVotingPowers.vals()) {
                    if (option > optionWithMostVotes.1) {
                        // TODO what to do in a tie?
                        optionWithMostVotes := (option, optionWithMostVotes.1);
                    };
                };

                if (not votingClosed) {
                    // Validate that the majority has been reached, if voting is still active
                    let majority = stats.totalVotingPower / 2;
                    if (optionWithMostVotes.1 < majority) {
                        return #noConsensus; // If any team hasnt reached a consensus, wait till its forced (end of voting period)
                    };
                };
                teamResults.add({
                    teamId = teamId;
                    option = optionWithMostVotes.0;
                });
            };

            #consensus(Buffer.toArray(teamResults));
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
