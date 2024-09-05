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
        var gold : Nat;
        var statusEffects : Buffer.Buffer<ActionResult.StatusEffectResult>;
    };

    public func calculateAction(
        prng : Prng,
        actionSource : ActionResult.ActionTargetResult,
        action : Action.Action,
        creatureCount : Nat,
        chosenTarget : ?ActionResult.ActionTargetResult,
    ) : Result.Result<ActionResult.ActionResult, { #invalidTarget; #targetRequired }> {
        let effectResults = Buffer.Buffer<ActionResult.ActionEffectResult>(0);

        for (effect in action.effects.vals()) {
            let effectResult = switch (effect.kind) {
                case (#damage(damage)) calculateDamage(prng, damage);
                case (#block(block)) calculateBlock(prng, block);
                case (#heal(heal)) calculateHeal(prng, heal);
                case (#addStatusEffect(statusEffect)) calculateStatusEffect(statusEffect);
            };

            let allValidTargets = switch (
                calculateAllValidTargets(
                    actionSource,
                    effect.target.scope,
                    creatureCount,
                    chosenTarget,
                )
            ) {
                case (#err(err)) return #err(err);
                case (#ok(targets)) targets;
            };

            let targets = switch (effect.target.selection) {
                case (#all) Buffer.toArray(allValidTargets);
                case (#random({ count })) {
                    let trueCount = Nat.min(count, creatureCount);
                    prng.shuffleBuffer(allValidTargets);
                    Buffer.toArray(Buffer.subBuffer(allValidTargets, 0, trueCount));
                };
                case (#chosen) {
                    switch (chosenTarget) {
                        case (null) return #err(#targetRequired);
                        case (?target) [target];
                    };
                };
            };

            effectResults.add({
                targets = targets;
                kind = effectResult;
            });
        };

        #ok({
            effects = Buffer.toArray(effectResults);
        });
    };

    public func tickEffects(stats : [CombatStats]) : () {
        for (combatStats in stats.vals()) {
            let currentEffects = combatStats.statusEffects;
            let newEffects = Buffer.Buffer<ActionResult.StatusEffectResult>(currentEffects.size());

            for (effect in currentEffects.vals()) {
                switch (effect.remainingTurns) {
                    case (0) (); // Remove (not add) the effect
                    case (remainingTurns) {
                        // Decrement the remaining turns and keep the effect
                        newEffects.add({
                            kind = effect.kind;
                            remainingTurns = remainingTurns - 1;
                        });
                    };
                };
            };

            combatStats.statusEffects := newEffects;
        };
    };

    public func applyAction(
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
                    case (#damage(damageResult)) applyDamage(stats, damageResult);
                    case (#block(blockResult)) applyBlock(stats, blockResult);
                    case (#heal(healResult)) applyHeal(stats, healResult);
                    case (#addStatusEffect(statusEffectResult)) applyStatusEffect(stats, statusEffectResult);
                };
            };
        };
    };

    private func applyDamage(stats : CombatStats, damageResult : ActionResult.DamageResult) : () {
        stats.health := subtractNatSafe(stats.health, damageResult.amount);
    };

    private func applyBlock(stats : CombatStats, blockResult : ActionResult.BlockResult) : () {
        stats.shield += blockResult.amount;
    };

    private func applyHeal(stats : CombatStats, healResult : ActionResult.HealResult) : () {
        stats.health := Nat.min(stats.health + healResult.amount, stats.maxHealth);
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
        let amount = prng.nextNat(damage.min, damage.max);
        #damage({ amount = amount; delay = calculateDelay(damage.timing) });
    };

    private func calculateBlock(prng : Prng, block : Action.Block) : ActionResult.ActionEffectKindResult {
        let amount = prng.nextNat(block.min, block.max);
        #block({ amount = amount; delay = calculateDelay(block.timing) });
    };

    private func calculateHeal(prng : Prng, heal : Action.Heal) : ActionResult.ActionEffectKindResult {
        let amount = prng.nextNat(heal.min, heal.max);
        #heal({ amount = amount; delay = calculateDelay(heal.timing) });
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

    private func calculateDelay(timing : Action.ActionTimingKind) : ?ActionResult.CastDelay {
        switch (timing) {
            case (#immediate) null;
            case (#periodic(periodicTiming)) ?{
                turns = periodicTiming.remainingTurns;
                kind = periodicTiming;
            };
        };
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
