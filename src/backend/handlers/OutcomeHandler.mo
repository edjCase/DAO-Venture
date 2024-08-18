import Outcome "../models/Outcome";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import CharacterHandler "CharacterHandler";
import Character "../models/Character";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public class Handler(
        prng : Prng,
        characterHandler : CharacterHandler.Handler,
    ) : Outcome.Processor {
        let messages = Buffer.Buffer<Text>(1);

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
