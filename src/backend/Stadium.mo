import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";

module {
    type FieldPosition = Player.FieldPosition;
    type Base = Player.Base;

    type PlayerId = Nat32;

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

    public type ScheduleMatchResult = {
        #ok;
        #timeNotAvailable;
        #duplicateTeams;
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
            playerOutId : PlayerId;
        };
        #setPlayerCondition : {
            playerId : PlayerId;
            condition : Player.PlayerCondition;
        };
        #movePlayerToBase : {
            playerId : PlayerId;
            base : ?Base;
        };
        #addStrike : {
            playerId : PlayerId;
        };
        #addOut : {
            playerId : PlayerId;
        };
        #endRound;
    };

    public type Event = {
        description : Text;
        effect : EventEffect;
    };

    public type PlayerState = {
        name : Text;
        teamId : TeamId;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
        position : FieldPosition;
    };

    public type TeamState = {
        score : Int;
        offeringId : Nat32;
    };

    public type MatchState = {
        #notStarted;
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type InProgressMatchState = {
        offenseTeamId : TeamId;
        team1 : TeamState;
        team2 : TeamState;
        specialRuleId : ?Nat32;
        players : Trie.Trie<PlayerId, PlayerState>;
        batter : ?PlayerId;
        positions : Trie.Trie<FieldPosition, PlayerId>;
        events : [Event];
        bases : Trie.Trie<Base, PlayerId>;
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
        getMatch : shared query (id : Nat32) -> async ?MatchWithId;
        getMatches : shared query () -> async [MatchWithId];
        scheduleMatch : shared (teamIds : (Principal, Principal), time : Time.Time) -> async ScheduleMatchResult;
    };

    public type Stadium = {
        canister : StadiumActor;
        name : Text;
    };

    public type Offering = {
        deities : [Text];
        effects : [Text];
    };

    public type SpecialRule = {
        name : Text;
        description : Text;
    };

    public type Match = {
        teams : (MatchTeamInfo, MatchTeamInfo);
        time : Time.Time;
        winner : ?Principal;
        offerings : [Offering];
        specialRules : [SpecialRule];
        timerId : Nat;
        state : MatchState;
    };

    public type MatchWithId = Match and {
        id : Nat32;
    };

    public type MatchOptions = {
        offeringId : Nat32;
        specialRuleVotes : Trie.Trie<Nat32, Nat>;
    };

    public type MatchTeamInfo = {
        id : Principal;
        predictionVotes : Nat;
    };
};
