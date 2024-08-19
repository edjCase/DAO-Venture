import Race "../models/Race";
module {
    public let races : [Race.Race] = [
        {
            id = "human";
            name = "Human";
            description = "Humans are versatile and adaptable.";
            modifiers = [
                #attack(1),
                #defense(1),
                #trait("clever"),
            ];
        },
        {
            id = "elf";
            name = "Elf";
            description = "Elves are graceful and attuned to nature.";
            modifiers = [
                #magic(1),
                #speed(1),
                #trait("naturalist"),
            ];
        },
        {
            id = "dwarf";
            name = "Dwarf";
            description = "Dwarves are sturdy and resilient.";
            modifiers = [
                #defense(2),
                #health(10),
                #trait("tough"),
            ];
        },
        {
            id = "halfling";
            name = "Halfling";
            description = "Halflings are small and nimble.";
            modifiers = [
                #speed(2),
                #defense(1),
                #trait("stealthy"),
            ];
        },
        {
            id = "faerie";
            name = "Faerie";
            description = "Faeries are mysterious and enchanting.";
            modifiers = [
                #magic(2),
                #speed(1),
                #trait("charismatic"),
            ];
        },
    ];
};
