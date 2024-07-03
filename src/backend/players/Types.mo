import Player "../models/Player";
import Scenario "../models/Scenario";
import FieldPosition "../models/FieldPosition";
import Result "mo:base/Result";
module {

    public type PlayerActor = actor {
        addFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : query (id : Nat32) -> async GetPlayerResult;
        getPosition : query (teamId : Nat, position : FieldPosition.FieldPosition) -> async Result.Result<Player.Player, GetPositionError>;
        getTeamPlayers : query (teamId : Nat) -> async [Player.Player];
        getAllPlayers : query () -> async [Player.Player];
        populateTeamRoster : (teamId : Nat) -> async PopulateTeamRosterResult;
        applyEffects : (request : ApplyEffectsRequest) -> async ApplyEffectsResult;
        onSeasonEnd : () -> async OnSeasonEndResult;
        swapTeamPositions : (
            teamId : Nat,
            position1 : FieldPosition.FieldPosition,
            position2 : FieldPosition.FieldPosition,
        ) -> async SwapPlayerPositionsResult;
        addMatchStats : (matchGroupId : Nat, playerStats : [Player.PlayerMatchStatsWithId]) -> async AddMatchStatsResult;
    };

    public type GetPositionError = {
        #teamNotFound;
    };

    public type AddMatchStatsError = {
        #notAuthorized;
    };

    public type AddMatchStatsResult = Result.Result<(), AddMatchStatsError>;

    public type SwapPlayerPositionsError = {
        #notAuthorized;
    };

    public type SwapPlayerPositionsResult = Result.Result<(), SwapPlayerPositionsError>;

    public type OnSeasonEndError = {
        #notAuthorized;
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type ApplyEffectsRequest = [Scenario.PlayerEffectOutcome];

    public type ApplyEffectsError = {
        #notAuthorized;
    };

    public type ApplyEffectsResult = Result.Result<(), ApplyEffectsError>;

    public type PopulateTeamRosterError = {
        #missingFluff;
        #notAuthorized;
    };

    public type PopulateTeamRosterResult = Result.Result<[Player.Player], PopulateTeamRosterError>;

    public type CreatePlayerFluffRequest = {
        name : Text;
        title : Text;
        description : Text;
        quirks : [Text];
        likes : [Text];
        dislikes : [Text];
    };

    public type InvalidError = {
        #nameTaken;
        #nameNotSpecified;
    };

    public type CreatePlayerFluffError = {
        #notAuthorized;
        #invalid : [InvalidError];
    };

    public type CreatePlayerFluffResult = Result.Result<(), CreatePlayerFluffError>;

    public type GetPlayerError = {
        #notFound;
    };

    public type GetPlayerResult = Result.Result<Player.Player, GetPlayerError>;

    public type SetPlayerTeamError = {
        #playerNotFound;
    };

    public type SetPlayerTeamResult = Result.Result<(), SetPlayerTeamError>;

};
