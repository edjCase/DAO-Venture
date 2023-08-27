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
        #invalidLineup : [PlayerValidationError];
    };

    public type ScheduleMatchResult = {
        #ok;
        #timeNotAvailable;
        #duplicateTeams;
    };

    public type TeamLineup = {
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

    public type PlayerPositionOffense = {
        #atBat;
        #first;
        #second;
        #third;
    };

    public type TeamId = {
        #team1;
        #team2;
    };

    public type EventEffect = {
        #increaseScore : {
            teamId : TeamId;
            amount : Int;
        };
        #changePlayer : {
            teamId : TeamId;
            playerInId : Nat32;
            playerOutId : Nat32;
        };
        #injurePlayer : {
            playerId : Nat32;
        };
        #killPlayer : {
            playerId : Nat32;
        };
        #increaseEnergy : {
            playerId : Nat32;
            amount : Int;
        };
        #movePlayerOffsense : {
            playerId : Nat32;
            position : PlayerPositionOffense;
        };
    };

    public type Event = {
        description : Text;
        effect : EventEffect;
    };

    public type PlayerState = {
        id : Nat32;
        name : Text;
        energy : Nat;
        condition : Player.PlayerCondition;
    };

    public type TeamState = {
        score : Int;
        battingOrder : [Nat32];
        players : [PlayerState];
        currentBatterIndex : Nat;
    };

    public type BaseInfo = {
        player : ?Nat;
    };

    public type MatchState = {
        #notStarted;
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type InProgressMatchState = {
        team1StartOffense : Bool;
        team1 : TeamState;
        team2 : TeamState;
        events : [Event];
        firstBase : BaseInfo;
        secondBase : BaseInfo;
        thirdBase : BaseInfo;
        atBat : ?Nat;
        round : Nat;
        outs : Nat;
        strikes : Nat;
        balls : Nat;
    };

    public type CompletedMatchState = {
        #absentTeam : TeamId;
        #allAbsent;
        #gameResult : {
            team1 : TeamState;
            team2 : TeamState;
            winner : TeamId;
        };
    };

    public type StadiumActor = actor {
        registerForMatch : (id : Nat32, teamConfig : TeamLineup) -> async RegisterResult;
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
        state : MatchState;
    };

    public type MatchTeamInfo = {
        id : Principal;
        lineup : ?TeamLineup;
        score : ?Nat;
        predictionVotes : Nat;
    };

    public type PlayerValidationError = {
        #notOnTeam : Nat32;
        #usedInMultiplePositions : Nat32;
    };
};
