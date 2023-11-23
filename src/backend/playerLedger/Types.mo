import Player "../models/Player";
module {

    public type CreatePlayerRequest = {
        name : Text;
        teamId : ?Principal;
        position : Player.FieldPosition;
        deity : Player.Deity;
        skills : Player.PlayerSkills;
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
