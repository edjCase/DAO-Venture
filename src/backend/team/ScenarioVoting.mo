import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Types "./Types";
import Team "../models/Team";
import TeamDao "TeamDao";

module {
    public type Data = {
        scenarioId : Text;
        optionCount : Nat;
        votes : [(Principal, Nat)];
    };

    public class Manager(data : [Data]) {
        let iter = data.vals()
        |> Iter.map<Data, (Text, Handler)>(
            _,
            func(d : Data) : (Text, Handler) = (d.scenarioId, Handler(d)),
        );
        let handlers = HashMap.fromIter<Text, Handler>(iter, data.size(), Text.equal, Text.hash);

        public func getHandler(scenarioId : Text) : ?Handler {
            handlers.get(scenarioId);
        };

        public func add(scenarioId : Text, optionCount : Nat) {
            let data : Data = {
                scenarioId = scenarioId;
                optionCount = optionCount;
                votes = [];
            };
            let null = handlers.get(scenarioId) else Debug.trap("Scenario already exists with id: " # scenarioId);
            handlers.put(scenarioId, Handler(data));
        };

        public func remove(scenarioId : Text) : { #ok; #notFound } {
            let ?handler = handlers.remove(scenarioId) else return #notFound;
            #ok;
        };

        public func toData() : [Data] {
            handlers.entries()
            |> Iter.map<(Text, Handler), Data>(
                _,
                func(e : (Text, Handler)) : Data = e.1.toData(),
            )
            |> Iter.toArray(_);
        };
    };

    public class Handler(data : Data) {
        let votes = HashMap.fromIter<Principal, Nat>(data.votes.vals(), data.votes.size(), Principal.equal, Principal.hash);

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
            votes.put(voterId, option);
            #ok;
        };

        public func getVote(voterId : Principal) : ?Nat {
            votes.get(voterId);
        };

        public func calculateWinningOption() : ?Nat {
            // TODO
            // if (caller != leagueId) {
            //     return #notAuthorized;
            // };
            // Scenario Option Id -> Vote Count
            var optionVotes = Trie.empty<Nat, Nat>();
            for ((userId, vote) in votes.entries()) {
                let userVotingPower = 1; // TODO

                let optionKey = {
                    key = vote;
                    hash = Nat32.fromNat(vote);
                };
                let currentVotes = switch (Trie.get(optionVotes, optionKey, Nat.equal)) {
                    case (?v) v;
                    case (null) 0;
                };
                let (newOptionVotes, _) = Trie.put(optionVotes, optionKey, Nat.equal, currentVotes + userVotingPower);
                optionVotes := newOptionVotes;
            };
            calculateVote<Nat>(optionVotes);
        };

        public func toData() : Data {
            let voteData = votes.entries()
            |> Iter.toArray(_);
            {
                data with
                votes = voteData
            };
        };

        private func calculateVote<T>(votes : Trie.Trie<T, Nat>) : ?T {
            var winningVote : ?(T, Nat) = null;
            for ((choice, votes) in Trie.iter(votes)) {
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
