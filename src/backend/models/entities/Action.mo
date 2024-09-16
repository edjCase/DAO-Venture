import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Entity "Entity";

module {

    public type Action = Entity.Entity and {
        target : ActionTarget;
        combatEffects : [CombatEffect];
        scenarioEffects : [ScenarioEffect];
    };

    public type ScenarioEffect = {
        #attribute : AttributeScenarioEffect;
    };

    public type Attribute = {
        #wisdom;
        #strength;
        #dexterity;
        #charisma;
    };

    public type AttributeScenarioEffect = {
        attribute : Attribute;
        value : Int;
    };

    public type CombatEffect = {
        target : CombatEffectTarget;
        kind : CombatEffectKind;
    };

    public type CombatEffectTarget = {
        #self;
        #targets;
    };

    public type CombatEffectKind = {
        #damage : Damage;
        #block : Block;
        #heal : Heal;
        #addStatusEffect : StatusEffect;
    };

    public type ActionTarget = {
        scope : ActionTargetScope;
        selection : ActionTargetSelection;
    };

    public type ActionTargetScope = {
        #ally;
        #enemy;
        #any;
    };

    public type ActionTargetSelection = {
        #random : {
            count : Nat;
        };
        #chosen;
        // #positions : [Position]; // TODO
        #all;
    };

    type MinMax = {
        min : Nat;
        max : Nat;
    };

    type DBN = MinMax and {
        timing : ActionTimingKind;
    };

    public type Damage = DBN;

    public type Block = DBN;

    public type Heal = DBN;

    public type ActionTimingKind = {
        #immediate;
        #periodic : PeriodicTiming;
    };

    public type PeriodicTiming = {
        phase : TurnPhase;
        turnDuration : Nat;
    };

    public type TurnPhase = {
        #start;
        #end;
    };

    public type StatusEffect = {
        kind : StatusEffectKind;
        duration : ?Nat;
    };

    public type StatusEffectKind = {
        #vulnerable;
        #weak;
        #stunned;
        #retaliating : Retaliating;
        #brittle;
        #necrotic;
    };

    public type Retaliating = {
        #flat : Nat;
    };

    public func validate(action : Action) : Result.Result<(), [Text]> {
        var errors = Buffer.Buffer<Text>(0);

        Entity.validate("action", action, errors);

        // Validate combat effects
        for (effect in action.combatEffects.vals()) {
            switch (effect.kind) {
                case (#damage(damage)) {
                    if (damage.max < damage.min) {
                        errors.add("Damage max must be greater than or equal to min");
                    };
                };
                case (#heal(heal)) {
                    if (heal.max < heal.min) {
                        errors.add("Heal max must be greater than or equal to min");
                    };
                };
                case (#block(block)) {
                    if (block.max < block.min) {
                        errors.add("Block max must be greater than or equal to min");
                    };
                };
                case (#addStatusEffect(statusEffect)) {
                    switch (statusEffect.duration) {
                        case (null) ();
                        case (?duration) {
                            if (duration == 0) {
                                errors.add("Status effect duration cannot be zero");
                            };
                        };
                    };
                    switch (statusEffect.kind) {
                        case (#vulnerable or #stunned or #weak or #brittle or #necrotic) {};
                        case (#retaliating(retaliating)) {
                            switch (retaliating) {
                                case (#flat(flat)) {
                                    if (flat == 0) {
                                        errors.add("Retaliating effect cannot be zero");
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };

        // Validate scenario effects
        for (effect in action.scenarioEffects.vals()) {
            switch (effect) {
                case (#attribute(attribute)) {
                    if (attribute.value == 0) {
                        errors.add("Attribute effect value cannot be zero");
                    };
                };
            };
        };

        // Validate target
        switch (action.target.selection) {
            case (#chosen or #all) ();
            case (#random(random)) {
                if (random.count == 0) {
                    errors.add("Random target count cannot be zero");
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
