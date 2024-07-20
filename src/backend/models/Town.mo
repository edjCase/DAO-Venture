import Flag "Flag";

module {

    public type Town = {
        id : Nat;
        name : Text;
        motto : Text;
        flagImage : Flag.FlagImage;

        entropy : Nat;
        currency : Nat;
    };
};
