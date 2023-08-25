import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import MatchSimulator "stadium/MatchSimulator";

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
        #duplicateTeams;
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
        scheduleMatch : (teamIds : (Principal, Principal), time : Time.Time) -> async ScheduleMatchResult;
    };

    public type Stadium = {
        canister : StadiumActor;
        name : Text;
    };

    public type Match = {
        teams : (MatchTeamInfo, MatchTeamInfo);
        time : Time.Time;
        winner : ?Principal;
        timerId : Nat;
        state : MatchSimulator.MatchState;
    };

    public type MatchTeamInfo = {
        id : Principal;
        config : ?TeamConfiguration;
        score : ?Nat;
        predictionVotes : Nat;
    };

    public type PlayerValidationError = {
        #notOnTeam : Nat32;
        #usedInMultiplePositions : Nat32;
    };
};
