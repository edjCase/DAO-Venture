import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";

module {
    type FieldPosition = Player.FieldPosition;
    type Base = Player.Base;
    type PlayerId = Nat32;

    public type StadiumActor = actor {
        getMatch : query (id : Nat32) -> async ?MatchWithId;
        getMatches : query () -> async [MatchWithId];
        tickMatch : (id : Nat32) -> async TickMatchResult;
        startMatch : (matchId : Nat32) -> async StartMatchResult;
        scheduleMatch : (request : ScheduleMatchRequest) -> async ScheduleMatchResult;
    };

    public type RegisterResult = {
        #ok;
        #matchNotFound;
        #teamNotInMatch;
        #matchAlreadyStarted;
        #invalidInfo : [RegistrationInfoError];
    };

    public type RegistrationInfoError = {
        #invalidOffering : Nat32;
        #invalidSpecialRule : Nat32;
    };

    public type ScheduleMatchRequest = {
        team1Id : Principal;
        team2Id : Principal;
        time : Time.Time;
    };

    public type ScheduleMatchError = {
        #timeNotAvailable;
        #duplicateTeams;
        #teamFetchError : Text;
        #teamNotFound : TeamIdOrBoth;
    };

    public type ScheduleMatchResult = ScheduleMatchError or {
        #ok : Nat32;
    };

    public type TeamId = {
        #team1;
        #team2;
    };

    public type TeamIdOrBoth = TeamId or { #bothTeams };

    public type MatchEndReason = {
        #noMoreRounds;
        #outOfPlayers : TeamIdOrBoth;
    };

    public type PlayerState = {
        name : Text;
        teamId : TeamId;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
        position : FieldPosition;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
    };

    public type TeamState = {
        id : Principal;
        name : Text;
        score : Int;
        offeringId : Nat32;
    };

    public type MatchState = {
        #notStarted;
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type DefenseFieldState = {
        firstBase : PlayerId;
        secondBase : PlayerId;
        thirdBase : PlayerId;
        shortStop : PlayerId;
        pitcher : PlayerId;
        leftField : PlayerId;
        centerField : PlayerId;
        rightField : PlayerId;
    };

    public type OffsenseFieldState = {
        atBat : PlayerId;
        firstBase : ?PlayerId;
        secondBase : ?PlayerId;
        thirdBase : ?PlayerId;
    };

    public type FieldState = {
        defense : DefenseFieldState;
        offense : OffsenseFieldState;
    };

    public type LogEntry = {
        description : Text;
        isImportant : Bool;
    };

    public type InProgressMatchState = {
        currentSeed : Nat32;
        offenseTeamId : TeamId;
        team1 : TeamState;
        team2 : TeamState;
        specialRuleId : ?Nat32;
        players : [PlayerStateWithId];
        field : FieldState;
        log : [LogEntry];
        round : Nat;
        outs : Nat;
        strikes : Nat;
    };

    public type CompletedMatchState = {
        #absentTeam : TeamId;
        #allAbsent;
        #played : CompletedMatchResult;
    };

    public type TeamIdOrTie = TeamId or { #tie };

    public type CompletedMatchResult = {
        team1 : CompletedTeamState;
        team2 : CompletedTeamState;
        winner : TeamIdOrTie;
        log : [LogEntry];
    };

    public type CompletedTeamState = {
        id : Principal;
        score : Int;
    };

    public type StartMatchResult = {
        #ok : InProgressMatchState;
        #matchNotFound;
        #matchAlreadyStarted;
        #completed : CompletedMatchState;
    };

    public type Stadium = {
        name : Text;
    };

    public type Offering = {
        deities : [Text];
        effects : [Text];
    };

    public type OfferingWithId = Offering and {
        id : Nat32;
    };

    public type SpecialRule = {
        name : Text;
        description : Text;
    };

    public type SpecialRuleWithId = SpecialRule and {
        id : Nat32;
    };

    public type Match = {
        team1 : MatchTeamInfo;
        team2 : MatchTeamInfo;
        time : Time.Time;
        offerings : [OfferingWithId];
        specialRules : [SpecialRuleWithId];
        state : MatchState;
    };

    public type MatchWithTimer = Match and {
        timerId : ?Nat;
    };

    public type MatchWithId = Match and {
        id : Nat32;
        stadiumId : Principal;
    };
    public type TickMatchResult = {
        #ok : InProgressMatchState;
        #matchNotFound;
        #matchOver : CompletedMatchState;
        #notStarted;
    };
    public type LiveStreamMessage = {
        matchId : Nat32;
        state : {
            #inProgress : InProgressMatchState;
            #matchOver : CompletedMatchState;
        };
    };

    public type MatchOptions = {
        offeringId : Nat32;
        specialRuleVotes : [(Nat32, Nat)];
    };

    public type MatchTeamInfo = {
        id : Principal;
        name : Text;
        predictionVotes : Nat;
    };
};
