import Player "../models/Player";
import FieldPosition "../models/FieldPosition";
import Principal "mo:base/Principal";
module {

    public type PlayerActor = actor {
        createFluff : (request : CreatePlayerFluffRequest) -> async CreatePlayerFluffResult;
        getPlayer : (id : Nat32) -> async GetPlayerResult;
        getTeamPlayers : (teamId : Principal) -> async [Player.PlayerWithId];
        getAllPlayers : () -> async [PlayerWithId];
        populateTeamRoster : (teamId : Principal) -> async PopulateTeamRosterResult;
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
