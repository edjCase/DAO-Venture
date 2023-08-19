import Trie "mo:base/Trie";
import Player "../Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
// import LeagueActor "canister:league"; TODO

actor PlayerLedger {

    type PlayerInfo = {
        player : Player.Player;
        teamId : ?Principal;
    };

    public type PlayerInfoWithId = PlayerInfo and {
        id : Nat32;
    };

    stable var nextPlayerId : Nat32 = 1;
    stable var players = Trie.empty<Nat32, PlayerInfo>();
    var teamPlayers = Trie.empty<Principal, Nat32>();

    public type PlayerCreationOptions = {
        name : Text;
        teamId : ?Principal;
    };

    public shared ({ caller }) func create(options : PlayerCreationOptions) : async Nat32 {
        assertLeague(caller);
        let id = nextPlayerId;
        nextPlayerId += 1;
        let player = generatePlayer(id, options);
        let playerInfo = {
            player = player;
            teamId = options.teamId;
        };
        let key = {
            key = id;
            hash = id;
        };
        let (newPlayers, oldPlayer) = Trie.put(players, key, Nat32.equal, playerInfo);
        if (oldPlayer != null) {
            Debug.trap("Player id '" # Nat32.toText(id) # "' already exists");
        };
        players := newPlayers;
        id;
    };

    public query ({ caller }) func getPlayer(id : Nat32) : async {
        #ok : PlayerInfo;
        #notFound;
    } {
        let key = {
            key = id;
            hash = id;
        };
        let playerInfo = Trie.get(players, key, Nat32.equal);
        switch (playerInfo) {
            case (?playerInfo) #ok(playerInfo);
            case (null) #notFound;
        };
    };

    public query func getTeamPlayers(teamId : ?Principal) : async [PlayerInfoWithId] {
        let teamPlayers = Trie.filter(players, func(k : Nat32, p : PlayerInfo) : Bool = p.teamId == teamId);
        Trie.toArray(teamPlayers, func(k : Nat32, p : PlayerInfo) : PlayerInfoWithId = { p with id = k });
    };

    public query func getAllPlayers() : async [PlayerInfoWithId] {
        Trie.toArray(players, func(k : Nat32, p : PlayerInfo) : PlayerInfoWithId = { p with id = k });
    };

    public shared ({ caller }) func setPlayerTeam(playerId : Nat32, teamId : ?Principal) : async {
        #ok;
        #playerNotFound;
    } {
        assertLeague(caller);
        let playerKey = {
            key = playerId;
            hash = playerId;
        };
        let ?playerInfo = Trie.get(players, playerKey, Nat32.equal) else return #playerNotFound;
        let newPlayerInfo = {
            playerInfo with
            teamId = teamId;
        };
        let (newPlayers, _) = Trie.put(players, playerKey, Nat32.equal, newPlayerInfo);
        players := newPlayers;
        #ok;
    };

    private func assertLeague(caller : Principal) {
        // TODO
        // if (caller != Principal.fromActor(LeagueActor)) {
        //     Debug.trap("Only the league can create players");
        // };
    };

    private func generatePlayer(id : Nat32, options : PlayerCreationOptions) : Player.Player {
        {
            id = id;
            name = options.name;
        };
    };
};
