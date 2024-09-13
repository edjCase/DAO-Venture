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
        nextPathOptions : [WeightedScenarioPathOption];
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
        data : [GeneratedDataField];
        effects : [Effect];
        requirement : ?ChoiceRequirement;
    };

    public type CombatPath = {
        creatures : [CombatCreatureKind];
    };

    public type RewardPath = {
        #random;
        #specificItemIds : [Text];
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
        weight : Float;
        condition : ?Condition;
        pathId : Text;
    };

    public type GeneratedDataField = {
        id : Text;
        name : Text;
        value : GeneratedDataFieldValue;
    };

    public type GeneratedDataFieldValue = {
        #nat : GeneratedDataFieldNat;
        #text : GeneratedDataFieldText;
    };

    public type GeneratedDataFieldNat = {
        min : Nat;
        max : Nat;
    };

    public type GeneratedDataFieldText = {
        options : [(Text, Float)];
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
        #dataField : Text;
    };

    public type TextValue = {
        #raw : Text;
        #weighted : [(Text, Float)];
        #dataField : Text;
    };

    public type Condition = {
        #hasGold : Nat;
        #hasItem : Text;
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #item : Text;
        #race : Text;
        #class_ : Text;
        #gold : Nat;
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
        // Check paths
        var visitedPaths = HashMap.HashMap<Text, Bool>(0, Text.equal, Text.hash);
        for (path in metaData.paths.vals()) {
            if (pathIdMap.replace(path.id, path) != null) {
                errors.add("Duplicate path id: " # path.id);
            };

            if (depthFirstSearch(path.id, visitedPaths, pathIdMap, errors)) {
                errors.add("Cycle detected in paths starting from: " # path.id);
            };

            switch (path.kind) {
                case (#combat(combat)) {
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
                        switch (choice.requirement) {
                            case (?requirement) validateRequirement(requirement, items, errors);
                            case (null) {};
                        };
                        // Check data fields
                        let dataFieldIdMap = HashMap.HashMap<Text, GeneratedDataField>(choice.data.size(), Text.equal, Text.hash);
                        for (field in choice.data.vals()) {
                            if (dataFieldIdMap.replace(field.id, field) != null) {
                                errors.add("Duplicate data field id: " # field.id);
                            };
                        };
                        for (effect in choice.effects.vals()) {
                            validateEffect(effect, items, achievements, dataFieldIdMap, errors);
                        };

                    };
                };
                case (#reward(reward)) {
                    switch (reward) {
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

        for (path in metaData.paths.vals()) {
            for (nextPath in path.nextPathOptions.vals()) {
                if (pathIdMap.get(nextPath.pathId) == null) {
                    errors.add("Invalid pathId in path: " # nextPath.pathId);
                };
            };
        };

        if (errors.size() > 0) {
            #err(Buffer.toArray(errors));
        } else {
            #ok();
        };
    };

    // Check for path cycles
    func depthFirstSearch(
        pathId : Text,
        visitedPaths : HashMap.HashMap<Text, Bool>,
        pathIdMap : HashMap.HashMap<Text, ScenarioPath>,
        errors : Buffer.Buffer<Text>,
    ) : Bool {
        switch (visitedPaths.get(pathId)) {
            case (?true) { return false };
            case (?false) { return true };
            case (null) {
                visitedPaths.put(pathId, false);
                let ?path = pathIdMap.get(pathId) else {
                    errors.add("Invalid path id: " # pathId);
                    return false;
                };
                for (nextPath in path.nextPathOptions.vals()) {
                    if (depthFirstSearch(nextPath.pathId, visitedPaths, pathIdMap, errors)) {
                        return true;
                    };
                };
                visitedPaths.put(pathId, true);
                return false;
            };
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
            case (#race(_)) {};
            case (#class_(_)) {};
            case (#gold(gold)) {
                if (gold == 0) {
                    errors.add("Gold requirement must be greater than 0");
                };
            };
            case (#all(all)) {
                for (requirement in all.vals()) {
                    validateRequirement(requirement, items, errors);
                };
            };
            case (#any(any)) {
                for (requirement in any.vals()) {
                    validateRequirement(requirement, items, errors);
                };
            };
        };
    };

    func validateTextValue<T>(
        value : TextValue,
        map : HashMap.HashMap<Text, T>,
        kind : Text,
        dataFieldIdMap : HashMap.HashMap<Text, GeneratedDataField>,
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
            case (#dataField(fieldId)) {
                let ?field = dataFieldIdMap.get(fieldId) else {
                    errors.add("Invalid data field id: " # fieldId);
                    return;
                };
                let #text(text) = field.value else {
                    errors.add("Data field " # fieldId # " is not a text field");
                    return;
                };
                validateTextDataField(text, errors);
            };
        };
    };

    func validateTextDataField(text : GeneratedDataFieldText, errors : Buffer.Buffer<Text>) {
        for ((v, weight) in text.options.vals()) {
            if (weight <= 0.0) {
                errors.add("Weights must be greater than 0: " # Float.toText(weight));
            };
        };
    };

    func validateNatValue(
        value : NatValue,
        kind : Text,
        dataFieldIdMap : HashMap.HashMap<Text, GeneratedDataField>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (value) {
            case (#raw(_)) {};
            case (#random(min, max)) {
                if (min >= max) {
                    errors.add("Random " # kind # " min must be less than max: " # Nat.toText(min) # " >= " # Nat.toText(max));
                };
            };
            case (#dataField(fieldId)) {
                let ?field = dataFieldIdMap.get(fieldId) else {
                    errors.add("Invalid data field id: " # fieldId);
                    return;
                };
                let #nat(nat) = field.value else {
                    errors.add("Data field " # fieldId # " is not a nat field");
                    return;
                };
                validateNatDataField(nat, errors);
            };
        };
    };

    func validateNatDataField(nat : GeneratedDataFieldNat, errors : Buffer.Buffer<Text>) {
        if (nat.min >= nat.max) {
            errors.add("Generated data field min must be less than max: " # Nat.toText(nat.min) # " >= " # Nat.toText(nat.max));
        };
    };

    private func validateEffect(
        effect : Effect,
        items : HashMap.HashMap<Text, Item.Item>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
        dataFieldIdMap : HashMap.HashMap<Text, GeneratedDataField>,
        errors : Buffer.Buffer<Text>,
    ) {
        switch (effect) {
            case (#addItem(addItem)) {
                switch (addItem) {
                    case (#random) {};
                    case (#specific(specific)) validateTextValue(specific, items, "item", dataFieldIdMap, errors);
                };
            };
            case (#removeGold(removeGold)) validateNatValue(removeGold, "gold", dataFieldIdMap, errors);
            case (#removeItem(removeItem)) {
                switch (removeItem) {
                    case (#random) {};
                    case (#specific(specific)) validateTextValue(specific, items, "item", dataFieldIdMap, errors);
                };
            };
            case (#damage(damage)) validateNatValue(damage, "damage", dataFieldIdMap, errors);
            case (#heal(heal)) validateNatValue(heal, "heal", dataFieldIdMap, errors);
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
    ) : Bool {
        switch (requirement) {
            case (#all(reqs)) {
                for (req in reqs.vals()) {
                    if (not characterMeetsRequirement(req, character)) return false;
                };
                true;
            };
            case (#any(reqs)) {
                for (req in reqs.vals()) {
                    if (characterMeetsRequirement(req, character)) return true;
                };
                false;
            };
            case (#item(itemId)) IterTools.any(character.inventorySlots.vals(), func(slot : { itemId : ?Text }) : Bool = slot.itemId == ?itemId);
            case (#race(raceId)) character.raceId == raceId;
            case (#class_(classId)) character.classId == classId;
            case (#gold(amount)) character.gold >= amount;
        };
    };
};
