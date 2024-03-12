import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";

module {
    public type StableData = {
        scenarioId : Text;
        optionCount : Nat;
        votes : [(Principal, Vote)];
    };

    public type Vote = {
        option : Nat;
        votingPower : Nat;
    };

    public class Manager(data : [StableData]) {
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
        let votes = HashMap.fromIter<Principal, Vote>(data.votes.vals(), data.votes.size(), Principal.equal, Principal.hash);

        public func vote(
            voterId : Principal,
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
                    option = option;
                    votingPower = votingPower;
                },
            );
            #ok;
        };

        public func getVote(voterId : Principal) : ?Vote {
            votes.get(voterId);
        };

        public func calculateWinningOption() : ?Nat {
            // TODO
            // if (caller != leagueId) {
            //     return #notAuthorized;
            // };
            // Scenario Option Id -> Vote Count
            let optionVotes = HashMap.HashMap<Nat, Nat>(data.optionCount, Nat.equal, Nat32.fromNat);
            for ((userId, vote) in votes.entries()) {

                let currentVotes = switch (optionVotes.get(vote.option)) {
                    case (?v) v;
                    case (null) 0;
                };
                optionVotes.put(vote.option, currentVotes + vote.votingPower);
            };
            calculateVote<Nat>(optionVotes.entries());
        };

        public func toStableData() : StableData {
            let voteData = votes.entries()
            |> Iter.toArray(_);
            {
                data with
                votes = voteData
            };
        };

        private func calculateVote<T>(votes : Iter.Iter<(T, Nat)>) : ?T {
            var winningVote : ?(T, Nat) = null;
            for ((choice, votes) in votes) {
                switch (winningVote) {
                    case (null) winningVote := ?(choice, votes);
                    case (?o) {
                        if (o.1 < votes) {
                            winningVote := ?(choice, votes);
                        };
                        // TODO what to do if there is a tie?
                    };
                };
            };
            switch (winningVote) {
                case (null) null;
                case (?v) ?v.0;
            };
        };
    };
};
