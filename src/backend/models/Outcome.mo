import Text "mo:base/Text";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Character "Character";
module {

    public type Outcome = {
        choiceId : Text;
        log : [OutcomeLogEntry];
    };

    public type OutcomeLogEntry = {
        #text : Text;
        #combat : CombatResult;
        #healthDelta : Int;
        #maxHealthDelta : Int;
        #attackDelta : Int;
        #defenseDelta : Int;
        #speedDelta : Int;
        #magicDelta : Int;
        #goldDelta : Int;
        #addItem : Text;
        #removeItem : Text;
        #addTrait : Text;
        #removeTrait : Text;
    };

    public type CombatResult = {
        turns : [CombatTurn];
        healthDelta : Int;
        kind : CombatResultKind;
    };

    public type CombatResultKind = {
        #victory;
        #defeat;
        #maxTurnsReached;
    };

    public type CombatTurn = {
        attacker : AttackerKind;
        attacks : [AttackResult];
    };

    public type AttackerKind = {
        #character;
        #creature;
    };

    public type AttackResult = {
        #hit : HitResult;
        #miss;
    };

    public type HitResult = {
        damage : Nat;
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
                    case (#attack) character.attack >= value;
                    case (#defense) character.defense >= value;
                    case (#speed) character.speed >= value;
                    case (#magic) character.magic >= value;
                    case (#maxHealth) character.maxHealth >= value;
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
