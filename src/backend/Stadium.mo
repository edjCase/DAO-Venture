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
    type PlayerId = Player.PlayerId;

    public type StadiumActor = actor {
        getMatchGroup : query (id : Nat32) -> async ?MatchGroupWithId;
        getMatchGroups : query () -> async [MatchGroupWithId];
        tickMatchGroup : (id : Nat32) -> async TickMatchGroupResult;
        scheduleMatchGroup : (request : ScheduleMatchGroupRequest) -> async ScheduleMatchGroupResult;
    };

    public type RegisterResult = {
        #ok;
        #matchNotFound;
        #teamNotInMatch;
        #matchAlreadyStarted;
        #invalidInfo : [RegistrationInfoError];
    };

    public type RegistrationInfoError = {
        #invalidOffering : Offering;
        #invalidChampion : PlayerId;
    };

    public type ScheduleMatchGroupRequest = {
        time : Time.Time;
        divisionId : Principal;
        matches : [ScheduleMatchRequest];
    };

    public type ScheduleMatchRequest = {
        team1Id : Principal;
        team2Id : Principal;
        offerings : [Offering];
        aura : MatchAura;
    };

    public type ScheduleMatchGroupError = {
        #teamFetchError : Text;
        #matchErrors : [ScheduleMatchError];
    };

    public type ScheduleMatchError = {
        #teamNotFound : TeamIdOrBoth;
    };

    public type ScheduleMatchGroupResult = ScheduleMatchGroupError or {
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
        offering : Offering;
        champion : PlayerId;
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
        offenseTeamId : TeamId;
        team1 : TeamState;
        team2 : TeamState;
        aura : MatchAura;
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

    public type StartMatchGroupResult = {
        #inProgress : InProgressMatchGroupState;
        #matchGroupNotFound;
        #matchGroupAlreadyStarted;
        #completed : CompletedMatchGroupState;
    };

    public type Stadium = {
        name : Text;
    };

    public type StadiumWithId = Stadium and {
        id : Principal;
    };

    public type Offering = {
        #shuffleAndBoost;
    };

    public func hashOffering(offering : Offering) : Nat32 = switch (offering) {
        case (#shuffleAndBoost) 0;
    };

    public func equalOffering(a : Offering, b : Offering) : Bool = a == b;

    public type MatchAura = {
        #lowGravity;
        #explodingBalls;
        #fastBallsHardHits;
        #highBlessingsAndCurses;
    };

    public func hashMatchAura(aura : MatchAura) : Nat32 = switch (aura) {
        case (#lowGravity) 0;
        case (#explodingBalls) 1;
        case (#fastBallsHardHits) 2;
        case (#highBlessingsAndCurses) 3;
    };

    public func equalMatchAura(a : MatchAura, b : MatchAura) : Bool = a == b;

    public type Match = {
        team1 : MatchTeam;
        team2 : MatchTeam;
        offerings : [Offering];
        aura : MatchAura;
        state : MatchState;
    };

    public type StartedMatchState = {
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type MatchState = StartedMatchState or {
        #notStarted;
    };
    public type MatchWithId = Match and {
        id : Nat32;
        stadiumId : Principal;
    };

    public type MatchGroup = {
        time : Time.Time;
        state : MatchGroupState;
    };

    public type MatchGroupWithId = MatchGroup and {
        id : Nat32;
    };

    public type MatchGroupState = {
        #notStarted : NotStartedMatchGroupState;
        #inProgress : InProgressMatchGroupState;
        #completed : CompletedMatchGroupState;
    };

    public type NotStartedMatchGroupState = {
        startTimerId : Nat;
        matches : [Match];
    };

    public type InProgressMatchGroupState = {
        tickTimerId : Nat;
        currentSeed : Nat32;
        matches : [StartedMatchState];
    };

    public type CompletedMatchGroupState = {
        matches : [CompletedMatchState];
    };

    public type TickMatchGroupResult = {
        #inProgress;
        #matchGroupNotFound;
        #completed;
    };

    public type MatchOptions = {
        offering : Offering;
        champion : PlayerId;
    };

    public type MatchTeam = {
        id : Principal;
        name : Text;
        predictionVotes : Nat;
    };

    public type Blessing = {
        #skill : Player.Skill;
    };

    public type Curse = {
        #skill : Player.Skill;
        #injury : Player.Injury;
    };
};
