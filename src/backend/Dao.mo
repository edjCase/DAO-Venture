import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Float "mo:base/Float";
import Int "mo:base/Int";

module {
    public type StableData<TProposalContent> = {
        proposals : [Proposal<TProposalContent>];
        proposalDuration : Duration;
        votingThreshold : VotingThreshold;
    };

    public type VotingThreshold = {
        #percent : { percent : Percent; quorum : ?Percent };
    };

    public type Duration = {
        #days : Nat;
        #nanoseconds : Nat;
    };

    public type Percent = Nat; // 0-100

    public type Member = {
        votingPower : Nat;
        id : Principal;
    };

    public type Proposal<TProposalContent> = {
        id : Nat;
        proposer : Principal;
        timeStart : Int;
        timeEnd : Int;
        endTimerId : ?Nat;
        content : TProposalContent;
        votes : [(Principal, Vote)];
        status : ProposalStatus;
    };

    public type ProposalStatus = {
        #open;
        #executed;
        #rejected;
    };

    public type Vote = {
        value : ?Bool;
        votingPower : Nat;
    };

    type MutableProposal<TProposalContent> = {
        id : Nat;
        proposer : Principal;
        timeStart : Int;
        timeEnd : Int;
        var endTimerId : ?Nat;
        content : TProposalContent;
        votes : HashMap.HashMap<Principal, Vote>;
        var status : ProposalStatus; // TODO status log
        votingSummary : VotingSummary;
    };

    type VotingSummary = {
        var yes : Nat;
        var no : Nat;
        var notVoted : Nat;
    };

    public type AddMemberResult = {
        #ok;
        #alreadyExists;
    };

    public type CreateProposalResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type VoteResult = {
        #ok;
        #notAuthorized;
        #alreadyVoted;
        #votingClosed;
        #proposalNotFound;
    };

    public class Dao<TProposalContent>(
        data : StableData<TProposalContent>,
        onExecute : Proposal<TProposalContent> -> async* (),
        onReject : Proposal<TProposalContent> -> async* (),
    ) {
        func hashNat(n : Nat) : Nat32 = Nat32.fromNat(n); // TODO

        let proposalsIter = data.proposals.vals()
        |> Iter.map<Proposal<TProposalContent>, (Nat, MutableProposal<TProposalContent>)>(
            _,
            func(proposal : Proposal<TProposalContent>) : (Nat, MutableProposal<TProposalContent>) {
                let mutableProposal = toMutableProposal(proposal);
                (
                    proposal.id,
                    mutableProposal,
                );
            },
        );

        var proposals = HashMap.fromIter<Nat, MutableProposal<TProposalContent>>(proposalsIter, 0, Nat.equal, hashNat);
        var nextProposalId = data.proposals.size(); // TODO make last proposal + 1

        var proposalDuration = data.proposalDuration;
        var votingThreshold = data.votingThreshold;

        public func resetEndTimers<system>() {
            for (proposal in proposals.vals()) {
                switch (proposal.endTimerId) {
                    case (null) ();
                    case (?id) Timer.cancelTimer(id);
                };
                proposal.endTimerId := null;
                if (proposal.status == #open) {
                    let proposalDurationNanoseconds = durationToNanoseconds(proposalDuration);
                    let endTimerId = createEndTimer<system>(proposal.id, proposalDurationNanoseconds);
                    proposal.endTimerId := ?endTimerId;
                };
            };
        };

        public func getProposal(id : Nat) : ?Proposal<TProposalContent> {
            let ?proposal = proposals.get(id) else return null;
            ?{
                proposal with
                endTimerId = proposal.endTimerId;
                votes = Iter.toArray(proposal.votes.entries());
                status = proposal.status;
                votingSummary = {
                    yes = proposal.votingSummary.yes;
                    no = proposal.votingSummary.no;
                    notVoted = proposal.votingSummary.notVoted;
                };
            };
        };

        public func getProposals() : [Proposal<TProposalContent>] {
            proposals.vals()
            |> Iter.map(
                _,
                func(proposal : MutableProposal<TProposalContent>) : Proposal<TProposalContent> = fromMutableProposal(proposal),
            )
            |> Iter.toArray(_);
        };

        public func vote(proposalId : Nat, voterId : Principal, vote : Bool) : async* VoteResult {
            let ?proposal = proposals.get(proposalId) else return #proposalNotFound;
            let now = Time.now();
            if (proposal.timeStart > now or proposal.timeEnd < now or proposal.status != #open) {
                return #votingClosed;
            };
            let ?existingVote = proposal.votes.get(voterId) else return #notAuthorized; // Only allow members to vote who existed when the proposal was created
            if (existingVote.value != null) {
                return #alreadyVoted;
            };
            proposal.votes.put(
                voterId,
                {
                    existingVote with
                    value = ?vote;
                },
            );
            proposal.votingSummary.notVoted -= existingVote.votingPower;
            if (vote) {
                proposal.votingSummary.yes += existingVote.votingPower;
            } else {
                proposal.votingSummary.no += existingVote.votingPower;
            };
            switch (calculateVoteStatus(proposal)) {
                case (#passed) {
                    await* executeOrRejectProposal(proposal, true);
                };
                case (#rejected) {
                    await* executeOrRejectProposal(proposal, false);
                };
                case (#undetermined) ();
            };
            #ok;
        };

        public func createProposal<system>(
            proposer : Principal,
            content : TProposalContent,
            members : [Member],
        ) : CreateProposalResult {
            // TODO check proposer is member here or in actor?
            let isAMember = members
            |> Iter.fromArray(_)
            |> Iter.filter(
                _,
                func(member : Member) : Bool = member.id == proposer,
            )
            |> _.next() != null;
            if (not isAMember) {
                return #notAuthorized;
            };
            let now = Time.now();
            let votes = HashMap.HashMap<Principal, Vote>(0, Principal.equal, Principal.hash);
            // Take snapshot of members at the time of proposal creation
            for (member in members.vals()) {
                votes.put(
                    member.id,
                    {
                        value = null; // Not voted
                        votingPower = member.votingPower;
                    },
                );
            };
            let proposalId = nextProposalId;
            let proposalDurationNanoseconds = durationToNanoseconds(proposalDuration);
            let endTimerId = createEndTimer<system>(proposalId, proposalDurationNanoseconds);
            let proposal : MutableProposal<TProposalContent> = {
                id = proposalId;
                proposer = proposer;
                content = content;
                timeStart = now;
                timeEnd = now + proposalDurationNanoseconds;
                var endTimerId = ?endTimerId;
                votes = votes;
                var status = #open;
                votingSummary = buildVotingSummary(votes);
            };
            proposals.put(nextProposalId, proposal);
            nextProposalId += 1;
            #ok(proposalId);
        };

        private func durationToNanoseconds(duration : Duration) : Nat {
            switch (duration) {
                case (#days(d)) d * 24 * 60 * 60 * 1_000_000_000;
                case (#nanoseconds(n)) n;
            };
        };

        private func createEndTimer<system>(
            proposalId : Nat,
            proposalDurationNanoseconds : Nat,
        ) : Nat {
            Timer.setTimer<system>(
                #nanoseconds(proposalDurationNanoseconds),
                func() : async () {
                    switch (await* onProposalEnd(proposalId)) {
                        case (#ok) ();
                        case (#alreadyEnded) {
                            Debug.print("EndTimer: Proposal already ended: " # Nat.toText(proposalId));
                        };
                    };
                },
            );
        };

        private func onProposalEnd(proposalId : Nat) : async* {
            #ok;
            #alreadyEnded;
        } {
            let ?mutableProposal = proposals.get(proposalId) else Debug.trap("Proposal not found for onProposalEnd: " # Nat.toText(proposalId));
            switch (mutableProposal.status) {
                case (#open) {
                    let passed = switch (calculateVoteStatus(mutableProposal)) {
                        case (#passed) true;
                        case (#rejected or #undetermined) false;
                    };
                    await* executeOrRejectProposal(mutableProposal, passed);
                    #ok;
                };
                case (#executed or #rejected) {
                    #alreadyEnded;
                };
            };
        };

        public func toStableData() : StableData<TProposalContent> {
            let proposalsArray = proposals.entries()
            |> Iter.map(
                _,
                func((_, v) : (Nat, MutableProposal<TProposalContent>)) : Proposal<TProposalContent> = fromMutableProposal<TProposalContent>(v),
            )
            |> Iter.toArray(_);

            {
                proposals = proposalsArray;
                proposalDuration = proposalDuration;
                votingThreshold = votingThreshold;
            };
        };

        private func executeOrRejectProposal(mutableProposal : MutableProposal<TProposalContent>, execute : Bool) : async* () {
            // TODO executing
            switch (mutableProposal.endTimerId) {
                case (null) ();
                case (?id) Timer.cancelTimer(id);
            };
            mutableProposal.endTimerId := null;
            mutableProposal.status := if (execute) #executed else #rejected;
            let proposal = fromMutableProposal(mutableProposal);
            if (execute) {
                await* onExecute(proposal);
            } else {
                await* onReject(proposal);
            };
        };

        private func calculateVoteStatus(proposal : MutableProposal<TProposalContent>) : {
            #undetermined;
            #passed;
            #rejected;
        } {
            let votedVotingPower = proposal.votingSummary.yes + proposal.votingSummary.no;
            let totalVotingPower = votedVotingPower + proposal.votingSummary.notVoted;
            switch (votingThreshold) {
                case (#percent({ percent; quorum })) {
                    let quorumThreshold = switch (quorum) {
                        case (null) 0;
                        case (?q) calculateFromPercent(q, totalVotingPower);
                    };
                    // The proposal must reach the quorum threshold in any case
                    if (votedVotingPower >= quorumThreshold) {
                        let voteThreshold = if (proposal.timeEnd >= Time.now()) {
                            // If the proposal has reached the end time, it passes if the votes are above the threshold of the VOTED voting power
                            let votedPercent = votedVotingPower / totalVotingPower;
                            calculateFromPercent(percent, votedVotingPower);
                        } else {
                            // If the proposal has not reached the end time, it passes if votes are above the threshold of the TOTAL voting power
                            calculateFromPercent(percent, totalVotingPower);
                        };
                        if (proposal.votingSummary.yes > proposal.votingSummary.no and proposal.votingSummary.yes >= voteThreshold) {
                            return #passed;
                        } else if (proposal.votingSummary.no > proposal.votingSummary.yes and proposal.votingSummary.no >= voteThreshold) {
                            return #rejected;
                        };
                    };
                };
            };
            return #undetermined;
        };

    };

    private func fromMutableProposal<TProposalContent>(proposal : MutableProposal<TProposalContent>) : Proposal<TProposalContent> = {
        proposal with
        endTimerId = proposal.endTimerId;
        votes = Iter.toArray(proposal.votes.entries());
        status = proposal.status;
        votingSummary = {
            yes = proposal.votingSummary.yes;
            no = proposal.votingSummary.no;
            notVoted = proposal.votingSummary.notVoted;
        };
    };

    private func toMutableProposal<TProposalContent>(proposal : Proposal<TProposalContent>) : MutableProposal<TProposalContent> {
        let votes = HashMap.fromIter<Principal, Vote>(
            proposal.votes.vals(),
            proposal.votes.size(),
            Principal.equal,
            Principal.hash,
        );
        {
            proposal with
            var endTimerId = proposal.endTimerId;
            votes = votes;
            var status = proposal.status;
            votingSummary = buildVotingSummary(votes);
        };
    };

    private func calculateFromPercent(percent : Percent, total : Nat) : Nat {
        Int.abs(Float.toInt(Float.ceil((Float.fromInt(percent) / 100.0) * Float.fromInt(total))));
    };

    private func buildVotingSummary(votes : HashMap.HashMap<Principal, Vote>) : VotingSummary {
        let votingSummary = {
            var yes = 0;
            var no = 0;
            var notVoted = 0;
        };

        for (vote in votes.vals()) {
            switch (vote.value) {
                case (null) {
                    votingSummary.notVoted += vote.votingPower;
                };
                case (?true) {
                    votingSummary.yes += vote.votingPower;
                };
                case (?false) {
                    votingSummary.no += vote.votingPower;
                };
            };
        };
        votingSummary;
    };

};
