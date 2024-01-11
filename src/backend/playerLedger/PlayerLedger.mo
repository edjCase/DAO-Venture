import Trie "mo:base/Trie";
import Player "../models/Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import Types "Types";
// import LeagueActor "canister:league"; TODO

actor PlayerLedger {

    stable var nextPlayerId : Nat32 = 1;
    stable var players = Trie.empty<Nat32, Types.Player>();
    stable var futurePlayers : [Types.FuturePlayer] = [];
    stable var retiredPlayers = Trie.empty<Nat32, Types.RetiredPlayer>();

    public shared ({ caller }) func createFluff(request : Types.CreatePlayerFluffRequest) : async Types.CreatePlayerFluffResult {
        assertLeague(caller);

        switch (validateRequest(request)) {
            case (null) {};
            case (?o) {
                return #invalid(o);
            };
        };

        let newFuturePlayers = Buffer.fromArray<Types.FuturePlayer>(futurePlayers);
        newFuturePlayers.add(request);
        futurePlayers := Buffer.toArray(newFuturePlayers);
        #created;
    };

    public query ({ caller }) func getPlayer(id : Nat32) : async Types.GetPlayerResult {
        let key = {
            key = id;
            hash = id;
        };
        let playerInfo = Trie.get(players, key, Nat32.equal);
        switch (playerInfo) {
            case (?playerInfo) #ok({
                playerInfo with
                id = id;
            });
            case (null) #notFound;
        };
    };

    public query func getTeamPlayers(teamId : Principal) : async [Player.TeamPlayerWithId] {
        getTeamPlayersInternal(teamId);
    };

    public query func getAllPlayers() : async [Types.PlayerWithId] {
        players
        |> Trie.toArray(_, func(k : Nat32, p : Types.Player) : Types.PlayerWithId = { p with id = k });
    };

    public shared ({ caller }) func populateTeamRoster(teamId : Principal) : async Types.PopulateTeamRosterResult {
        assertLeague(caller);
        // TODO validate that the teamid is valid?
        let teamPlayers = getTeamPlayersInternal(teamId);
        let allPositions = [
            #pitcher,
            #firstBase,
            #secondBase,
            #thirdBase,
            #shortStop,
            #leftField,
            #centerField,
            #rightField,
        ];
        let futurePlayersBuffer = Buffer.fromArray<Types.FuturePlayer>(futurePlayers);
        let newPlayersBuffer = Buffer.Buffer<Player.TeamPlayerWithId>(1);
        label l for (position in Iter.fromArray(allPositions)) {
            let positionIsFilled = teamPlayers
            |> Iter.fromArray(_)
            |> IterTools.any(
                _,
                func(p : Player.TeamPlayerWithId) : Bool {
                    p.position == position;
                },
            );
            if (positionIsFilled) {
                continue l;
            };
            let ?futurePlayer = futurePlayersBuffer.getOpt(0) else return #noMorePlayers;

            // TODO randomize skills
            let skills : Player.Skills = switch (position) {
                case (#pitcher) {
                    {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 1;
                        throwingPower = 1;
                        catching = 0;
                        defense = 0;
                        piety = 0;
                        speed = 0;
                    };
                };
                case (#firstBase or #secondBase or #thirdBase or #shortStop) {
                    {
                        battingAccuracy = 1;
                        battingPower = 1;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 0;
                        defense = 0;
                        piety = 0;
                        speed = 0;
                    };
                };
                case (#leftField or #centerField or #rightField) {
                    {
                        battingAccuracy = 0;
                        battingPower = 0;
                        throwingAccuracy = 0;
                        throwingPower = 0;
                        catching = 1;
                        defense = 0;
                        piety = 0;
                        speed = 1;
                    };
                };
            };
            let newPlayer : Types.Player = {
                futurePlayer with
                skills = skills;
                position = position;
                teamId = ?teamId;
            };
            newPlayersBuffer.add({
                newPlayer with
                teamId = teamId;
                id = nextPlayerId;
            });
            let newPlayerKey = {
                key = nextPlayerId;
                hash = nextPlayerId;
            };
            let (newPlayers, _) = Trie.put(players, newPlayerKey, Nat32.equal, newPlayer);
            players := newPlayers;
            nextPlayerId += 1;
            ignore futurePlayersBuffer.remove(0);
        };
        #ok(Buffer.toArray(newPlayersBuffer));
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

    private func getTeamPlayersInternal(teamId : Principal) : [Player.TeamPlayerWithId] {
        players
        |> Trie.iter(_)
        |> IterTools.mapFilter(
            _,
            func((playerId, player) : (Nat32, Types.Player)) : ?Player.TeamPlayerWithId {
                if (player.teamId != ?teamId) {
                    return null;
                };
                ?{
                    player with
                    id = playerId;
                    teamId = teamId;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func validateRequest(options : Types.CreatePlayerFluffRequest) : ?[Types.InvalidError] {
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
};
