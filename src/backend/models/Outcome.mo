import Text "mo:base/Text";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Character "Character";
module {

    public type Outcome = {
        choiceOrUndecided : ?Text;
        messages : [Text];
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #stat : (Character.CharacterStatKind, Nat);
        #item : Text;
        #trait : Text;
        #race : Text;
        #class_ : Text;
        #gold : Nat;
    };

    public func validateRequirement(
        requirement : ChoiceRequirement,
        character : Character.Character,
    ) : Bool {
        switch (requirement) {
            case (#all(reqs)) {
                for (req in reqs.vals()) {
                    if (not validateRequirement(req, character)) return false;
                };
                true;
            };
            case (#any(reqs)) {
                for (req in reqs.vals()) {
                    if (validateRequirement(req, character)) return true;
                };
                false;
            };
            case (#stat(statKind, value)) {
                switch (statKind) {
                    case (#attack) character.stats.attack >= value;
                    case (#defense) character.stats.defense >= value;
                    case (#speed) character.stats.speed >= value;
                    case (#magic) character.stats.magic >= value;
                };
            };
            case (#item(itemId)) TrieSet.mem(character.itemIds, itemId, Text.hash(itemId), Text.equal);
            case (#trait(traitId)) TrieSet.mem(character.traitIds, traitId, Text.hash(traitId), Text.equal);
            case (#race(raceId)) character.raceId == raceId;
            case (#class_(classId)) character.classId == classId;
            case (#gold(amount)) character.gold >= amount;
        };
    };
};
