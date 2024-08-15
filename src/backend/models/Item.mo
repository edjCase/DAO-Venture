module {

    public type Item = {
        #echoCrystal;
    };

    public func toId(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "echoCrystal";
        };
    };

    public func toText(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "Echo Crystal";
        };
    };

    public func toDescription(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "A crystal that echoes the sound of your voice.";
        };
    };
};
