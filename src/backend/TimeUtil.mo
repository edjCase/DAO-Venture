import Time "mo:base/Time";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
module {
    public func getAge(genesisTime : Time.Time) : {
        days : Nat;
        timeInDay : Nat;
    } {
        let timeElapsed = Time.now() - genesisTime;
        if (timeElapsed < 0) {
            Debug.trap("Time elapsed is negative: " # Int.toText(timeElapsed));
        };
        let timeElapsedNat : Nat = Int.abs(timeElapsed);
        let dayInNanos : Nat = 60 * 60 * 24 * 1_000_000_000;
        let timeInDay : Nat = timeElapsedNat % dayInNanos;
        let days : Nat = timeElapsedNat / dayInNanos;
        { timeInDay = timeInDay; days = days };
    };
};
