module {

    public type Item = {
        #echoCrystal;
        #herbs;
        #fairyCharm;
        #healthPotion;
    };

    public func toId(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "echoCrystal";
            case (#herbs) "herbs";
            case (#fairyCharm) "fairyCharm";
            case (#healthPotion) "healthPotion";
        };
    };

    public func toText(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "Echo Crystal";
            case (#herbs) "Herbs";
            case (#fairyCharm) "Fairy Charm";
            case (#healthPotion) "Health Potion";
        };
    };

    public func toDescription(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "A crystal that echoes the sound of your voice.";
            case (#herbs) "A bundle of aromatic herbs.";
            case (#fairyCharm) "A charm that attracts fairies.";
            case (#healthPotion) "A potion that restores health.";
        };
    };

    public func hash(item : Item) : Nat32 {
        switch (item) {
            case (#echoCrystal) 0;
            case (#herbs) 1;
            case (#fairyCharm) 2;
            case (#healthPotion) 3;
        };
    };

    public func equal(a : Item, b : Item) : Bool {
        a == b;
    };
};
