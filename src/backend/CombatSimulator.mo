import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Weapon "models/entities/Weapon";
import Outcome "models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type CombatStats = {
        health : Nat;
        maxHealth : Nat;
        attack : Int;
        defense : Int;
        magic : Int;
        speed : Int;
        gold : Nat;
        weapon : Weapon.Weapon;
    };

    public func run(
        prng : Prng,
        character : CombatStats,
        creature : CombatStats,
        maxTurns : Nat,
    ) : Outcome.CombatResult {

        // Determine initiative
        let characterInitiative : Int = character.speed + prng.nextNat(1, 20);
        let creatureInitiative : Int = creature.speed + prng.nextNat(1, 20);

        var turn = 0;
        let isCharacterFirst : Bool = if (characterInitiative > creatureInitiative) {
            true;
        } else if (creatureInitiative > characterInitiative) {
            false;
        } else {
            // Tiebreaker
            prng.nextCoin();
        };

        var characterIsAttacker : Bool = isCharacterFirst;
        var characterHealth = character.health;
        var creatureHealth = creature.health;
        let turns = Buffer.Buffer<Outcome.CombatTurn>(5);
        loop {
            let (attacker, defender) = if (characterIsAttacker) {
                (character, creature);
            } else {
                (creature, character);
            };
            let attackResults = calculateAttackResults(prng, attacker, defender);
            turns.add({
                attacker = if (characterIsAttacker) #character else #creature;
                attacks = attackResults;
            });
            for (attackResult in attackResults.vals()) {
                switch (attackResult) {
                    case (#hit({ damage })) {
                        let defenderHealth = if (characterIsAttacker) creatureHealth else characterHealth;
                        let newDefenderHealth : Int = defenderHealth - damage;
                        if (newDefenderHealth <= 0) {
                            return {
                                turns = Buffer.toArray(turns);
                                healthDelta = characterHealth - character.health;
                                kind = if (characterIsAttacker) #victory else #defeat;
                            };
                        };
                        let natHealth = Int.abs(newDefenderHealth);
                        if (characterIsAttacker) {
                            creatureHealth := natHealth;
                        } else {
                            characterHealth := natHealth;
                        };
                    };
                    case (#miss) ();
                };
            };

            turn += 1;
            if (turn > maxTurns) {
                return {
                    turns = Buffer.toArray(turns);
                    healthDelta = characterHealth - character.health;
                    kind = #maxTurnsReached;
                };
            };
            characterIsAttacker := not characterIsAttacker;

        };
    };

    func calculateAttackResults(
        prng : Prng,
        attacker : CombatStats,
        defender : CombatStats,
    ) : [Outcome.AttackResult] {
        let weaponStats = calculateWeaponStats(attacker);
        let hitChance = calculateHitChance(weaponStats, defender);
        Iter.range(0, weaponStats.attacks - 1)
        |> Iter.map(
            _,
            func(_ : Nat) : Outcome.AttackResult {
                if (prng.nextNat(1, 100) <= hitChance) {
                    var damage = calculateWeaponDamage(prng, weaponStats);
                    // TODO better defense
                    // TODO do damage type/resistances
                    let finalDamage = Int.abs(Int.max(0, damage - defender.defense));
                    #hit({ damage = finalDamage });
                } else {
                    #miss;
                };
            },
        )
        |> Iter.toArray(_);
    };

    func calculateWeaponDamage(
        prng : Prng,
        weaponStats : Weapon.WeaponStats,
    ) : Nat {
        var damage = prng.nextNat(weaponStats.minDamage, weaponStats.maxDamage) + 5;

        if (prng.nextNat(1, 100) <= weaponStats.criticalChance) {
            // Crit
            let damagePlusCrit = damage
            |> percentMultiply(damage, weaponStats.criticalMultiplier)
            |> Int.max(1, _)
            |> Int.abs(_);
            damage := damagePlusCrit;
        };
        damage;
    };

    func calculateHitChance(attacker : { accuracy : Int }, defender : { speed : Int }) : Nat {
        let hitChance : Int = attacker.accuracy - defender.speed + 50;
        // Clamp to 5-100%
        hitChance |> Int.min(100, _) |> Int.max(5, _) |> Int.abs(_);
    };

    func percentMultiply(value : Nat, percent : Nat) : Nat {
        Int.abs(Float.toInt(Float.floor(Float.fromInt(value) * (Float.fromInt(percent) / 100.0))));
    };

    func calculateWeaponStats(attacker : CombatStats) : Weapon.WeaponStats {
        var attacks = attacker.weapon.baseStats.attacks;
        var minDamage = attacker.weapon.baseStats.minDamage;
        var maxDamage = attacker.weapon.baseStats.maxDamage;
        var accuracy = attacker.weapon.baseStats.accuracy;
        var criticalChance = attacker.weapon.baseStats.criticalChance;
        var criticalMultiplier = attacker.weapon.baseStats.criticalMultiplier;
        for (modifier in attacker.weapon.baseStats.statModifiers.vals()) {

            let value : Int = switch (modifier.characterStat) {
                case (#attack) attacker.attack;
                case (#magic) attacker.magic;
                case (#speed) attacker.speed;
                case (#defense) attacker.defense;
                case (#health(health)) {
                    if (health.inverse) {
                        attacker.maxHealth - attacker.health;
                    } else {
                        attacker.health;
                    };
                };
                case (#gold) attacker.gold;
            };
            let minValue : Nat = switch (modifier.attribute) {
                case (#attacks) 1;
                case (#damage) 1;
                case (#minDamage) 1;
                case (#maxDamage) 1;
                case (#accuracy) 1;
                case (#criticalChance) 0;
                case (#criticalMultiplier) 1;
            };

            let scaledValue : Nat = Int.abs(Int.max(minValue, Int.abs(Float.toInt(Float.fromInt(value) * modifier.factor))));

            switch (modifier.attribute) {
                case (#attacks) attacks += scaledValue;
                case (#damage) {
                    minDamage += scaledValue;
                    maxDamage += scaledValue;
                };
                case (#minDamage) minDamage += scaledValue;
                case (#maxDamage) maxDamage += scaledValue;
                case (#accuracy) accuracy += scaledValue;
                case (#criticalChance) criticalChance += scaledValue;
                case (#criticalMultiplier) criticalMultiplier += scaledValue;
            };
        };

        {
            attacks = attacker.weapon.baseStats.attacks;
            minDamage = attacker.weapon.baseStats.minDamage;
            maxDamage = attacker.weapon.baseStats.maxDamage;
            accuracy = attacker.weapon.baseStats.accuracy;
            criticalChance = attacker.weapon.baseStats.criticalChance;
            criticalMultiplier = attacker.weapon.baseStats.criticalMultiplier;
            statModifiers = attacker.weapon.baseStats.statModifiers;
        };
    };
};
