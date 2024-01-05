import Time "mo:base/Time";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Offering "Offering";
import MatchAura "MatchAura";
import Team "Team";
import MatchPrediction "MatchPrediction";

module {

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : InProgressSeason;
        #completed : CompletedSeason;
    };

    public type InProgressSeason = {
        matchGroups : [InProgressSeasonMatchGroupVariant];
    };

    public type InProgressSeasonMatchGroupVariant = {
        #notScheduled : NotScheduledMatchGroup;
        #scheduled : ScheduledMatchGroup;
        #inProgress : InProgressMatchGroup;
        #completed : CompletedMatchGroup;
    };

    public type TeamInfo = {
        id : Principal;
        name : Text;
        logoUrl : Text;
    };

    public type NotScheduledMatchGroup = {
        time : Time.Time;
        matches : [NotScheduledMatch];
    };

    public type NotScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
    };

    public type ScheduledMatchGroup = {
        time : Time.Time;
        timerId : Nat;
        matches : [ScheduledMatch];
    };

    public type ScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        offerings : [Offering.OfferingWithMetaData];
        aura : MatchAura.MatchAuraWithMetaData;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        stadiumId : Principal;
        matches : [InProgressMatch];
    };

    public type InProgressTeam = TeamInfo and {
        offering : Offering.Offering;
        championId : Nat32;
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
        aura : MatchAura.MatchAura;
        predictions : Trie.Trie<Principal, MatchPrediction.MatchPrediction>;
    };

    public type CompletedMatchTeam = TeamInfo and {
        offering : Offering.Offering;
        championId : Nat32;
        score : Int;
    };
    public type CompletedMatchWithoutPredictions = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        aura : MatchAura.MatchAura;
        log : [LogEntry];
        winner : Team.TeamIdOrTie;
        error : ?Text;
    };

    public type CompletedMatch = CompletedMatchWithoutPredictions and {
        predictions : Trie.Trie<Principal, MatchPrediction.MatchPrediction>;
    };

    public type LogEntry = {
        message : Text;
        isImportant : Bool;
    };

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatch];
    };

    // Completed Season
    public type CompletedSeason = {
        teams : [CompletedSeasonTeam];
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedSeasonTeam = TeamInfo and {
        standing : Nat;
        wins : Nat;
        losses : Nat;
    };
};
