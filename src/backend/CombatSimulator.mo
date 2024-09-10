import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import ActionResult "models/ActionResult";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Action "models/entities/Action";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type CombatStats = {
        var health : Nat;
        var maxHealth : Nat;
        var shield : Nat;
        var statusEffects : Buffer.Buffer<ActionResult.StatusEffectResult>;
    };

    public func calculateActionResult(
        prng : Prng,
        actionSource : ActionResult.ActionTargetResult,
        action : Action.Action,
        creatureCount : Nat,
        chosenTarget : ?ActionResult.ActionTargetResult,
    ) : Result.Result<ActionResult.ActionResult, { #invalidTarget; #targetRequired }> {
        let effectResults = Buffer.Buffer<ActionResult.ActionEffectResult>(0);

        let allValidTargets = switch (
            calculateAllValidTargets(
                actionSource,
                action.target.scope,
                creatureCount,
                chosenTarget,
            )
        ) {
            case (#err(err)) return #err(err);
            case (#ok(targets)) targets;
        };

        let actionTargets = switch (action.target.selection) {
            case (#all) Buffer.toArray(allValidTargets);
            case (#random({ count })) {
                let trueCount = Nat.min(count, creatureCount);
                prng.shuffleBuffer(allValidTargets);
                Buffer.toArray(Buffer.subBuffer(allValidTargets, 0, trueCount));
            };
            case (#chosen) {
                switch (chosenTarget) {
                    case (?target) [target];
                    case (null) {
                        switch (actionSource) {
                            case (#character) return #err(#targetRequired);
                            case (#creature(_)) {
                                // Creatures select randomly from all valid targets
                                [prng.nextBufferElement(allValidTargets)];
                            };
                        };
                    };
                };
            };
        };

        for (effect in action.effects.vals()) {
            let effectResult = switch (effect.kind) {
                case (#damage(damage)) calculateDamage(prng, damage);
                case (#block(block)) calculateBlock(prng, block);
                case (#heal(heal)) calculateHeal(prng, heal);
                case (#addStatusEffect(statusEffect)) calculateStatusEffect(statusEffect);
            };

            let effectTargets = switch (effect.target) {
                case (#self) [actionSource];
                case (#targets) actionTargets;
            };

            effectResults.add({
                targets = effectTargets;
                kind = effectResult;
            });
        };

        #ok({
            effects = Buffer.toArray(effectResults);
        });
    };

    public func triggerEffects(stats : [CombatStats], phase : Action.TurnPhase) : () {
        for (combatStats in stats.vals()) {
            for (effect in combatStats.statusEffects.vals()) {
                switch (effect.kind) {
                    case (#vulnerable or #weak or #stunned or #retaliating(_)) (); // No direct effect to trigger
                    case (#periodic(periodic)) {
                        if (periodic.phase == phase) {
                            switch (periodic.kind) {
                                case (#damage) applyDamage(combatStats, periodic.amount);
                                case (#heal) applyHeal(combatStats, periodic.amount);
                                case (#block) applyBlock(combatStats, periodic.amount);
                            };
                        };
                    };
                };
            };
        };
    };

    public func decrementEffectTurns(stats : [CombatStats]) : () {
        for (combatStats in stats.vals()) {
            let newEffects = Buffer.Buffer<ActionResult.StatusEffectResult>(combatStats.statusEffects.size());

            for (effect in combatStats.statusEffects.vals()) {
                if (effect.remainingTurns > 0) {
                    // Decrement the remaining turns and keep the effect
                    newEffects.add({
                        kind = effect.kind;
                        remainingTurns = effect.remainingTurns - 1;
                    });
                };
            };

            combatStats.statusEffects := newEffects;
        };
    };

    public func applyActionResult(
        character : CombatStats,
        creatures : [CombatStats],
        action : ActionResult.ActionResult,
    ) : () {
        for (effect in action.effects.vals()) {
            for (target in effect.targets.vals()) {
                let stats = switch (target) {
                    case (#creature(creatureIndex)) creatures[creatureIndex];
                    case (#character) character;
                };
                switch (effect.kind) {
                    case (#damage(damage)) applyDamage(stats, damage);
                    case (#block(block)) applyBlock(stats, block);
                    case (#heal(heal)) applyHeal(stats, heal);
                    case (#addStatusEffect(statusEffectResult)) applyStatusEffect(stats, statusEffectResult);
                };
            };
        };
    };

    private func applyDamage(stats : CombatStats, amount : Nat) : () {
        stats.health := subtractNatSafe(stats.health, amount);
    };

    private func applyBlock(stats : CombatStats, amount : Nat) : () {
        stats.shield += amount;
    };

    private func applyHeal(stats : CombatStats, amount : Nat) : () {
        stats.health := Nat.min(stats.health + amount, stats.maxHealth);
    };

    private func applyStatusEffect(stats : CombatStats, statusEffectResult : ActionResult.StatusEffectResult) : () {
        stats.statusEffects.add(statusEffectResult);
    };

    private func subtractNatSafe(a : Nat, b : Nat) : Nat {
        if (a < b) {
            return 0;
        };
        return a - b;
    };

    private func calculateDamage(prng : Prng, damage : Action.Damage) : ActionResult.ActionEffectKindResult {
        #damage(calculateMinMaxAmount(prng, damage));
    };

    private func calculateBlock(prng : Prng, block : Action.Block) : ActionResult.ActionEffectKindResult {
        #block(calculateMinMaxAmount(prng, block));
    };

    private func calculateHeal(prng : Prng, heal : Action.Heal) : ActionResult.ActionEffectKindResult {
        #heal(calculateMinMaxAmount(prng, heal));
    };

    private func calculateMinMaxAmount(prng : Prng, amount : { min : Nat; max : Nat }) : Nat {
        if (amount.min >= amount.max) {
            return amount.min; // No need for random, just the raw value if no variance
        };
        prng.nextNat(amount.min, amount.max);
    };

    private func calculateStatusEffect(statusEffect : Action.StatusEffect) : ActionResult.ActionEffectKindResult {
        #addStatusEffect({
            kind = statusEffect.kind;
            remainingTurns = switch (statusEffect.duration) {
                case (null) 0;
                case (?duration) duration;
            };
        });
    };

    private func calculateAllValidTargets(
        actionSource : ActionResult.ActionTargetResult,
        scope : Action.ActionTargetScope,
        creatureCount : Nat,
        chosenTarget : ?ActionResult.ActionTargetResult,
    ) : Result.Result<Buffer.Buffer<ActionResult.ActionTargetResult>, { #invalidTarget }> {
        let allCreatures = Array.tabulate<ActionResult.ActionTargetResult>(creatureCount, func(i) { #creature(i) });
        let allTargets = Buffer.Buffer<ActionResult.ActionTargetResult>(creatureCount + 1);

        switch (scope) {
            case (#any) {
                allTargets.append(Buffer.fromArray(allCreatures));
                allTargets.add(#character);
            };
            case (#ally) {
                switch (actionSource) {
                    case (#creature(_)) {
                        allTargets.append(Buffer.fromArray(allCreatures));
                        switch (chosenTarget) {
                            case (null) ();
                            case (?target) {
                                switch (target) {
                                    case (#creature(_)) ();
                                    case (#character) return #err(#invalidTarget);
                                };
                            };
                        };
                    };
                    case (#character) {
                        allTargets.add(#character);
                        switch (chosenTarget) {
                            case (null) ();
                            case (?target) {
                                switch (target) {
                                    case (#creature(_)) return #err(#invalidTarget);
                                    case (#character) ();
                                };
                            };
                        };
                    };
                };
            };
            case (#enemy) {
                switch (actionSource) {
                    case (#creature(_)) {
                        allTargets.add(#character);
                        switch (chosenTarget) {
                            case (null) ();
                            case (?target) {
                                switch (target) {
                                    case (#creature(_)) return #err(#invalidTarget);
                                    case (#character) ();
                                };
                            };
                        };
                    };
                    case (#character) {
                        allTargets.append(Buffer.fromArray(allCreatures));
                        switch (chosenTarget) {
                            case (null) ();
                            case (?target) {
                                switch (target) {
                                    case (#creature(_)) ();
                                    case (#character) return #err(#invalidTarget);
                                };
                            };
                        };
                    };
                };
            };
        };
        #ok(allTargets);
    };
};
