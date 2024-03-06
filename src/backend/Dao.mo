import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
module {

    type MemberWithoutId = {

    };

    public type Member = MemberWithoutId and {
        id : Principal;
    };

    public type ProposalWithoutId = {
        title : Text;
        description : Text;
        proposer : Principal;
        votes : Trie.Trie<Principal, Vote>;

    };

    public type Proposal = ProposalWithoutId and {
        id : Nat32;
    };

    public type AddMemberResult = {
        #ok;
        #alreadyMember;
    };

    public type VoteResult = {
        #ok;
        #alreadyVoted;
        #notMember;
        #proposalNotFound;
    };

    public type Vote = {
        #yes;
        #no;
        #abstain;
    };

    public type GetVoteResult = {
        #ok : ?Vote;
        #proposalNotFound;
    };

    public class Dao() {
        var members = Trie.empty<Principal, MemberWithoutId>();
        var nextProposalId : Nat32 = 1;
        var proposals = Trie.empty<Nat32, ProposalWithoutId>();

        public func addMember(id : Principal, member : Member) : AddMemberResult {
            // TODO security check here or in the caller?
            let idKey = {
                key = id;
                hash = Principal.hash(id);
            };
            let (newMembers, currentMember) = Trie.put(members, idKey, Principal.equal, member);
            if (currentMember != null) {
                return #alreadyMember;
            };
            members := newMembers;
            #ok;
        };

        public func addProposal(proposal : ProposalWithoutId) : () {
            // TODO security check here or in the caller?
            let proposalId = nextProposalId;
            let idKey = {
                key = proposalId;
                hash = proposalId;
            };
            let (newProposals, currentProposal) = Trie.put(proposals, idKey, Nat32.equal, proposal);
            if (currentProposal != null) {
                Debug.trap("Proposal id " # Nat32.toText(proposalId) # " already exists");
            };
            proposals := newProposals;
        };

        public func vote(proposalId : Nat32, memberId : Principal, vote : Vote) : VoteResult {
            let ?proposal = getProposal(proposalId) else return #proposalNotFound;
            let ?_ = getMember(memberId) else return #notMember;
            let memberKey = {
                key = memberId;
                hash = Principal.hash(memberId);
            };
            let (newVotes, currentVote) = Trie.put(proposal.votes, memberKey, Principal.equal, vote);
            if (currentVote != null) {
                return #alreadyVoted;
            };
            let newProposal : Proposal = {
                proposal with
                votes = newVotes;
            };
            let proposalKey = {
                key = proposalId;
                hash = proposalId;
            };
            let (newProposals, _) = Trie.put(proposals, proposalKey, Nat32.equal, newProposal);
            #ok;
        };

        public func getVote(proposalId : Nat32, memberId : Principal) : GetVoteResult {
            let ?proposal = getProposal(proposalId) else return #proposalNotFound;
            let idKey = {
                key = memberId;
                hash = Principal.hash(memberId);
            };
            let vote = Trie.get(proposal.votes, idKey, Principal.equal);
            #ok(vote);
        };

        public func getProposal(id : Nat32) : ?Proposal {
            let idKey = {
                key = id;
                hash = id;
            };
            switch (Trie.get(proposals, idKey, Nat32.equal)) {
                case (null) null;
                case (?proposal) {
                    ?{
                        proposal with
                        id = id;
                    };
                };
            };
        };

        public func getProposals() : [Proposal] {
            proposals
            |> Trie.iter(_)
            |> Iter.map(
                _,
                func(kv : (Nat32, ProposalWithoutId)) : Proposal {
                    {
                        kv.1 with
                        id = kv.0;
                    };
                },
            )
            |> Iter.toArray(_);
        };

        public func getMember(id : Principal) : ?Member {
            let idKey = {
                key = id;
                hash = Principal.hash(id);
            };
            switch (Trie.get(members, idKey, Principal.equal)) {
                case (null) null;
                case (?member) {
                    ?{
                        member with
                        id = id;
                    };
                };
            };
        };

        public func getMembers() : [Member] {
            members
            |> Trie.iter(_)
            |> Iter.map(
                _,
                func(kv : (Principal, MemberWithoutId)) : Member {
                    {
                        kv.1 with
                        id = kv.0;
                    };
                },
            )
            |> Iter.toArray(_);
        };

    };
};
