import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Types "./Types";

module {
    public type Data = {
        optionCount : Nat;
        votes : Trie.Trie<Principal, Nat>;
    };

    public class Handler(data : Data) {
        var votes : Trie.Trie<Principal, Nat> = data.votes;

        public func vote(
            voterId : Principal,
            option : Nat,
        ) : Types.VoteOnScenarioResult {
            // TODO
            // let isOwner = await isTeamOwner(caller);
            // if (not isOwner) {
            //     return #notAuthorized;
            // };

            let choiceExists = option < data.optionCount;
            if (not choiceExists) {
                return #invalidOption;
            };

            let voterKey = {
                key = voterId;
                hash = Principal.hash(voterId);
            };
            switch (Trie.put(votes, voterKey, Principal.equal, option)) {
                case ((_, ?existingVote)) #alreadyVoted;
                case ((newVotes, null)) {
                    votes := newVotes;
                    #ok;
                };
            };
        };

        public func getVote(voterId : Principal) : ?Nat {
            let voterKey = {
                key = voterId;
                hash = Principal.hash(voterId);
            };
            Trie.get(votes, voterKey, Principal.equal);
        };

        public func calculateWinningOption() : ?Nat {
            // TODO
            // if (caller != leagueId) {
            //     return #notAuthorized;
            // };
            // Scenario Option Id -> Vote Count
            var optionVotes = Trie.empty<Nat, Nat>();
            for ((userId, vote) in Trie.iter(votes)) {
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
