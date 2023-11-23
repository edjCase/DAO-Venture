import Trie "mo:base/Trie";
import Player "../models/Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import TextX "mo:xtended-text/TextX";
import Types "Types";
// import LeagueActor "canister:league"; TODO

actor PlayerLedger {

    stable var nextPlayerId : Nat32 = 1;
    stable var players = Trie.empty<Nat32, Player.Player>();

    public shared ({ caller }) func create(options : Types.CreatePlayerRequest) : async Types.CreatePlayerResult {
        assertLeague(caller);

        switch (validateOptions(options)) {
            case (null) {};
            case (?o) {
                return #invalid(o);
            };
        };

        let id = nextPlayerId;
        nextPlayerId += 1;
        let player = generatePlayer(options);
        let key = {
            key = id;
            hash = id;
        };
        let (newPlayers, oldPlayer) = Trie.put(players, key, Nat32.equal, player);
        if (oldPlayer != null) {
            Debug.trap("Player id '" # Nat32.toText(id) # "' already exists");
        };
        players := newPlayers;
        #created(id);
    };

    public query ({ caller }) func getPlayer(id : Nat32) : async Types.GetPlayerResult {
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

    public query func getTeamPlayers(teamId : ?Principal) : async [Player.PlayerWithId] {
        let teamPlayers = Trie.filter(players, func(k : Nat32, p : Player.Player) : Bool = p.teamId == teamId);
        Trie.toArray(teamPlayers, func(k : Nat32, p : Player.Player) : Player.PlayerWithId = { p with id = k });
    };

    public query func getAllPlayers() : async [Player.PlayerWithId] {
        Trie.toArray(players, func(k : Nat32, p : Player.Player) : Player.PlayerWithId = { p with id = k });
    };

    public shared ({ caller }) func setPlayerTeam(playerId : Nat32, teamId : ?Principal) : async Types.SetPlayerTeamResult {
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

    private func validateOptions(options : Types.CreatePlayerRequest) : ?[Types.InvalidError] {
        let errors = Buffer.Buffer<Types.InvalidError>(0);
        if (TextX.isEmptyOrWhitespace(options.name)) {
            errors.add(#nameNotSpecified);
        };
        for ((playerId, player) in Trie.iter(players)) {
            if (player.name == options.name) {
                errors.add(#nameTaken);
            };
        };
        if (errors.size() < 1) {
            null;
        } else {
            ?Buffer.toArray(errors);
        };
    };

    private func assertLeague(caller : Principal) {
        // TODO
        // if (caller != Principal.fromActor(LeagueActor)) {
        //     Debug.trap("Only the league can create players");
        // };
    };

    private func generatePlayer(options : Types.CreatePlayerRequest) : Player.Player {
        {
            name = options.name;
            teamId = options.teamId;
            condition = #ok;
            position = options.position;
            skills = options.skills;
            deity = options.deity;
        };
    };
};
