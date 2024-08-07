import Time "mo:base/Time";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
module {

    public func getAge(genesisTime : Time.Time) : {
        daysElapsed : Nat;
        dayTimeLength : Nat;
        nextDayStartTime : Nat;
    } {
        let now : Nat = Int.abs(Time.now());
        let timeElapsed = now - genesisTime;
        if (timeElapsed < 0) {
            Debug.trap("Time elapsed is negative: " # Int.toText(timeElapsed));
        };
        // let dayTimeLength : Nat = 60 * 60 * 24 * 1000000000; // 1 day in nanoseconds
        let dayTimeLength : Nat = 10 * 1000000000; // 10 seconds for testing

        let timeElapsedNat : Nat = Int.abs(timeElapsed);
        let timeInDay : Nat = timeElapsedNat % dayTimeLength;
        let daysElapsed : Nat = timeElapsedNat / dayTimeLength;
        let timeTillNextDay : Nat = dayTimeLength - timeInDay;
        let nextDayStartTime : Nat = now + timeTillNextDay;
        { timeInDay; daysElapsed; dayTimeLength; nextDayStartTime };
    };
};
