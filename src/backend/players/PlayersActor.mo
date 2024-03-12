import Trie "mo:base/Trie";
import Player "../models/Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import PseudoRandomX "mo:random/PseudoRandomX";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import Types "Types";
import Trait "../models/Trait";
import Scenario "../models/Scenario";
import Skill "../models/Skill";
// import LeagueActor "canister:league"; TODO

actor {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var nextPlayerId : Nat32 = 1;
    stable var players = Trie.empty<Nat32, Types.Player>();
    stable var stats = Trie.empty<Nat32, Trie.Trie<Nat, Player.PlayerMatchStats>>();
    stable var traits = Trie.empty<Text, Trait.Trait>();
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

    public query func getPlayer(id : Nat32) : async Types.GetPlayerResult {
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

    public query func getTeamPlayers(teamId : Principal) : async [Player.PlayerWithId] {
        getTeamPlayersInternal(teamId);
    };

    public query func getAllPlayers() : async [Types.PlayerWithId] {
        players
        |> Trie.toArray(_, func(k : Nat32, p : Types.Player) : Types.PlayerWithId = { p with id = k });
    };

    // TODO REMOVE DELETING METHODS
    public shared func clearPlayers() : async () {
        players := Trie.empty<Nat32, Types.Player>();
        stats := Trie.empty<Nat32, Trie.Trie<Nat, Player.PlayerMatchStats>>();
        futurePlayers := [];
        retiredPlayers := Trie.empty<Nat32, Types.RetiredPlayer>();
        nextPlayerId := 1;
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
        let newPlayersBuffer = Buffer.Buffer<Player.PlayerWithId>(1);
        label l for (position in Iter.fromArray(allPositions)) {
            let positionIsFilled = teamPlayers
            |> Iter.fromArray(_)
            |> IterTools.any(
                _,
                func(p : Player.PlayerWithId) : Bool {
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
                        speed = 1;
                    };
                };
            };
            let newPlayer : Types.Player = {
                futurePlayer with
                skills = skills;
                position = position;
                teamId = teamId;
                traitIds = []; // TODO
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
        futurePlayers := Buffer.toArray(futurePlayersBuffer);
        #ok(Buffer.toArray(newPlayersBuffer));
    };

    // TODO REMOVE DELETING METHODS
    public shared func clearTraits() : async () {
        traits := Trie.empty<Text, Trait.Trait>();
    };

    public shared query func getTraits() : async [Trait.Trait] {
        traits
        |> Trie.toArray(_, func(_ : Text, t : Trait.Trait) : Trait.Trait = t);
    };

    public shared ({ caller }) func addTrait(request : Types.AddTraitRequest) : async Types.AddTraitResult {
        assertLeague(caller);
        let traitKey = {
            key = request.id;
            hash = Text.hash(request.id);
        };
        let (newTraits, oldTrait) = Trie.put(traits, traitKey, Text.equal, request);
        if (oldTrait != null) {
            return #idTaken;
        };
        traits := newTraits;
        #ok;
    };

    public shared ({ caller }) func applyEffects(request : Types.ApplyEffectsRequest) : async Types.ApplyEffectsResult {
        assertLeague(caller);
        for (effect in Iter.fromArray(request)) {
            switch (effect) {
                case (#skill(skillEffect)) {
                    let targetPlayerIds = getTargetPlayerIds(skillEffect.target);
                    for (playerId in Iter.fromArray(targetPlayerIds)) {
                        updatePlayer(
                            playerId,
                            func(player) {
                                let newSkills = Skill.modify(player.skills, skillEffect.skill, skillEffect.delta);

                                {
                                    player with
                                    skills = newSkills
                                };
                            },
                        );
                    };
                };
                case (#injury(injuryEffect)) {
                    let targetPlayerIds = getTargetPlayerIds(injuryEffect.target);
                    for (playerId in Iter.fromArray(targetPlayerIds)) {
                        updatePlayer(
                            playerId,
                            func(player) {
                                // TODO how to remove effect?
                                {
                                    player with
                                    injury = injuryEffect.injury;
                                };
                            },
                        );
                    };
                };
            };
        };
        #ok;
    };

    public shared ({ caller }) func addMatchStats(matchGroupId : Nat, playerStats : [Player.PlayerMatchStatsWithId]) : async () {
        assertLeague(caller);

        let matchGroupKey = {
            key = matchGroupId;
            hash = Nat32.fromNat(matchGroupId); // TODO
        };
        for (playerStat in Iter.fromArray(playerStats)) {
            let playerKey = {
                key = playerStat.playerId;
                hash = playerStat.playerId;
            };
            let playerMatchGroupStats = switch (Trie.get(stats, playerKey, Nat32.equal)) {
                case (null) Trie.empty<Nat, Player.PlayerMatchStats>();
                case (?p) p;
            };

            let (newPlayerMatchGroupStats, oldPlayerStat) = Trie.put(playerMatchGroupStats, matchGroupKey, Nat.equal, playerStat);
            if (oldPlayerStat != null) {
                Debug.trap("Player match stats already exist for match group: " # Nat.toText(matchGroupId) # " and player: " # Nat32.toText(playerStat.playerId));
            };
            let (newStats, _) = Trie.put(stats, playerKey, Nat32.equal, newPlayerMatchGroupStats);
            stats := newStats;
        };
    };

    public shared ({ caller }) func onSeasonComplete() : async Types.OnSeasonCompleteResult {
        if (not isLeague(caller)) {
            return #notAuthorized;
        };
        // TODO
        stats := Trie.empty<Nat32, Trie.Trie<Nat, Player.PlayerMatchStats>>();
        #ok;
    };

    private func getTargetPlayerIds(target : Scenario.TargetInstance) : [Nat32] {
        let filterFunc = switch (target) {
            case (#league) func((playerId, player) : (Nat32, Types.Player)) : Bool = true;
            case (#teams(teamIds)) func((playerId, player) : (Nat32, Types.Player)) : Bool {
                Array.indexOf(player.teamId, teamIds, Principal.equal) != null;
            };
            case (#players(playerIds)) func((playerId, player) : (Nat32, Types.Player)) : Bool {
                Array.indexOf(playerId, playerIds, Nat32.equal) != null;
            };
        };
        players
        |> Trie.iter(_)
        |> Iter.filter(
            _,
            filterFunc,
        )
        |> Iter.map(
            _,
            func((playerId, player) : (Nat32, Types.Player)) : Nat32 = playerId,
        )
        |> Iter.toArray(_);
    };

    private func updatePlayer(playerId : Nat32, updateFunc : (player : Types.Player) -> Types.Player) {
        let playerKey = {
            key = playerId;
            hash = playerId;
        };
        let ?player = Trie.get(players, playerKey, Nat32.equal) else Debug.trap("Player not found: " # Nat32.toText(playerId)); // TODO trap?

        let newPlayer = updateFunc(player);

        let (newPlayers, _) = Trie.put(players, playerKey, Nat32.equal, newPlayer);
        players := newPlayers;
    };

    private func getTeamPlayersInternal(teamId : Principal) : [Player.PlayerWithId] {
        players
        |> Trie.iter(_)
        |> IterTools.mapFilter(
            _,
            func((playerId, player) : (Nat32, Types.Player)) : ?Player.PlayerWithId {
                if (player.teamId != teamId) {
                    return null;
                };
                ?{
                    player with
                    id = playerId;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func validateRequest(request : Types.CreatePlayerFluffRequest) : ?[Types.InvalidError] {
        let errors = Buffer.Buffer<Types.InvalidError>(0);
        if (TextX.isEmptyOrWhitespace(request.name)) {
            errors.add(#nameNotSpecified);
        };
        for ((playerId, player) in Trie.iter(players)) {
            if (player.name == request.name) {
                errors.add(#nameTaken);
            };
        };
        for (player in Iter.fromArray(futurePlayers)) {
            if (player.name == request.name) {
                errors.add(#nameTaken);
            };
        };
        for ((playerId, player) in Trie.iter(retiredPlayers)) {
            if (player.name == request.name) {
                errors.add(#nameTaken);
            };
        };
        if (errors.size() < 1) {
            null;
        } else {
            ?Buffer.toArray(errors);
        };
    };

    private func isLeague(_ : Principal) : Bool {
        // TODO
        // caller == Principal.fromActor(LeagueActor);
        true;
    };

    private func assertLeague(caller : Principal) {
        if (not isLeague(caller)) {
            Debug.trap("Only the league is authorized to perform this action.");
        };
    };
};
