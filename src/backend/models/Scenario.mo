import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "Outcome";
import TextX "mo:xtended-text/TextX";
import Character "Character";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Scenario = {
        id : Nat;
        metaDataId : Text;
        data : [GeneratedDataFieldInstance];
        outcome : ?Outcome.Outcome;
    };

    public type ScenarioMetaData = {
        id : Text;
        title : Text;
        description : Text;
        data : [GeneratedDataField];
        choices : [Choice];
        paths : [OutcomePath];
        undecidedPathId : Text;
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
        effects : [Effect];
        paths : [WeightedOutcomePath];
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
        allTraitIds : [Text],
        allItemIds : [Text],
    ) : Result.Result<(), [Text]> {
        var errors = Buffer.Buffer<Text>(0);
        let traitIdMap = allTraitIds.vals()
        |> Iter.map<Text, (Text, ())>(_, func(traitId : Text) : (Text, ()) = (traitId, ()))
        |> HashMap.fromIter<Text, ()>(_, allTraitIds.size(), Text.equal, Text.hash);

        let itemIdMap = allItemIds.vals()
        |> Iter.map<Text, (Text, ())>(_, func(itemId : Text) : (Text, ()) = (itemId, ()))
        |> HashMap.fromIter<Text, ()>(_, allItemIds.size(), Text.equal, Text.hash);

        let dataFieldIdMap = HashMap.HashMap<Text, GeneratedDataField>(metaData.data.size(), Text.equal, Text.hash);
        // Check id and description
        if (TextX.isEmpty(metaData.id)) {
            errors.add("Scenario id is empty");
        };
        if (TextX.isEmpty(metaData.title)) {
            errors.add("Scenario title is empty");
        };
        if (TextX.isEmpty(metaData.description)) {
            errors.add("Scenario description is empty");
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
                    if (traitIdMap.get(traitId) == null) {
                        errors.add("Invalid trait id in choice requirement: " # traitId);
                    };
                };
                case (#item(itemId)) {
                    if (itemIdMap.get(itemId) == null) {
                        errors.add("Invalid item id in choice requirement: " # itemId);
                    };
                };
                case (#stat(_)) {};
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

            func validateTextValue(value : TextValue, map : HashMap.HashMap<Text, ()>, kind : Text) {
                switch (value) {
                    case (#raw(raw)) {
                        if (map.get(raw) == null) {
                            errors.add("Invalid " # kind # ": " # raw);
                        };
                    };
                    case (#weighted(weighted)) {
                        for ((v, weight) in weighted.vals()) {
                            if (map.get(v) == null) {
                                errors.add("Invalid " # kind # ": " # v);
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

            for (effect in path.effects.vals()) {
                switch (effect) {
                    case (#addItem(addItem)) validateTextValue(addItem, itemIdMap, "item");
                    case (#addTrait(addTrait)) validateTextValue(addTrait, traitIdMap, "trait");
                    case (#removeGold(removeGold)) validateNatValue(removeGold, "gold");
                    case (#removeItem(removeItem)) {
                        switch (removeItem) {
                            case (#random) {};
                            case (#specific(specific)) validateTextValue(specific, itemIdMap, "item");
                        };
                    };
                    case (#removeTrait(removeTrait)) {
                        switch (removeTrait) {
                            case (#random) {};
                            case (#specific(specific)) validateTextValue(specific, traitIdMap, "trait");
                        };
                    };
                    case (#damage(damage)) validateNatValue(damage, "damage");
                    case (#heal(heal)) validateNatValue(heal, "heal");
                    case (#reward) {};
                    case (#upgradeStat(upgradeStat)) validateNatValue(upgradeStat.1, "stat");
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

        if (pathIdMap.get(metaData.undecidedPathId) == null) {
            errors.add("Invalid undecidedPathId: " # metaData.undecidedPathId);
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
