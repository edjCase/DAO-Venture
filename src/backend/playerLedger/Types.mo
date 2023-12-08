import Player "../models/Player";
import FieldPosition "../models/FieldPosition";
module {

    public type CreatePlayerRequest = {
        name : Text;
        teamId : ?Principal;
        position : FieldPosition.FieldPosition;
        deity : Player.Deity;
        skills : Player.Skills;
    };

    public type InvalidError = {
        #nameTaken;
        #nameNotSpecified;
    };

    public type CreatePlayerResult = {
        #created : Nat32;
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
