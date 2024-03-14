import Player "../models/Player";
import Principal "mo:base/Principal";
import Trait "../models/Trait";
import Scenario "../models/Scenario";
module {

    public type PlayerActor = actor {
        createFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : query (id : Nat32) -> async GetPlayerResult;
        getTeamPlayers : query (teamId : Nat) -> async [Player.PlayerWithId];
        getAllPlayers : query () -> async [PlayerWithId];
        populateTeamRoster : (teamId : Nat) -> async PopulateTeamRosterResult;
        addTrait : (request : AddTraitRequest) -> async AddTraitResult;
        getTraits : query () -> async [Trait.Trait];
        applyEffects : (request : ApplyEffectsRequest) -> async ApplyEffectsResult;
        onSeasonComplete : () -> async OnSeasonCompleteResult;
    };

    public type OnSeasonCompleteResult = {
        #ok;
        #notAuthorized;
    };

    public type ApplyEffectsRequest = [Scenario.PlayerEffectOutcome];

    public type ApplyEffectsResult = {
        #ok;
    };

    public type AddTraitRequest = Trait.Trait;

    public type AddTraitResult = {
        #ok;
        #idTaken;
    };

    public type PopulateTeamRosterResult = {
        #ok : [Player.PlayerWithId];
        #noMorePlayers;
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
        #created;
        #invalid : [InvalidError];
    };

    public type GetPlayerResult = {
        #ok : Player;
        #notFound;
    };

    public type SetPlayerTeamResult = {
        #ok;
        #playerNotFound;
    };

    public type Player = Player.Player;

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type RetiredPlayer = Player.PlayerFluff; // TODO

    public type FuturePlayer = Player.PlayerFluff;

};
