import Principal "mo:base/Principal";
import Player "Player";

module {
    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.Player];
    };

    public type Team = {
        canister : TeamActor;
        name : Text;
        logoUrl : Text;
    };
};
