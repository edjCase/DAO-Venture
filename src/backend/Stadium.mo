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
        #invalidOffering : Offering;
        #invalidSpecialRule : SpecialRule;
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
        offering : Offering;
    };

    public type StartedMatchState = {
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type MatchState = StartedMatchState or {
        #notStarted;
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
        specialRule : SpecialRule;
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
        #mischief : {
            #a;
        };
        #war : {
            #b;
        };
        #indulgence : {
            #c;
        };
        #pestilence : {
            #d;
        };
    };

    public func hashOffering(offering : Offering) : Nat32 = switch (offering) {
        case (#mischief(m)) switch (m) {
            case (#a) 0;
        };
        case (#war(w)) switch (w) {
            case (#b) 1;
        };
        case (#indulgence(i)) switch (i) {
            case (#c) 2;
        };
        case (#pestilence(p)) switch (p) {
            case (#d) 3;
        };
    };

    public func equalOffering(a : Offering, b : Offering) : Bool = a == b;

    public type SpecialRule = {
        #playersAreFaster;
        #explodingBalls;
        #fastBallsHardHits;
        #highBlessingAndCurses;
    };

    public func hashSpecialRule(rule : SpecialRule) : Nat32 = switch (rule) {
        case (#playersAreFaster) 0;
        case (#explodingBalls) 1;
        case (#fastBallsHardHits) 2;
        case (#highBlessingAndCurses) 3;
    };

    public func equalSpecialRule(a : SpecialRule, b : SpecialRule) : Bool = a == b;

    public type Match = {
        team1 : MatchTeamInfo;
        team2 : MatchTeamInfo;
        time : Time.Time;
        offerings : [Offering];
        specialRules : [SpecialRule];
        state : MatchState;
    };

    public type MatchWithTimer = Match and {
        timerId : ?Nat;
    };

    public type MatchWithId = Match and {
        id : Nat32;
        stadiumId : Principal;
    };
    public type TickMatchResult = StartedMatchState or {
        #matchNotFound;
        #notStarted;
    };
    public type LiveStreamMessage = {
        matchId : Nat32;
        state : StartedMatchState;
    };

    public type MatchOptions = {
        offering : Offering;
        specialRuleVotes : [(SpecialRule, Nat)];
    };

    public type MatchTeamInfo = {
        id : Principal;
        name : Text;
        predictionVotes : Nat;
    };
};
