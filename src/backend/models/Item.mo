module {

    public type Item = {
        #echoCrystal;
    };

    public func toText(item : Item) : Text {
        switch (item) {
            case (#echoCrystal) "Echo Crystal";
        };
    };
};
