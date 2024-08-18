import Character "models/Character";
module {
    public let items : [Character.Item] = [
        {
            id = "echoCrystal";
            name = "Echo Crystal";
            description = "A crystal that repeats everything you say, say, say...";
        },
        {
            id = "herbs";
            name = "Herbs";
            description = "Nature's breath mints, now in leafy green!";
        },
        {
            id = "fairyCharm";
            name = "Fairy Charm";
            description = "Guaranteed to attract 99% more fairy dust. Side effects may include spontaneous glitter.";
        },
        {
            id = "healthPotion";
            name = "Health Potion";
            description = "Tastes like liquid band-aid, works like magic. Literally.";
        },
        {
            id = "treasureMap";
            name = "Treasure Map";
            description = "A piece of paper with a red X on it.";
        },
    ];
};
