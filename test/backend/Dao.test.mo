// import { testsys; expect } "mo:test/async";
// import Debug "mo:base/Debug";
// import Nat "mo:base/Nat";
// import Dao "../../src/backend/Dao";
// import Result "mo:base/Result";
// import Principal "mo:base/Principal";

// testsys<system>(
//     "arrayUpdateElementSafe",
//     func<system>() : async () {
//         type ProposalContent = {
//             text : Text;
//         };
//         var onExecuteCalls = 0;
//         var onRejectCalls = 0;
//         let onExecute = func(proposal : Dao.Proposal<ProposalContent>) : async* Result.Result<(), Text> {
//             Debug.print("Proposal executed: " # Nat.toText(proposal.id));
//             onExecuteCalls += 1;
//             #ok;
//         };
//         let onReject = func(proposal : Dao.Proposal<ProposalContent>) : async* () {
//             Debug.print("Proposal rejected: " # Nat.toText(proposal.id));
//             onRejectCalls += 1;
//         };
//         let stableData : Dao.StableData<ProposalContent> = {
//             proposalDuration = #days(1);
//             votingThreshold = #percent({
//                 percent = 50;
//                 quorum = ?20;
//             });
//             proposals = [];
//         };
//         let dao = Dao.Dao<ProposalContent>(stableData, onExecute, onReject);
//         let creatorId = Principal.fromText("sctyd-5qaaa-aaaag-aa5lq-cai");
//         let members : [Dao.Member] = [{
//             id = creatorId;
//             votingPower = 1;
//         }];
//         let result = dao.createProposal<system>(creatorId, { text = "Proposal 1" }, members);
//         let show = func(x : Result.Result<Nat, Dao.CreateProposalError>) : Text = debug_show (x);
//         let equal = func(x : Result.Result<Nat, Dao.CreateProposalError>, y : Result.Result<Nat, Dao.CreateProposalError>) : Bool {
//             x == y;
//         };
//         expect.result(result, show, equal).equal(#ok(1));

//         let voteResult = await* dao.vote<system>(1, creatorId, true);

//         let showVote = func(x : Result.Result<(), Dao.VoteError>) : Text = debug_show (x);
//         let equalVote = func(x : Result.Result<(), Dao.VoteError>, y : Result.Result<(), Dao.VoteError>) : Bool {
//             x == y;
//         };

//         expect.result(voteResult, showVote, equalVote).equal(#ok);

//         expect.nat(onExecuteCalls).equal(1);
//         expect.nat(onRejectCalls).equal(0);

//         let proposal = dao.getProposal(1);
//         // expect.option(proposal).toNotEqual(None);
//     },
// );
