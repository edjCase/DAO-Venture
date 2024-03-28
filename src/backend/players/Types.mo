import Player "../models/Player";
import Scenario "../models/Scenario";
import FieldPosition "../models/FieldPosition";
module {

    public type PlayerActor = actor {
        addFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : query (id : Nat32) -> async GetPlayerResult;
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
        setTeamsCanisterId : (canisterId : Principal) -> async SetTeamsCanisterIdResult;
    };

    public type SetTeamsCanisterIdResult = {
        #ok;
        #notAuthorized;
    };

    public type AddMatchStatsResult = {
        #ok;
        #notAuthorized;
    };

    public type SwapPlayerPositionsResult = {
        #ok;
        #notAuthorized;
    };

    public type OnSeasonEndResult = {
        #ok;
        #notAuthorized;
    };

    public type ApplyEffectsRequest = [Scenario.PlayerEffectOutcome];

    public type ApplyEffectsResult = {
        #ok;
        #notAuthorized;
    };

    public type PopulateTeamRosterResult = {
        #ok : [Player.Player];
        #missingFluff;
        #notAuthorized;
        // #teamNotFound; // TODO?
    };

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

    public type CreatePlayerFluffResult = {
        #ok;
        #notAuthorized;
        #invalid : [InvalidError];
    };

    public type GetPlayerResult = {
        #ok : Player.Player;
        #notFound;
    };

    public type SetPlayerTeamResult = {
        #ok;
        #playerNotFound;
    };

};
