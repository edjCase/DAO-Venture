import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import Result "mo:base/Result";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type LocationData = {
        structureName : Text;
        size : Text;
        material : Text;
        condition : Text;
        unusualFeature : Text;
    };

    public type StableData = LocationData and {
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>;
    };

    public type MutableData = LocationData and {
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

    private let prefixes = ["Forgotten", "Ancient", "Mystic", "Enigmatic", "Shadowy", "Ethereal", "Whispering", "Shimmering", "Veiled", "Otherworldly"];
    private let nouns = ["Tower", "Temple", "Monolith", "Obelisk", "Spire", "Citadel", "Pillar", "Dome", "Pyramid", "Arch"];
    private let suffixes = ["of Echoes", "of Shadows", "of Time", "of Secrets", "of the Ancients", "of Whispers", "of Eternity", "of the Void", "of Mysteries", "of Forgotten Lore"];

    private let sizeOptions = ["Small", "Medium", "Large", "Massive"];
    private let materialOptions = ["Stone", "Crystal", "Metal", "Wood", "Bone", "Energy"];
    private let conditionOptions = ["Crumbling", "Well-preserved", "Partially submerged", "Overgrown", "Glowing", "Floating"];
    private let unusualFeatures = ["Emits strange sounds", "Shifts appearance", "Radiates energy", "Distorts nearby space", "Changes color", "Attracts local wildlife"];

    private func generateStructureName(prng : Prng) : Text {
        let prefix = prng.nextArrayElement(prefixes);
        let noun = prng.nextArrayElement(nouns);
        let suffix = prng.nextArrayElement(suffixes);
        Text.join(" ", [prefix, noun, suffix].vals());
    };

    public func generateLocation(prng : Prng) : LocationData {
        {
            structureName = generateStructureName(prng);
            size = prng.nextArrayElement(sizeOptions);
            material = prng.nextArrayElement(materialOptions);
            condition = prng.nextArrayElement(conditionOptions);
            unusualFeature = prng.nextArrayElement(unusualFeatures);
        };
    };

};
