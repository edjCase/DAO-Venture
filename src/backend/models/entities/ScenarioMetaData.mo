import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import TextX "mo:xtended-text/TextX";
import Item "Item";
import Image "../Image";
import Zone "Zone";
import Achievement "Achievement";
import Creature "Creature";
import Character "../Character";
import IterTools "mo:itertools/Iter";
import Action "Action";

module {

    public type ScenarioMetaData = Entity.Entity and {
        location : LocationKind;
        imageId : Text;
        paths : [ScenarioPath];
        category : ScenarioCategory;
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public type ScenarioCategory = {
        #other;
        #combat;
        #store;
    };

    public type LocationKind = {
        #common;
        #zoneIds : [Text];
    };

    public type ScenarioPath = {
        id : Text;
        description : Text;
        kind : ScenarioPathKind;
    };

    public type ScenarioPathKind = {
        #choice : ChoicePath;
        #combat : CombatPath;
        #reward : RewardPath;
    };

    public type ChoicePath = {
        choices : [Choice];
    };

    public type Choice = {
        id : Text;
        description : Text;
        effects : [Effect];
        requirement : ?ChoiceRequirement;
        nextPath : NextPathKind;
    };

    public type CombatPath = {
        creatures : [CombatCreatureKind];
        nextPath : NextPathKind;
    };

    public type RewardPath = {
        kind : RewardPathKind;
        nextPath : NextPathKind;
    };

    public type RewardPathKind = {
        #random;
        #specificItemIds : [Text];
    };

    public type NextPathKind = {
        #single : Text;
        #multi : [WeightedScenarioPathOption];
        #none;
    };

    public type CombatCreatureKind = {
        #id : Text;
        #filter : CombatCreatureFilter;
    };

    public type CombatCreatureFilter = {
        location : CombatCreatureLocationFilter;
    };

    public type CombatCreatureLocationFilter = {
        #zone : Text;
        #common;
        #any;
    };

    public type WeightedScenarioPathOption = {
        weight : OptionWeight;
        pathId : Text;
        description : Text;
        effects : [Effect];
    };

    public type OptionWeight = {
        value : Float;
        kind : WeightKind;
    };

    public type WeightKind = {
        #raw;
        #attributeScaled : Action.Attribute;
    };

    public type Effect = {
        #damage : NatValue;
        #heal : NatValue;
        #removeGold : NatValue;
        #addItem : RandomOrSpecificTextValue;
        #removeItem : RandomOrSpecificTextValue;
        #achievement : Text;
    };

    public type RandomOrSpecificTextValue = {
        #random;
        #specific : TextValue;
    };

    public type NatValue = {
        #raw : Nat;
        #random : (Nat, Nat);
    };

    public type TextValue = {
        #raw : Text;
        #weighted : [(Text, Float)];
    };

    public type ChoiceRequirement = {
        #item : Text;
        #gold : Nat;
        #attribute : AttributeChoiceRequirement;
    };

    public type AttributeChoiceRequirement = {
        attribute : Action.Attribute;
        value : Int;
    };

    public func validate(
        metaData : ScenarioMetaData,
        items : HashMap.HashMap<Text, Item.Item>,
        images : HashMap.HashMap<Text, Image.Image>,
        zones : HashMap.HashMap<Text, Zone.Zone>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
    ) : Result.Result<(), [Text]> {
        var errors = Buffer.Buffer<Text>(0);

        Entity.validate("Scenario", metaData, errors);
        switch (metaData.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
        };
        if (images.get(metaData.imageId) == null) {
            errors.add("Image id not found: " # metaData.imageId);
        };

        switch (metaData.location) {
            case (#common) {};
            case (#zoneIds(zoneIds)) {
                if (zoneIds.size() == 0) {
                    errors.add("Zone ids must not be empty");
                } else {
                    for (zoneId in zoneIds.vals()) {
                        if (zones.get(zoneId) == null) {
                            errors.add("Zone id not found: " # zoneId);
                        };
                    };
                };
            };
        };

        let pathIdMap = HashMap.HashMap<Text, ScenarioPath>(metaData.paths.size(), Text.equal, Text.hash);
        for (path in metaData.paths.vals()) {
            if (pathIdMap.replace(path.id, path) != null) {
                errors.add("Duplicate path id: " # path.id);
            };
        };
        // Check paths
        for (path in metaData.paths.vals()) {
            let visitedPaths = HashMap.HashMap<Text, Bool>(0, Text.equal, Text.hash);
            validateAcyclical(path.id, visitedPaths, pathIdMap, errors, false);

            switch (path.kind) {
                case (#combat(combat)) {
                    validateNextPath(combat.nextPath, pathIdMap, errors);
                    for (creature in combat.creatures.vals()) {
                        switch (creature) {
                            case (#id(id)) {
                                if (creatures.get(id) == null) {
                                    errors.add("Invalid creature id: " # id);
                                };
                            };
                            case (#filter(filter)) {
                                switch (filter.location) {
                                    case (#zone(zoneId)) {
                                        if (zones.get(zoneId) == null) {
                                            errors.add("Invalid zone id: " # zoneId);
                                        };
                                    };
                                    case (#common) ();
                                    case (#any) ();
                                };
                            };
                        };
                    };
                };
                case (#choice(choicePath)) {
                    let choiceIdMap = HashMap.HashMap<Text, ()>(choicePath.choices.size(), Text.equal, Text.hash);

                    // Check choices
                    for (choice in choicePath.choices.vals()) {
                        if (choiceIdMap.replace(choice.id, ()) == ?()) {
                            errors.add("Duplicate choice id: " # choice.id);
                        };
                        validateNextPath(choice.nextPath, pathIdMap, errors);
                        switch (choice.requirement) {
                            case (?requirement) validateRequirement(requirement, items, errors);
                            case (null) {};
                        };
                        for (effect in choice.effects.vals()) {
                            validateEffect(effect, items, achievements, errors);
                        };

                    };
                };
                case (#reward(reward)) {
                    validateNextPath(reward.nextPath, pathIdMap, errors);
                    switch (reward.kind) {
                        case (#random) {};
                        case (#specificItemIds(itemIds)) {
                            for (itemId in itemIds.vals()) {
                                if (items.get(itemId) == null) {
                                    errors.add("Invalid item id: " # itemId);
                                };
                            };
                        };
                    };
                };
            };
        };

        if (errors.size() > 0) {
            #err(Buffer.toArray(errors));
        } else {
            #ok();
        };
    };

    func validateNextPath(
        nextPath : NextPathKind,
        pathIdMap : HashMap.HashMap<Text, ScenarioPath>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (nextPath) {
            case (#single(pathId)) {
                if (pathIdMap.get(pathId) == null) {
                    errors.add("Invalid path id: " # pathId);
                };
            };
            case (#multi(weightedPaths)) {
                for (weightedPath in weightedPaths.vals()) {
                    if (pathIdMap.get(weightedPath.pathId) == null) {
                        errors.add("Invalid path id: " # weightedPath.pathId);
                    };
                };
            };
            case (#none) ();
        };
    };

    // Check for path cycles
    func validateAcyclical(
        pathId : Text,
        visitedPaths : HashMap.HashMap<Text, Bool>,
        pathIdMap : HashMap.HashMap<Text, ScenarioPath>,
        errors : Buffer.Buffer<Text>,
        branchingPath : Bool,
    ) {
        switch (visitedPaths.get(pathId)) {
            case (?true) return; // Already visited, skip
            case (?false) {
                if (not branchingPath) {
                    errors.add("Cycle detected at path: " # pathId);
                };
                return;
            };
            case (null) {
                visitedPaths.put(pathId, false);
                let ?path = pathIdMap.get(pathId) else {
                    errors.add("Invalid path id: " # pathId);
                    return;
                };

                switch (path.kind) {
                    case (#choice(choicePath)) {
                        for (choice in choicePath.choices.vals()) {
                            validateAcyclicalPathKind(choice.nextPath, visitedPaths, pathIdMap, errors);
                        };
                    };
                    case (#combat(combat)) validateAcyclicalPathKind(combat.nextPath, visitedPaths, pathIdMap, errors);
                    case (#reward(reward)) validateAcyclicalPathKind(reward.nextPath, visitedPaths, pathIdMap, errors);
                };

                visitedPaths.put(pathId, true);

            };
        };
    };

    func validateAcyclicalPathKind(
        pathKind : NextPathKind,
        visitedPaths : HashMap.HashMap<Text, Bool>,
        pathIdMap : HashMap.HashMap<Text, ScenarioPath>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (pathKind) {
            case (#single(pathId)) {
                validateAcyclical(pathId, visitedPaths, pathIdMap, errors, false);
            };
            case (#multi(weightedPaths)) {
                for (weightedPath in weightedPaths.vals()) {
                    validateAcyclical(weightedPath.pathId, visitedPaths, pathIdMap, errors, true);
                };
            };
            case (#none) ();
        };
    };

    func validateRequirement(
        requirement : ChoiceRequirement,
        items : HashMap.HashMap<Text, Item.Item>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (requirement) {
            case (#item(itemId)) {
                if (items.get(itemId) == null) {
                    errors.add("Invalid item id in choice requirement: " # itemId);
                };
            };
            case (#attribute(attribute)) {
                if (attribute.value == 0) {
                    errors.add("Attribute requirement value cannot be 0");
                };
            };
            case (#gold(gold)) {
                if (gold == 0) {
                    errors.add("Gold requirement must be greater than 0");
                };
            };
        };
    };

    func validateTextValue<T>(
        value : TextValue,
        map : HashMap.HashMap<Text, T>,
        kind : Text,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (value) {
            case (#raw(raw)) {
                switch (map.get(raw)) {
                    case (?_) ();
                    case (null) {
                        errors.add("Invalid " # kind # ": " # raw);
                    };
                };
            };
            case (#weighted(weighted)) {
                for ((v, weight) in weighted.vals()) {
                    switch (map.get(v)) {
                        case (?_) ();
                        case (null) {
                            errors.add("Invalid " # kind # ": " # v);
                        };
                    };
                    if (weight <= 0.0) {
                        errors.add("Weights must be greater than 0: " # Float.toText(weight));
                    };
                };
            };
        };
    };

    func validateNatValue(
        value : NatValue,
        kind : Text,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (value) {
            case (#raw(_)) {};
            case (#random(min, max)) {
                if (min >= max) {
                    errors.add("Random " # kind # " min must be less than max: " # Nat.toText(min) # " >= " # Nat.toText(max));
                };
            };
        };
    };

    private func validateEffect(
        effect : Effect,
        items : HashMap.HashMap<Text, Item.Item>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (effect) {
            case (#addItem(addItem)) {
                switch (addItem) {
                    case (#random) {};
                    case (#specific(specific)) validateTextValue(specific, items, "item", errors);
                };
            };
            case (#removeGold(removeGold)) validateNatValue(removeGold, "gold", errors);
            case (#removeItem(removeItem)) {
                switch (removeItem) {
                    case (#random) {};
                    case (#specific(specific)) validateTextValue(specific, items, "item", errors);
                };
            };
            case (#damage(damage)) validateNatValue(damage, "damage", errors);
            case (#heal(heal)) validateNatValue(heal, "heal", errors);
            case (#achievement(achievementId)) {
                if (TextX.isEmpty(achievementId)) {
                    errors.add("Achievement id cannot be empty");
                };
                if (achievements.get(achievementId) == null) {
                    errors.add("Invalid achievement id: " # achievementId);
                };
            };
        };
    };

    public func characterMeetsRequirement(
        requirement : ChoiceRequirement,
        character : Character.Character,
        attributes : Character.CharacterAttributes,
    ) : Bool {
        switch (requirement) {
            case (#item(itemId)) IterTools.any(character.inventorySlots.vals(), func(slot : { itemId : ?Text }) : Bool = slot.itemId == ?itemId);
            case (#gold(amount)) character.gold >= amount;
            case (#attribute(attribute)) {
                switch (attribute.attribute) {
                    case (#strength) attributes.strength >= attribute.value;
                    case (#dexterity) attributes.dexterity >= attribute.value;
                    case (#wisdom) attributes.wisdom >= attribute.value;
                    case (#charisma) attributes.charisma >= attribute.value;
                };
            };
        };
    };
};
