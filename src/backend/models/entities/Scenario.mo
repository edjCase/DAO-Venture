import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Float "mo:base/Float";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import TextX "mo:xtended-text/TextX";
import Trait "Trait";
import Item "Item";
import Zone "Zone";
import Achievement "Achievement";
import Creature "Creature";
import Entity "Entity";
import Outcome "../Outcome";
import Character "../Character";
import Image "../Image";
import UnlockRequirement "../UnlockRequirement";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Scenario = {
        id : Nat;
        metaDataId : Text;
        data : [GeneratedDataFieldInstance];
        outcome : ?Outcome.Outcome;
    };

    public type ScenarioMetaData = Entity.Entity and {
        location : LocationKind;
        imageId : Text;
        data : [GeneratedDataField];
        choices : [Choice];
        paths : [OutcomePath];
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

    public type GeneratedDataFieldInstance = {
        id : Text;
        value : GeneratedDataFieldInstanceValue;
    };

    public type GeneratedDataFieldInstanceValue = {
        #nat : Nat;
        #text : Text;
    };

    public type Choice = {
        id : Text;
        description : Text;
        pathId : Text;
        requirement : ?Outcome.ChoiceRequirement;
    };

    public type OutcomePath = {
        id : Text;
        description : Text;
        kind : OutcomePathKind;
        paths : [WeightedOutcomePath];
    };

    public type OutcomePathKind = {
        #effects : [Effect];
        #combat : CombatPath;
    };

    public type CombatPath = {
        creature : CombatCreatureKind;
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

    public type WeightedOutcomePath = {
        weight : Float;
        condition : ?Condition;
        pathId : Text;
    };

    public type Effect = {
        #reward;
        #damage : NatValue;
        #heal : NatValue;
        #upgradeStat : (Character.CharacterStatKind, NatValue);
        #removeGold : NatValue;
        #addItem : TextValue;
        #removeItem : RandomOrSpecificTextValue;
        #addTrait : TextValue;
        #removeTrait : RandomOrSpecificTextValue;
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
        #hasGold : NatValue;
        #hasItem : TextValue;
        #hasTrait : TextValue;
    };

    public func validateMetaData(
        metaData : ScenarioMetaData,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
        images : HashMap.HashMap<Text, Image.Image>,
        zones : HashMap.HashMap<Text, Zone.Zone>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
    ) : Result.Result<(), [Text]> {
        var errors = Buffer.Buffer<Text>(0);

        let dataFieldIdMap = HashMap.HashMap<Text, GeneratedDataField>(metaData.data.size(), Text.equal, Text.hash);
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

        // Check data fields
        for (field in metaData.data.vals()) {
            if (dataFieldIdMap.replace(field.id, field) != null) {
                errors.add("Duplicate data field id: " # field.id);
            };
        };

        func validateRequirement(requirement : Outcome.ChoiceRequirement) {
            switch (requirement) {
                case (#trait(traitId)) {
                    if (traits.get(traitId) == null) {
                        errors.add("Invalid trait id in choice requirement: " # traitId);
                    };
                };
                case (#item(itemId)) {
                    if (items.get(itemId) == null) {
                        errors.add("Invalid item id in choice requirement: " # itemId);
                    };
                };
                case (#race(_)) {};
                case (#class_(_)) {};
                case (#stat(_)) {};
                case (#gold(gold)) {
                    if (gold == 0) {
                        errors.add("Gold requirement must be greater than 0");
                    };
                };
                case (#all(all)) {
                    for (requirement in all.vals()) {
                        validateRequirement(requirement);
                    };
                };
                case (#any(any)) {
                    for (requirement in any.vals()) {
                        validateRequirement(requirement);
                    };
                };
            };
        };

        let choiceIdMap = HashMap.HashMap<Text, ()>(metaData.choices.size(), Text.equal, Text.hash);

        // Check choices
        for (choice in metaData.choices.vals()) {
            if (choiceIdMap.replace(choice.id, ()) == ?()) {
                errors.add("Duplicate choice id: " # choice.id);
            };
            switch (choice.requirement) {
                case (?requirement) validateRequirement(requirement);
                case (null) {};
            };
        };

        let pathIdMap = HashMap.HashMap<Text, OutcomePath>(metaData.paths.size(), Text.equal, Text.hash);
        // Check paths
        var visitedPaths = HashMap.HashMap<Text, Bool>(0, Text.equal, Text.hash);
        for (path in metaData.paths.vals()) {
            if (pathIdMap.replace(path.id, path) != null) {
                errors.add("Duplicate path id: " # path.id);
            };

            func validateTextValue<T>(value : TextValue, map : HashMap.HashMap<Text, T>, kind : Text) {
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
                        validateTextDataField(text);
                    };
                };
            };

            func validateTextDataField(text : GeneratedDataFieldText) {
                for ((v, weight) in text.options.vals()) {
                    if (weight <= 0.0) {
                        errors.add("Weights must be greater than 0: " # Float.toText(weight));
                    };
                };
            };

            func validateNatValue(value : NatValue, kind : Text) {
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
                        validateNatDataField(nat);
                    };
                };
            };

            func validateNatDataField(nat : GeneratedDataFieldNat) {
                if (nat.min >= nat.max) {
                    errors.add("Generated data field min must be less than max: " # Nat.toText(nat.min) # " >= " # Nat.toText(nat.max));
                };
            };

            switch (path.kind) {
                case (#combat(combat)) {
                    switch (combat.creature) {
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
                case (#effects(effects)) {
                    for (effect in effects.vals()) {
                        switch (effect) {
                            case (#addItem(addItem)) validateTextValue(addItem, items, "item");
                            case (#addTrait(addTrait)) validateTextValue(addTrait, traits, "trait");
                            case (#removeGold(removeGold)) validateNatValue(removeGold, "gold");
                            case (#removeItem(removeItem)) {
                                switch (removeItem) {
                                    case (#random) {};
                                    case (#specific(specific)) validateTextValue(specific, items, "item");
                                };
                            };
                            case (#removeTrait(removeTrait)) {
                                switch (removeTrait) {
                                    case (#random) {};
                                    case (#specific(specific)) validateTextValue(specific, traits, "trait");
                                };
                            };
                            case (#damage(damage)) validateNatValue(damage, "damage");
                            case (#heal(heal)) validateNatValue(heal, "heal");
                            case (#reward) {};
                            case (#upgradeStat(upgradeStat)) validateNatValue(upgradeStat.1, "stat");
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
                };
            };
        };

        // Check for path cycles
        func dfs(pathId : Text) : Bool {
            switch (visitedPaths.get(pathId)) {
                case (?true) { return false };
                case (?false) { return true };
                case (null) {
                    visitedPaths.put(pathId, false);
                    let ?path = pathIdMap.get(pathId) else {
                        errors.add("Invalid path id: " # pathId);
                        return false;
                    };
                    for (nextPath in path.paths.vals()) {
                        if (dfs(nextPath.pathId)) {
                            return true;
                        };
                    };
                    visitedPaths.put(pathId, true);
                    return false;
                };
            };
        };

        for (path in metaData.paths.vals()) {
            if (dfs(path.id)) {
                errors.add("Cycle detected in paths starting from: " # path.id);
            };
        };

        // Check if all referenced pathIdMap exist
        for (choice in metaData.choices.vals()) {
            if (pathIdMap.get(choice.pathId) == null) {
                errors.add("Invalid pathId in choice: " # choice.pathId);
            };
        };

        for (path in metaData.paths.vals()) {
            for (nextPath in path.paths.vals()) {
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
};
