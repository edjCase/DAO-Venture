import Class "../models/Class";

module {
    public let classes : [Class.Class] = [
        {
            id = "warrior";
            name = "Warrior";
            description = "A warrior is a master of combat, using their strength and skill to defeat their foes.";
            modifiers = [
                #attack(1),
                #health(10),
                #trait("strong"),
            ];
        },
        {
            id = "mage";
            name = "Mage";
            description = "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.";
            modifiers = [
                #magic(1),
                #trait("alchemist"),
                #trait("intelligent"),
            ];
        },
        {
            id = "rogue";
            name = "Rogue";
            description = "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.";
            modifiers = [
                #speed(1),
                #gold(10),
                #trait("agile"),
            ];
        },
        {
            id = "archer";
            name = "Archer";
            description = "An archer is a master of ranged combat, using their precision and skill to strike from a distance.";
            modifiers = [
                #attack(1),
                #speed(1),
                #trait("perceptive"),
            ];
        },
        {
            id = "druid";
            name = "Druid";
            description = "A druid is a guardian of nature, wielding its power to protect and heal.";
            modifiers = [
                #magic(1),
                #health(5),
                #trait("naturalist"),
            ];
        },
        {
            id = "paladin";
            name = "Paladin";
            description = "A paladin is a holy warrior, combining martial prowess with divine magic.";
            modifiers = [
                #attack(1),
                #defense(1),
                #trait("holy"),
            ];
        },
        {
            id = "bard";
            name = "Bard";
            description = "A bard is a jack-of-all-trades, using music and charm to inspire allies and confound enemies.";
            modifiers = [
                #magic(1),
                #speed(1),
                #trait("charismatic"),
            ];
        },
        {
            id = "monk";
            name = "Monk";
            description = "A monk is a martial artist, harnessing inner energy to perform incredible feats.";
            modifiers = [
                #speed(2),
                #trait("tough"),
            ];
        },
        {
            id = "artificer";
            name = "Artificer";
            description = "An artificer is an inventor, combining magic with technology to create powerful gadgets.";
            modifiers = [
                #defense(1),
                #attack(1),
                #trait("crafty"),
            ];
        },
        {
            id = "necromancer";
            name = "Necromancer";
            description = "A necromancer is a master of death magic, commanding undead and draining life force.";
            modifiers = [
                #magic(2),
                #health(-5),
                #trait("cursed"),
            ];
        },
    ];
};
