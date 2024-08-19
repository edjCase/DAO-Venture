import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import CharacterHandler "handlers/CharacterHandler";
import Outcome "models/Outcome";
import Scenario "models/Scenario";
import Character "models/Character";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func run(
        prng : Prng,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        scenarioMetaData : Scenario.ScenarioMetaData,
        choiceOrUndecided : ?Text,
    ) : Outcome.Outcome {
        let messages = Buffer.Buffer<Text>(5);
        let helper = Helper(prng, characterHandler, scenario, messages);

        let initialPathId = switch (choiceOrUndecided) {
            case (null) { scenarioMetaData.undecidedPathId };
            case (?choice) {
                let ?choiceData = Array.find(
                    scenarioMetaData.choices,
                    func(c : Scenario.Choice) : Bool { c.id == choice },
                ) else Debug.trap("Invalid choice: " # choice);
                choiceData.pathId;
            };
        };

        var currentPathId = initialPathId;

        label l loop {
            let ?currentPath = Array.find(
                scenarioMetaData.paths,
                func(p : Scenario.OutcomePath) : Bool { p.id == currentPathId },
            ) else Debug.trap("Invalid path ID: " # currentPathId);
            helper.log(currentPath.description);

            for (effect in currentPath.effects.vals()) {
                switch (helper.applyEffect(effect)) {
                    case (#alive) (); // Continue
                    case (#dead) {
                        return {
                            messages = Buffer.toArray(messages);
                            choiceOrUndecided = choiceOrUndecided;
                        };
                    };
                };
            };

            if (currentPath.paths.size() == 0) {
                break l;
            };

            let validPaths = Array.filter(
                currentPath.paths,
                func(p : Scenario.WeightedOutcomePath) : Bool {
                    switch (p.condition) {
                        case (null) true;
                        case (?condition) helper.meetsCondition(condition);
                    };
                },
            );

            if (validPaths.size() == 0) {
                break l;
            };
            let pathsWithWeights = Array.map<Scenario.WeightedOutcomePath, (Text, Float)>(
                validPaths,
                func(p : Scenario.WeightedOutcomePath) : (Text, Float) {
                    (p.pathId, p.weight);
                },
            );
            let nextPathId = prng.nextArrayElementWeighted(pathsWithWeights);
            currentPathId := nextPathId;
        };
        {
            messages = Buffer.toArray(messages);
            choiceOrUndecided = choiceOrUndecided;
        };
    };

    func getNatValue(
        prng : Prng,
        value : Scenario.NatValue,
        data : [Scenario.GeneratedDataFieldInstance],
    ) : Nat {
        switch (value) {
            case (#raw(n)) n;
            case (#random(min, max)) prng.nextNat(min, max);
            case (#dataField(id)) {
                let ?dataField = Array.find(
                    data,
                    func(d : Scenario.GeneratedDataFieldInstance) : Bool {
                        d.id == id;
                    },
                ) else Debug.trap("Data field not found: " # id);
                let #nat(value) = dataField.value else Debug.trap("Data field is not a Nat: " # id);
                value;
            };
        };
    };

    func getTextValue(
        prng : Prng,
        value : Scenario.TextValue,
        data : [Scenario.GeneratedDataFieldInstance],
    ) : Text {
        switch (value) {
            case (#raw(t)) t;
            case (#weighted(options)) prng.nextArrayElementWeighted(options);
            case (#dataField(id)) {
                let ?dataField = Array.find(data, func(d : Scenario.GeneratedDataFieldInstance) : Bool { d.id == id }) else Debug.trap("Data field not found: " # id);
                let #text(value) = dataField.value else Debug.trap("Data field is not a Text: " # id);
                value;
            };
        };
    };

    private class Helper(
        prng : Prng,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        messages : Buffer.Buffer<Text>,
    ) {

        public func meetsCondition(condition : Scenario.Condition) : Bool {
            let character = characterHandler.get();
            switch (condition) {
                case (#hasGold(amountValue)) {
                    let amount = getNatValue(prng, amountValue, scenario.data);
                    character.gold >= amount;
                };
                case (#hasItem(itemValue)) {
                    let itemId = getTextValue(prng, itemValue, scenario.data);
                    TrieSet.mem(character.itemIds, itemId, Text.hash(itemId), Text.equal);
                };
                case (#hasTrait(traitValue)) {
                    let traitId = getTextValue(prng, traitValue, scenario.data);
                    TrieSet.mem(character.traitIds, traitId, Text.hash(traitId), Text.equal);
                };
            };
        };

        public func applyEffect(effect : Scenario.Effect) : { #alive; #dead } {
            switch (effect) {
                case (#reward) reward();
                case (#damage(amount)) {
                    let damageAmount = getNatValue(prng, amount, scenario.data);
                    if (not takeDamage(damageAmount)) return #dead;
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount, scenario.data));
                };
                case (#upgradeStat((stat, amount))) {
                    upgradeStat(stat, getNatValue(prng, amount, scenario.data));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount, scenario.data));
                };
                case (#addItem(item)) {
                    ignore addItem(getTextValue(prng, item, scenario.data));
                };
                case (#removeItem(item)) {
                    switch (item) {
                        case (#random) {
                            ignore loseRandomItem();
                        };
                        case (#specific(itemId)) {
                            ignore removeItem(getTextValue(prng, itemId, scenario.data));
                        };
                    };
                };
                case (#addTrait(trait)) {
                    ignore addTrait(getTextValue(prng, trait, scenario.data));
                };
                case (#removeTrait(trait)) {
                    switch (trait) {
                        case (#random) {
                            /* TODO: Implement random trait removal */
                        };
                        case (#specific(traitId)) {
                            ignore removeTrait(getTextValue(prng, traitId, scenario.data));
                        };
                    };
                };
            };
            #alive;
        };

        public func log(message : Text) {
            messages.add(message);
        };

        public func takeDamage(amount : Nat) : Bool {
            messages.add("You take " # Nat.toText(amount) # " damage.");
            characterHandler.takeDamage(amount);
        };

        public func heal(amount : Nat) {
            messages.add("You heal " # Nat.toText(amount) # " health.");
            characterHandler.heal(amount);
        };

        public func addItem(item : Text) : Bool {
            messages.add("You get " # item);
            characterHandler.addItem(item);
        };

        public func removeItem(item : Text) : Bool {
            messages.add("You lose " # item);
            characterHandler.removeItem(item);
        };

        public func loseRandomItem() : Bool {
            let items = characterHandler.getItems();
            if (TrieSet.size(items) < 1) return false;
            let randomItem = prng.nextArrayElement(TrieSet.toArray(items));
            removeItem(randomItem);
        };

        public func addGold(amount : Nat) {
            messages.add("You get " # Nat.toText(amount) # " gold");
            characterHandler.addGold(amount);
        };

        public func upgradeStat(kind : Character.CharacterStatKind, amount : Nat) {
            messages.add("You upgrade your " # Character.toTextStatKind(kind) # " stat by " # Nat.toText(amount));
            characterHandler.upgradeStat(kind, amount);
        };

        type Reward = {
            #item : Text;
            #money : Nat;
        };
        // TODO reward table
        let weightedRewardTable : [(Reward, Float)] = [
            (#money(1), 20.0),
            (#money(10), 15.0),
            (#item("echoCrystal"), 1.0),
        ];
        public func reward() {
            log("You find a reward!");
            switch (prng.nextArrayElementWeighted(weightedRewardTable)) {
                case (#money(amount)) addGold(amount);
                case (#item(item)) ignore addItem(item); // TODO already have item?
            };
        };

        public func removeGold(amount : Nat) : Bool {
            if (characterHandler.removeGold(amount)) {
                messages.add("You lose " # Nat.toText(amount) # " gold");
                return true;
            } else {
                messages.add("You don't have enough gold to lose " # Nat.toText(amount));
                return false;
            };
        };

        public func addTrait(trait : Text) : Bool {
            messages.add("You gain the trait " # trait);
            characterHandler.addTrait(trait);
        };

        public func removeTrait(trait : Text) : Bool {
            messages.add("You lose the trait " # trait);
            characterHandler.removeTrait(trait);
        };

        public func getMessages() : [Text] {
            Buffer.toArray(messages);
        };
    };
};
