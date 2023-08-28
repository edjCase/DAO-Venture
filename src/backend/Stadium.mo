import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";

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
        catcher : Nat32; // TODO remove?
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

    public type PlayerPositionDefense = {
        #firstBase;
        #secondBase;
        #thirdBase;
        #shortStop;
        #leftField;
        #centerField;
        #rightField;
        #pitcher;
        #catcher;
    };

    public type PlayerPositionOffense = {
        #onFirstBase;
        #onSecondBase;
        #onThirdBase;
        #atBat;
    };

    public type PlayerPosition = PlayerPositionDefense or PlayerPositionOffense;

    public func equalPlayerPosition(a : PlayerPosition, b : PlayerPosition) : Bool {
        a == b;
    };

    public func hashPlayerPosition(position : PlayerPosition) : Hash.Hash {
        switch (position) {
            case (#firstBase) 0;
            case (#secondBase) 1;
            case (#thirdBase) 2;
            case (#pitcher) 3;
            case (#catcher) 4;
            case (#shortStop) 5;
            case (#leftField) 6;
            case (#centerField) 7;
            case (#rightField) 8;
            case (#atBat) 9;
            case (#onFirstBase) 10;
            case (#onSecondBase) 11;
            case (#onThirdBase) 12;
        };
    };

    public type TeamId = {
        #team1;
        #team2;
    };

    public type EventEffect = {
        #none;
        #increaseScore : {
            teamId : TeamId;
            amount : Int;
        };
        #subPlayer : {
            playerOutId : Nat32;
        };
        #setPlayerCondition : {
            playerId : Nat32;
            condition : Player.PlayerCondition;
        };
        #increaseEnergy : {
            playerId : Nat32;
            amount : Int;
        };
        #movePlayerOffense : {
            playerId : Nat32;
            position : ?PlayerPositionOffense;
        };
    };

    public type Event = {
        description : Text;
        effect : EventEffect;
    };

    public type PlayerState = {
        name : Text;
        teamId : TeamId;
        energy : Int;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
    };

    public type TeamState = {
        score : Int;
        battingOrder : [Nat32];
        substitutes : [Nat32];
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
        offenseTeam : TeamId;
        team1 : TeamState;
        team2 : TeamState;
        players : Trie.Trie<Nat32, PlayerState>;
        events : [Event];
        positions : Trie.Trie<PlayerPosition, Nat32>;
        round : Nat;
        outs : Nat;
        strikes : Nat;
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
