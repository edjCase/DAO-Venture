import Character "models/Character";

module {
    public let classes : [Character.Class] = [
        {
            id = "warrior";
            name = "Warrior";
            description = "A warrior is a master of combat, using their strength and skill to defeat their foes.";
        },
        {
            id = "mage";
            name = "Mage";
            description = "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.";
        },
        {
            id = "rogue";
            name = "Rogue";
            description = "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.";
        },
        {
            id = "archer";
            name = "Archer";
            description = "An archer is a master of ranged combat, using their precision and skill to strike from a distance.";
        },
    ];
};
