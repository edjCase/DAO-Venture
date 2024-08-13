import Outcome "../models/Outcome";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Item "../models/Item";
import CharacterHandler "CharacterHandler";

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

        public func takeDamage(amount : Nat) : { #alive; #dead } {
            messages.add("You take " # Nat.toText(amount) # " damage.");
            characterHandler.takeDamage(amount);
        };

        public func reward() {
            type Reward = {
                #item : Item.Item;
                #money : Nat;
            };
            messages.add("You find a reward!");
            // TODO reward table
            let weightedRewardTable : [(Reward, Float)] = [
                (#money(1), 20.0),
                (#money(10), 15.0),
                (#item(#echoCrystal), 1.0),
            ];
            switch (prng.nextArrayElementWeighted(weightedRewardTable)) {
                case (#money(amount)) addGold(amount);
                case (#item(item)) addItem(item);
            };
        };

        public func addItem(item : Item.Item) {
            messages.add("You get " # Item.toText(item));
            characterHandler.addItem(item);
        };

        public func addGold(amount : Nat) {
            messages.add("You get " # Nat.toText(amount) # " gold");
            characterHandler.addGold(amount);
        };
    };
};
