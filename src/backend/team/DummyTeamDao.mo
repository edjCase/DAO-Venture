import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Team "../Team";
import IterTools "mo:itertools/Iter";

shared (install) actor class DummyTeamDao(initOwners : [Principal]) = this {

    public type VoteResult = {
        #ok;
        #notAuthorized;
        #alreadyVoted;
        #proposalNotFound;
        #invalidVotetype;
    };
    public type Vote = {
        #matchOptions : MatchVote;
        #addTeam : Bool;
    };
    public type MatchVote = {
        offeringId : Nat32;
        specialRuleId : Nat32;
    };
    public type MatchOptionsProposal = {
        teamId : Principal;
        stadiumId : Nat32;
        matchId : Nat32;
        votes : Trie.Trie<Principal, MatchVote>;
    };
    public type AddTeamProposal = {
        teamId : Principal;
        votes : Trie.Trie<Principal, Bool>;
    };
    public type Proposal = {
        #matchOptions : MatchOptionsProposal;
        #addTeam : AddTeamProposal;
    };
    public type CreateMatchOptionsProposalRequest = {
        stadiumId : Nat32;
        matchId : Nat32;
    };
    public type CreateProposalRequest = {
        #matchOptions : CreateMatchOptionsProposalRequest;
        #addTeam : Principal;
    };
    public type CreateProposalResult = {
        #ok : Nat32;
        #notAuthorized;
    };

    stable var owners : [Principal] = initOwners;
    stable var proposals : Trie.Trie<Nat32, Proposal> = Trie.empty();
    stable var teams : [Principal] = [];

    public shared ({ caller }) func createProposal(request : CreateProposalRequest) : async CreateProposalResult {
        // let isOwner = isOwnerId(caller);
        // if (not isOwner) {
        //     return;
        // };
        let proposalId = Nat32.fromNat(Trie.size(proposals));
        let proposalKey = {
            key = proposalId;
            hash = proposalId;
        };
        let proposal : Proposal = switch (request) {
            case (#matchOptions(matchOptions)) {
                let teamId = caller;
                let isTeam = IterTools.any(teams.vals(), func(team : Principal) : Bool = team == teamId);
                if (not isTeam) {
                    // Only authorized teams can make this request
                    return #notAuthorized;
                };
                let votes : Trie.Trie<Principal, MatchVote> = Trie.empty();
                #matchOptions({
                    teamId = caller;
                    stadiumId = matchOptions.stadiumId;
                    matchId = matchOptions.matchId;
                    votes = votes;
                });
            };
            case (#addTeam(teamId)) {
                // TODO stake
                let isOwner = isOwnerId(caller);
                if (not isOwner) {
                    return #notAuthorized;
                };
                #addTeam({
                    teamId = teamId;
                    votes = Trie.empty();
                });
            };
        };
        let (newProposals, _) = Trie.put(proposals, proposalKey, Nat32.equal, proposal);
        proposals := newProposals;
        #ok(proposalId);
    };

    public shared ({ caller }) func vote(proposalId : Nat32, vote : Vote) : async VoteResult {
        let isOwner = isOwnerId(caller);
        if (not isOwner) {
            return #notAuthorized;
        };
        let proposalKey = {
            key = proposalId;
            hash = proposalId;
        };
        let proposal : Proposal = switch (Trie.get(proposals, proposalKey, Nat32.equal)) {
            case (null) return #proposalNotFound;
            case (?votes) votes;
        };
        let voterKey = {
            key = caller;
            hash = Principal.hash(caller);
        };
        let newProposal : Proposal = switch (vote) {
            case (#matchOptions(matchVote)) {
                let #matchOptions(matchOptions) = proposal else return #invalidVotetype;
                switch (Trie.put(matchOptions.votes, voterKey, Principal.equal, matchVote)) {
                    case ((_, ?existingVote)) return #alreadyVoted;
                    case ((newVotes, null)) {
                        #matchOptions({ matchOptions with votes = newVotes });
                    };
                };
            };
            case (#addTeam(addTeamVote)) {
                let #addTeam(addTeamProposal) = proposal else return #invalidVotetype;
                switch (Trie.put(addTeamProposal.votes, voterKey, Principal.equal, addTeamVote)) {
                    case ((_, ?existingVote)) return #alreadyVoted;
                    case ((newVotes, null)) {
                        #addTeam({ addTeamProposal with votes = newVotes });
                    };
                };
            };
        };
        let (newProposals, _) = Trie.put(proposals, proposalKey, Nat32.equal, newProposal);
        proposals := newProposals;
        #ok;
    };

    private func isOwnerId(caller : Principal) : Bool {
        IterTools.any(owners.vals(), func(owner : Principal) : Bool = owner == caller);
    };
};
