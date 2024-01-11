import Player "../models/Player";
import FieldPosition "../models/FieldPosition";
import Principal "mo:base/Principal";
module {

    public type PopulateTeamRosterResult = {
        #ok : [Player.TeamPlayerWithId];
        #noMorePlayers;
        #notAuthorized;
        // #teamNotFound; // TODO?
    };

    public type CreatePlayerFluffRequest = {
        name : Text;
        genesis : Text;
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

    public type Player = Player.FreeAgentPlayer and {
        teamId : ?Principal;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type RetiredPlayer = Player.FreeAgentPlayer;

    public type FuturePlayer = Player.PlayerFluff;

};
