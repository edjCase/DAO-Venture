import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import ActionResult "models/ActionResult";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Prelude "mo:base/Prelude";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Action "models/entities/Action";
import Scenario "models/entities/Scenario";
import IterTools "mo:itertools/Iter";
import ScenarioMetaData "models/entities/ScenarioMetaData";
import Character "models/Character";
import Creature "models/entities/Creature";
import Race "models/entities/Race";
import Item "models/entities/Item";
import Weapon "models/entities/Weapon";
import Class "models/entities/Class";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type CombatStats = {
        var health : Nat;
        var maxHealth : Nat;
        var block : Nat;
        var statusEffects : Buffer.Buffer<ActionResult.StatusEffectResult>;
    };
    public type CombatChoice = {
        actionId : Text;
        target : ?ActionResult.ActionTargetResult;
    };

    public type GameContent = {
        actions : HashMap.HashMap<Text, Action.Action>;
        creatures : HashMap.HashMap<Text, Creature.Creature>;
        classes : HashMap.HashMap<Text, Class.Class>;
        races : HashMap.HashMap<Text, Race.Race>;
        items : HashMap.HashMap<Text, Item.Item>;
        weapons : HashMap.HashMap<Text, Weapon.Weapon>;
    };

    public func startCombat(
        prng : Prng,
        combat : ScenarioMetaData.CombatPath,
        character : Character.Character,
        gameContent : GameContent,
    ) : Scenario.CombatScenarioState {
        let creatureCombatStats = Buffer.Buffer<Scenario.CreatureCombatState>(combat.creatures.size());
        for (creature in combat.creatures.vals()) {
            creatureCombatStats.add(getRandomCreature(prng, creature, gameContent));
        };
        let newActionIds = getRandomCharacterActionIds(prng, character, gameContent);
        {
            character = {
                health = character.health;
                maxHealth = character.maxHealth;
                block = 0;
                statusEffects = [];
                availableActionIds = newActionIds;
            };
            creatures = Buffer.toArray(creatureCombatStats);
            nextPath = combat.nextPath;
        };
    };

    public func run(
        state : Scenario.CombatScenarioState,
        combatChoice : CombatChoice,
        prng : Prng,
        character : Character.Character,
        gameContent : GameContent,
    ) : Result.Result<Scenario.ScenarioCombatResult, { #invalidTarget; #targetRequired; #invalidChoice : Text }> {
        let combatLog = Buffer.Buffer<Scenario.CombatLogEntry>(10);

        let characterCombatStats : CombatStats = {
            var health = state.character.health;
            var maxHealth = state.character.maxHealth;
            var block = state.character.block;
            var statusEffects = Buffer.fromArray(state.character.statusEffects);
        };
        let creatureCombatStats = state.creatures.vals()
        |> Iter.map(
            _,
            func(c : Scenario.CreatureCombatState) : CombatStats {
                {
                    var health = c.health;
                    var maxHealth = c.maxHealth;
                    var block = c.block;
                    var statusEffects = Buffer.fromArray(c.statusEffects);
                };
            },
        )
        |> Iter.toArray(_);
        // Character turn first
        if (Array.indexOf(combatChoice.actionId, state.character.availableActionIds, Text.equal) == null) {
            return #err(#invalidChoice("Action not available: " # combatChoice.actionId));
        };
        let ?action = gameContent.actions.get(combatChoice.actionId) else Debug.trap("Action not found: " # combatChoice.actionId);

        // Character turn
        triggerEffect(characterCombatStats, #character, #start, combatLog);

        let characterSource = #character;

        let actionResult = switch (
            calculateActionResult(
                prng,
                characterSource,
                action,
                characterCombatStats,
                creatureCombatStats,
                combatChoice.target,
            )
        ) {
            case (#ok(result)) result;
            case (#err(#invalidTarget)) return #err(#invalidTarget);
            case (#err(#targetRequired)) return #err(#targetRequired);
        };

        applyActionResult(characterSource, characterCombatStats, creatureCombatStats, actionResult, combatLog);

        func buildNewCreatureStates() : [Scenario.CreatureCombatState] {
            creatureCombatStats.vals()
            |> IterTools.enumerate(_)
            |> Iter.map(
                _,
                func((i, c) : (Nat, CombatStats)) : Scenario.CreatureCombatState {
                    let creatureState = state.creatures[i];
                    {
                        creatureState with
                        health = c.health;
                        maxHealth = c.maxHealth;
                        block = c.block;
                        statusEffects = Buffer.toArray(c.statusEffects);
                    };
                },
            )
            |> Iter.toArray(_);
        };

        func checkForDefeat() : ?Scenario.ScenarioCombatResult {
            if (characterCombatStats.health <= 0) {
                let newCreatureStates = buildNewCreatureStates();
                return ?{
                    kind = #defeat({ creatures = newCreatureStates });
                    log = Buffer.toArray(combatLog);
                };
            };
            null;
        };
        switch (checkForDefeat()) {
            case (?result) return #ok(result);
            case (null) ();
        };

        triggerEffect(characterCombatStats, #character, #end, combatLog);
        decrementEffectTurns(characterCombatStats);

        // Creature turns
        label f for ((i, creature) in IterTools.enumerate(creatureCombatStats.vals())) {
            if (creature.health <= 0) continue f;
            let creatureInfo = state.creatures[i];
            let randomActionId = prng.nextArrayElement(creatureInfo.availableActionIds);

            let ?creatureAction = gameContent.actions.get(randomActionId) else Debug.trap("Action not found: " # randomActionId);

            triggerEffect(creatureCombatStats[i], #creature(i), #start, combatLog);
            let source = #creature(i);

            let actionResult = switch (
                calculateActionResult(
                    prng,
                    source,
                    creatureAction,
                    characterCombatStats,
                    creatureCombatStats,
                    null,
                )
            ) {
                case (#ok(result)) result;
                case (#err(#invalidTarget)) Prelude.unreachable();
                case (#err(#targetRequired)) Prelude.unreachable();
            };
            applyActionResult(
                source,
                characterCombatStats,
                creatureCombatStats,
                actionResult,
                combatLog,
            );

            switch (checkForDefeat()) {
                case (?result) return #ok(result);
                case (null) ();
            };
            triggerEffect(creatureCombatStats[i], #creature(i), #end, combatLog);
            decrementEffectTurns(creatureCombatStats[i]);
        };
        let newCreatureStates = buildNewCreatureStates();
        let allCreaturesDead = IterTools.all(newCreatureStates.vals(), func(c : Scenario.CreatureCombatState) : Bool = c.health <= 0);

        let combatKind : Scenario.CombatResultKind = if (allCreaturesDead) {
            #victory({
                characterHealth = characterCombatStats.health;
            });
        } else {
            let newActionIds = getRandomCharacterActionIds(prng, character, gameContent);
            #inProgress({
                character = {
                    health = characterCombatStats.health;
                    maxHealth = characterCombatStats.maxHealth;
                    block = characterCombatStats.block;
                    statusEffects = Buffer.toArray(characterCombatStats.statusEffects);
                    availableActionIds = newActionIds;
                };
                creatures = newCreatureStates;
                nextPath = state.nextPath;
            });

        };
        #ok({
            kind = combatKind;
            log = Buffer.toArray(combatLog);
        });
    };

    func getRandomCreature(
        prng : Prng,
        kind : ScenarioMetaData.CombatCreatureKind,
        gameContent : GameContent,
    ) : Scenario.CreatureCombatState {
        let creatureIds = switch (kind) {
            case (#id(id)) [id];
            case (#filter(filter)) {
                let creatureFilter = switch (filter.location) {
                    case (#any) func(_ : Creature.Creature) : Bool = true;
                    case (#common) func(c : Creature.Creature) : Bool = c.location == #common;
                    case (#zone(zoneId)) func(c : Creature.Creature) : Bool = switch (c.location) {
                        case (#zoneIds(zoneIds)) Array.indexOf(zoneId, zoneIds, Text.equal) != null;
                        case (_) false;
                    };
                };
                gameContent.creatures.vals()
                |> Iter.filter(_, creatureFilter)
                |> Iter.map(_, func(c : Creature.Creature) : Text = c.id)
                |> Iter.toArray(_);
            };
        };
        let selectedCreatureId = prng.nextArrayElement(creatureIds);
        let ?creature = gameContent.creatures.get(selectedCreatureId) else Debug.trap("Creature not found: " # selectedCreatureId);
        {
            creatureId = selectedCreatureId;
            health = creature.health;
            maxHealth = creature.maxHealth;
            block = 0;
            statusEffects = [];
            availableActionIds = creature.actionIds;
        };
    };

    func getRandomCharacterActionIds(
        prng : Prng,
        character : Character.Character,
        gameContent : GameContent,
    ) : [Text] {
        let count = 3; // TODO

        let allActionIds = Character.getActionIds(
            character,
            gameContent.classes,
            gameContent.races,
            gameContent.items,
            gameContent.weapons,
        );

        prng.shuffleBuffer(allActionIds);

        allActionIds.vals()
        |> IterTools.take(_, count)
        |> Iter.toArray(_);
    };

    func calculateActionResult(
        prng : Prng,
        actionSource : ActionResult.ActionTargetResult,
        action : Action.Action,
        characterStats : CombatStats,
        creatureStatList : [CombatStats],
        chosenTarget : ?ActionResult.ActionTargetResult,
    ) : Result.Result<ActionResult.ActionResult, { #invalidTarget; #targetRequired }> {
        let effectResults = Buffer.Buffer<ActionResult.CombatEffectResult>(0);
        let creatureCount = creatureStatList.size();
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

        for (effect in action.combatEffects.vals()) {

            let effectTargets = switch (effect.target) {
                case (#self) [actionSource];
                case (#targets) actionTargets;
            };

            for (target in effectTargets.vals()) {
                let defenderStats = switch (target) {
                    case (#character) characterStats;
                    case (#creature(creatureIndex)) creatureStatList[creatureIndex];
                };

                let attackerStats = switch (actionSource) {
                    case (#character) characterStats;
                    case (#creature(creatureIndex)) creatureStatList[creatureIndex];
                };
                let effectResult = switch (effect.kind) {
                    case (#damage(damage)) calculateDamage(prng, damage, attackerStats, defenderStats);
                    case (#block(block)) calculateBlock(prng, block, attackerStats); // TODO who casts or the target who gets block?
                    case (#heal(heal)) calculateHeal(prng, heal, attackerStats); // TODO who casts or the target who gets healed?
                    case (#addStatusEffect(statusEffect)) calculateStatusEffect(statusEffect);
                };
                effectResults.add({
                    target = target;
                    kind = effectResult;
                });
            };
        };

        #ok({
            effects = Buffer.toArray(effectResults);
        });
    };

    func triggerEffect(
        combatStats : CombatStats,
        target : ActionResult.ActionTargetResult,
        phase : Action.TurnPhase,
        combatLog : Buffer.Buffer<Scenario.CombatLogEntry>,
    ) : () {
        for (effect in combatStats.statusEffects.vals()) {
            switch (effect.kind) {
                case (#vulnerable or #weak or #stunned or #retaliating(_) or #brittle or #necrotic) (); // No direct effect to trigger
                case (#periodic(periodic)) {
                    if (periodic.phase == phase) {
                        let source : Scenario.TargetKind = #periodicEffect; // TODO need some identifier for the periodic effect?
                        let entry : Scenario.CombatLogEntry = switch (periodic.kind) {
                            case (#damage) {
                                applyDamage(combatStats, periodic.amount);
                                #damage({
                                    source = source;
                                    target = target;
                                    amount = periodic.amount;
                                });
                            };
                            case (#heal) {
                                applyHeal(combatStats, periodic.amount);
                                #heal({
                                    source = source;
                                    target = target;
                                    amount = periodic.amount;
                                });
                            };
                            case (#block) {
                                applyBlock(combatStats, periodic.amount);
                                #block({
                                    source = source;
                                    target = target;
                                    amount = periodic.amount;
                                });
                            };
                        };
                        combatLog.add(entry);
                    };
                };
            };
        };
    };

    func decrementEffectTurns(combatStats : CombatStats) : () {
        let newEffects = Buffer.Buffer<ActionResult.StatusEffectResult>(combatStats.statusEffects.size());

        for (effect in combatStats.statusEffects.vals()) {
            if (effect.remainingTurns > 1) {
                // Decrement the remaining turns and keep the effect
                newEffects.add({
                    kind = effect.kind;
                    remainingTurns = effect.remainingTurns - 1;
                });
            };
        };

        combatStats.statusEffects := newEffects;
    };

    func applyActionResult(
        source : ActionResult.ActionTargetResult,
        character : CombatStats,
        creatures : [CombatStats],
        action : ActionResult.ActionResult,
        combatLog : Buffer.Buffer<Scenario.CombatLogEntry>,
    ) : () {
        for (effect in action.effects.vals()) {
            let stats = switch (effect.target) {
                case (#creature(creatureIndex)) creatures[creatureIndex];
                case (#character) character;
            };
            let entry : Scenario.CombatLogEntry = switch (effect.kind) {
                case (#damage(damage)) {
                    applyDamage(stats, damage);
                    #damage({
                        source = source;
                        target = effect.target;
                        amount = damage;
                    });
                };
                case (#block(block)) {
                    applyBlock(stats, block);
                    #block({
                        source = source;
                        target = effect.target;
                        amount = block;
                    });
                };
                case (#heal(heal)) {
                    applyHeal(stats, heal);
                    #heal({
                        source = source;
                        target = effect.target;
                        amount = heal;
                    });
                };
                case (#addStatusEffect(statusEffectResult)) {
                    applyStatusEffect(stats, statusEffectResult);
                    #statusEffect({
                        source = source;
                        target = effect.target;
                        statusEffect = statusEffectResult;
                    });
                };
            };
            combatLog.add(entry);
        };
    };

    private func applyDamage(stats : CombatStats, amount : Nat) : () {
        if (stats.block >= amount) {
            // Only damage block
            stats.block := stats.block - amount;
        } else {
            // Destroy block and damage health
            stats.block := 0;
            stats.health := subtractNatSafe(stats.health, amount - stats.block);
        };
    };

    private func applyBlock(stats : CombatStats, amount : Nat) : () {
        stats.block += amount;
    };

    private func applyHeal(stats : CombatStats, amount : Nat) : () {
        stats.health := Nat.min(stats.health + amount, stats.maxHealth);
    };

    private func applyStatusEffect(stats : CombatStats, statusEffectResult : ActionResult.StatusEffectResult) : () {
        let existingEffectIndex = Buffer.indexOf(
            statusEffectResult,
            stats.statusEffects,
            func(a : ActionResult.StatusEffectResult, b : ActionResult.StatusEffectResult) : Bool = a.kind == b.kind,
        );
        switch (existingEffectIndex) {
            case (null) stats.statusEffects.add(statusEffectResult);
            case (?index) {
                // Add the remaining turns of the new effect to the existing one
                let currentTurns = stats.statusEffects.get(index).remainingTurns;
                let newTurns = currentTurns + statusEffectResult.remainingTurns;
                stats.statusEffects.put(
                    index,
                    {
                        stats.statusEffects.get(index) with
                        remainingTurns = newTurns;
                    },
                );
            };
        };
    };

    private func subtractNatSafe(a : Nat, b : Nat) : Nat {
        if (a < b) {
            return 0;
        };
        return a - b;
    };

    private func calculateDamage(
        prng : Prng,
        damage : Action.Damage,
        attackerStats : CombatStats,
        defenderStats : CombatStats,
    ) : ActionResult.CombatEffectKindResult {
        var damageAmount = calculateMinMaxAmount(prng, damage);
        if (hasEffect(defenderStats, #vulnerable)) {
            damageAmount := damageAmount + 1;
        };
        if (hasEffect(attackerStats, #weak)) {
            damageAmount := damageAmount - 1;
        };
        #damage(damageAmount);
    };

    private func calculateBlock(
        prng : Prng,
        block : Action.Block,
        blockerStats : CombatStats,
    ) : ActionResult.CombatEffectKindResult {
        var blockAmount = calculateMinMaxAmount(prng, block);
        if (hasEffect(blockerStats, #brittle)) {
            blockAmount := blockAmount - 1;
        };
        #block(blockAmount);
    };

    private func calculateHeal(
        prng : Prng,
        heal : Action.Heal,
        casterStats : CombatStats,
    ) : ActionResult.CombatEffectKindResult {
        var healAmount = calculateMinMaxAmount(prng, heal);
        if (hasEffect(casterStats, #necrotic)) {
            healAmount := healAmount - 1;
        };
        #heal(healAmount);
    };

    private func calculateMinMaxAmount(prng : Prng, amount : { min : Nat; max : Nat }) : Nat {
        if (amount.min >= amount.max) {
            return amount.min; // No need for random, just the raw value if no variance
        };
        prng.nextNat(amount.min, amount.max);
    };

    private func hasEffect(stats : CombatStats, effect : ActionResult.StatusEffectResultKind) : Bool {
        stats.statusEffects.vals()
        |> IterTools.any(
            _,
            func(e : ActionResult.StatusEffectResult) : Bool {
                e.kind == effect;
            },
        );
    };

    private func calculateStatusEffect(statusEffect : Action.StatusEffect) : ActionResult.CombatEffectKindResult {
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
