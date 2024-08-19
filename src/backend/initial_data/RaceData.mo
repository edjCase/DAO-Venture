import Character "../models/Character";
module {
    public let races : [Character.Race] = [
        {
            id = "human";
            name = "Human";
            description = "Humans are versatile and adaptable.";
            effects = [
                #attack(1),
                #defense(1),
                #trait("clever"),
            ];
        },
        {
            id = "elf";
            name = "Elf";
            description = "Elves are graceful and attuned to nature.";
            effects = [
                #magic(1),
                #speed(1),
                #trait("naturalist"),
            ];
        },
        {
            id = "dwarf";
            name = "Dwarf";
            description = "Dwarves are sturdy and resilient.";
            effects = [
                #defense(2),
                #health(10),
                #trait("tough"),
            ];
        },
        {
            id = "halfling";
            name = "Halfling";
            description = "Halflings are small and nimble.";
            effects = [
                #speed(2),
                #defense(1),
                #trait("stealthy"),
            ];
        },
        {
            id = "faerie";
            name = "Faerie";
            description = "Faeries are mysterious and enchanting.";
            effects = [
                #magic(2),
                #speed(1),
                #trait("charismatic"),
            ];
        },
    ];
};
