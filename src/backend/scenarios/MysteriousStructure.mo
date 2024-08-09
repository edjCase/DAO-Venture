import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import Result "mo:base/Result";

module {
    public type MetaData = {
        structureName : Text;
    };

    public type StableData = MetaData and {
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>;
    };

    public type MutableData = MetaData and {
        proposalEngine : GenericProposalEngine.ProposalEngine<ProposalContent, Choice>;
    };

    public type ProposalContent = {

    };

    public type Choice = {

    };

    public func onProposalExecute(
        choice : ?Choice,
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>,
    ) : async* Result.Result<(), Text> {
        #ok; // TODO
    };

    public func onProposalValidate(content : ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        true; // TODO
    };

    public func hashChoice(choice : Choice) : Nat32 {
        0; // TODO
    };

};
