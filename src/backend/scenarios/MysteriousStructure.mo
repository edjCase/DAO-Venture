import ExtendedProposalEngine "mo:dao-proposal-engine/ExtendedProposalEngine";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type LocationData = {
        structureName : Text;
        size : Text;
        material : Text;
        condition : Text;
        unusualFeature : Text;
    };

    public type ProposalContent = {
        locationId : Nat;
    };

    public type StableData = LocationData and {
        proposal : ExtendedProposalEngine.Proposal<ProposalContent, Choice>;
    };

    public type Choice = {
        #cautiousSearch;
        #forcefulEntry;
        #crystalResonance;
        #naturesApproach;
        #ancientRitual;
        #arcaneVision;
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#cautiousSearch or #forcefulEntry) null;
            case (#crystalResonance) ? #item(#echoCrystal);
            case (#naturesApproach) ? #trait(#natureAttuned);
            case (#ancientRitual) ? #all([#item(#ancientRunes), #item(#mysticalTome)]);
            case (#arcaneVision) ? #all([#item(#scryingOrb), #trait(#thirdEye)]);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#cautiousSearch) "Carefully examine the structure's exterior for a hidden entrance.";
            case (#forcefulEntry) "Attempt to create an opening using brute force or basic tools.";
            case (#crystalResonance) "Use an Echo Crystal to try and resonate with the structure, potentially revealing hidden pathways.";
            case (#naturesApproach) "Attempt to commune with the surrounding plantlife to find a natural way inside.";
            case (#ancientRitual) "Perform a mystical ritual based on clues found on the structure's exterior.";
            case (#arcaneVision) "Use a Scrying Orb and your Third Eye ability to peer through the structure's magical barriers.";
        };
    };

    public func getOutcome(prng : Prng, choice : ?Choice) : Outcome.Outcome<Choice> {
        let descriptions = Buffer.Buffer<Text>(1);
        let effects = Buffer.Buffer<Outcome.Effect>(1);
        // switch (choice) {
        //     case (#cautiousSearch) {
        //         if (prng.nextRatio(3, 10)) {
        //             descriptions.add("You find a hidden entrance and carefully make your way inside.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You hit a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("You search the structure's exterior but find no hidden entrances.");
        //         };
        //     };
        //     case (#forcefulEntry) {
        //         if (prng.nextRatio(1, 2)) {
        //             descriptions.add("You manage to create an opening and enter the structure.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You trigger a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("Your attempts to force your way inside are unsuccessful.");
        //         };
        //     };
        //     case (#crystalResonance) {
        //         descriptions.add("You use an Echo Crystal to resonate with the structure.");

        //         if (prng.nextRatio(1, 2)) {
        //             descriptions.add("The crystal reveals a hidden pathway inside the structure.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You trigger a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("The crystal does not resonate with the structure.");
        //         };
        //     };
        //     case (#naturesApproach) {
        //         descriptions.add("You attempt to commune with the surrounding plantlife.");

        //         if (prng.nextRatio(1, 2)) {
        //             descriptions.add("The plants guide you to a natural entrance.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You hit a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("The plants do not reveal a natural entrance.");
        //         };
        //     };
        //     case (#ancientRitual) {
        //         descriptions.add("You perform a mystical ritual based on clues found on the structure's exterior.");

        //         if (prng.nextRatio(1, 2)) {
        //             descriptions.add("The ritual opens a hidden doorway.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You trigger a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("The ritual does not open the doorway.");
        //         };
        //     };
        //     case (#arcaneVision) {
        //         descriptions.add("You use a Scrying Orb and your Third Eye ability to peer through the structure's magical barriers.");

        //         if (prng.nextRatio(1, 2)) {
        //             descriptions.add("You see a hidden entrance through the magical barriers.");

        //             if (prng.nextRatio(1, 4)) {
        //                 combat(prng, descriptions, effects);
        //             } else if (prng.nextRatio(1, 2)) {
        //                 descriptions.add("You trigger a trap and take some damage.");
        //                 effects.add(#health(prng.nextNat(1, 3)));
        //             };

        //             if (prng.nextRatio(5, 10)) {
        //                 descriptions.add("You discover a hidden chamber containing a small amount of treasure.");
        //                 treasure(prng, effects);
        //             } else {
        //                 descriptions.add("You find nothing of interest inside.");
        //             };
        //         } else {
        //             descriptions.add("You are unable to see through the magical barriers.");
        //         };
        //     };
        // };
        {
            choice = choice;
            description = Buffer.toArray(descriptions);
            effects = Buffer.toArray(effects);
        };
    };

    // public func combat(prng : Prng, descriptions : Buffer.Buffer<Text>, effects : Buffer.Buffer<Effect>) {
    //     descriptions.add("You are ambushed by a group of hostile creatures!");
    //     let healthLoss = prng.nextNat(0, 5);
    //     descriptions.add("You take " # Nat.toText(healthLoss) # " damage.");
    //     health -= healthLoss;
    //     if (health <= 0) {
    //         descriptions.add("You are defeated in combat.");
    //         effects.add(#death);
    //         return;
    //     };
    //     effects.add(#health(healthLoss));
    // };

    // public func treasure(prng : Prng, effects : Buffer.Buffer<Effect>) {
    //     let treasure = prng.nextArrayElement([#money(10), #item(#echoCrystal, #gain)]);
    //     effects.add(treasure);
    // };

    public func onProposalExecute(
        choice : ?Choice,
        proposal : ExtendedProposalEngine.Proposal<ProposalContent, Choice>,
    ) : async* Result.Result<(), Text> {
        #ok; // TODO
    };

    public func onProposalValidate(content : ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#cautiousSearch) 0;
            case (#forcefulEntry) 1;
            case (#crystalResonance) 2;
            case (#naturesApproach) 3;
            case (#ancientRitual) 4;
            case (#arcaneVision) 5;
        };
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
