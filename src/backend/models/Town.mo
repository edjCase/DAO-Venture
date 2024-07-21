import Flag "Flag";
import Time "mo:base/Time";

module {

    public type Town = {
        id : Nat;
        name : Text;
        genesisTime : Time.Time;
        motto : Text;
        flagImage : Flag.FlagImage;
        entropy : Nat;
        currency : Nat;
        size : Nat;
        population : Nat;
    };
};
