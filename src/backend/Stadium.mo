import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";

module {
    public type RegisterResult = {
        #ok;
        #matchNotFound;
        #teamNotInMatch;
        #matchAlreadyStarted;
        #invalidTeamConfig : [PlayerValidationError];
    };

    public type ScheduleMatchResult = {
        #ok;
        #timeNotAvailable;
    };

    public type TeamConfiguration = {
        pitcher : Nat32;
        catcher : Nat32;
        firstBase : Nat32;
        secondBase : Nat32;
        thirdBase : Nat32;
        shortStop : Nat32;
        leftField : Nat32;
        centerField : Nat32;
        rightField : Nat32;
        battingOrder : [Nat32];
        substitutes : [Nat32];
    };

    public type StadiumActor = actor {
        registerForMatch : (id : Nat32, teamConfig : TeamConfiguration) -> async RegisterResult;
        scheduleMatch : (teamIds : [Principal], time : Time.Time) -> async ScheduleMatchResult;
    };

    public type Stadium = {
        canister : StadiumActor;
        name : Text;
    };

    public type Match = {
        id : Nat32;
        teams : [MatchTeamInfo];
        time : Time.Time;
    };

    public type MatchTeamInfo = {
        id : Principal;
        config : ?TeamConfiguration;
    };

    public type CompletedMatch = Match and {
        score1 : Int;
        score2 : Int;
    };

    public type PlayerValidationError = {
        #notOnTeam : Nat32;
        #usedInMultiplePositions : Nat32;
    };
};
