module {
    public type Player = {
        name : Text;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };
};
