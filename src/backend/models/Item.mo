module {

    public type Item = {
        #echoCrystal;
        #herbs;
        #fairyCharm;
        #healthPotion;
        #treasureMap;
    };

    public func toId(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "echoCrystal";
            case (#herbs) "herbs";
            case (#fairyCharm) "fairyCharm";
            case (#healthPotion) "healthPotion";
            case (#treasureMap) "treasureMap";
        };
    };

    public func toText(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "Echo Crystal";
            case (#herbs) "Herbs";
            case (#fairyCharm) "Fairy Charm";
            case (#healthPotion) "Health Potion";
            case (#treasureMap) "Treasure Map";
        };
    };

    public func toDescription(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "A crystal that repeats everything you say, say, say...";
            case (#herbs) "Nature's breath mints, now in leafy green!";
            case (#fairyCharm) "Guaranteed to attract 99% more fairy dust. Side effects may include spontaneous glitter.";
            case (#healthPotion) "Tastes like liquid band-aid, works like magic. Literally.";
            case (#treasureMap) "A piece of paper with a red X on it.";
        };
    };

    public type State = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func toState(item : Item) : State {
        {
            id = toId(item);
            name = toText(item);
            description = toDescription(item);
        };
    };

    public func hash(item : Item) : Nat32 {
        switch (item) {
            case (#echoCrystal) 0;
            case (#herbs) 1;
            case (#fairyCharm) 2;
            case (#healthPotion) 3;
            case (#treasureMap) 4;
        };
    };

    public func equal(a : Item, b : Item) : Bool {
        a == b;
    };
};
