import Text "mo:base/Text";
import Nat "mo:base/Nat";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";

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
        proposal : ExtendedProposal.Proposal<ProposalContent, Choice>;
    };

    public type Choice = {
        #skip;
        #forcefulEntry;
        #secretEntrance;
        #sacrifice;
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#skip or #forcefulEntry or #sacrifice) null;
            case (#secretEntrance) ? #trait(#perceptive);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#skip) "Ignore the structure and continue exploring elsewhere.";
            case (#forcefulEntry) "Attempt to create an opening using brute force or basic tools. Could be dangerous.";
            case (#sacrifice) "Offer a random resource or item to the structure, hoping to gain entry or unlock its secrets.";
            case (#secretEntrance) "Use the secret side entrance that was found from being so perceptive.";
        };
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        choice : Choice,
    ) {

        func exploreTreasureRoom() {
            if (prng.nextRatio(5, 10)) {
                outcomeProcessor.log("You discover a hidden chamber containing a small amount of treasure.");
                outcomeProcessor.reward();
            } else {
                outcomeProcessor.log("You find nothing of interest inside.");
            };
        };

        func exploreStructure() {
            if (prng.nextRatio(1, 4)) {
                outcomeProcessor.log("You are ambushed by a group of hostile creatures!");
                let healthLoss = prng.nextNat(0, 5);
                switch (outcomeProcessor.takeDamage(healthLoss)) {
                    case (#alive) ();
                    case (#dead) {
                        return;
                    };
                };
            } else if (prng.nextRatio(1, 2)) {
                outcomeProcessor.log("You trigger a trap!");
                let damage = prng.nextNat(1, 3);
                switch (outcomeProcessor.takeDamage(damage)) {
                    case (#alive) ();
                    case (#dead) {
                        outcomeProcessor.log("The trap is too much for you to handle.");
                        return;
                    };
                };
            };
            exploreTreasureRoom();
        };

        switch (choice) {
            case (#secretEntrance) {
                outcomeProcessor.log("You find a hidden entrance and carefully make your way inside.");
                exploreTreasureRoom();
            };
            case (#forcefulEntry) {
                func rollForDamage() {
                    if (prng.nextRatio(1, 2)) {
                        outcomeProcessor.log("You hurt yourself trying to force into the entrance.");
                        let damage = prng.nextNat(1, 5);
                        switch (outcomeProcessor.takeDamage(damage)) {
                            case (#alive) ();
                            case (#dead) {
                                outcomeProcessor.log("You are defeated in the most embarassing way.");
                                return;
                            };
                        };
                    };
                };

                rollForDamage();
                if (prng.nextRatio(1, 2)) {
                    outcomeProcessor.log("You manage to create an opening and enter the structure.");
                    exploreStructure();
                } else {
                    outcomeProcessor.log("Your attempts to force your way inside are unsuccessful.");
                };
            };
            case (#sacrifice) {
                outcomeProcessor.log("You make an offering to the structure and allows you to enter safely.");
                exploreTreasureRoom();
            };
            case (#skip) {
                outcomeProcessor.log("You decide to leave the structure alone and continue exploring elsewhere.");
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#skip) 0;
            case (#forcefulEntry) 1;
            case (#secretEntrance) 2;
            case (#sacrifice) 3;
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
