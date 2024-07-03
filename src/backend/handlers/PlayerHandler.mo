import Player "../models/Player";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import TextX "mo:xtended-text/TextX";
import Scenario "../models/Scenario";
import FieldPosition "../models/FieldPosition";
import IterTools "mo:itertools/Iter";
import Skill "../models/Skill";

module {
    // Public Types -------------------------------------------------------
    public type PlayerInfo = Player.PlayerFluff and {
        id : Nat32;
        teamId : Nat;
        position : FieldPosition.FieldPosition;
        skills : Player.Skills;
        condition : Player.PlayerCondition;
        matchGroupStats : [(Nat, Player.PlayerMatchStats)];
    };

    public type InvalidError = {
        #nameTaken;
        #nameNotSpecified;
    };

    // Private Types -------------------------------------------------------

    type MutablePlayerInfo = Player.PlayerFluff and {
        id : Nat32;
        var teamId : Nat;
        var position : FieldPosition.FieldPosition;
        var skills : Player.Skills;
        var condition : Player.PlayerCondition;
        matchGroupStats : HashMap.HashMap<Nat, Player.PlayerMatchStats>;
    };

    type RetiredPlayer = Player.PlayerFluff and {
        id : Nat32;
        name : Text;
        teamId : Nat;
        position : FieldPosition.FieldPosition;
        skills : Player.Skills;
    };

    public type StableData = {
        players : [PlayerInfo];
        retiredPlayers : [RetiredPlayer];
        unusedFluff : [Player.PlayerFluff];
    };

    public class PlayerHandler(stableData : StableData) {
        let players : HashMap.HashMap<Nat32, MutablePlayerInfo> = buildPlayerMap(stableData.players);
        let retiredPlayers : HashMap.HashMap<Nat32, RetiredPlayer> = buildRetiredPlayerMap(stableData.retiredPlayers);
        let unusedFluff : Buffer.Buffer<Player.PlayerFluff> = Buffer.fromArray(stableData.unusedFluff);

        public func toStableData() : StableData {
            let stablePlayers = players.vals()
            |> Iter.map(
                _,
                mapPlayerInfo,
            )
            |> Iter.toArray(_);
            {
                players = stablePlayers;
                retiredPlayers = Iter.toArray(retiredPlayers.vals());
                unusedFluff = Buffer.toArray(unusedFluff);
            };
        };

        public func get(id : Nat32) : ?PlayerInfo {
            let ?player = players.get(id) else return null;
            ?mapPlayerInfo(player);
        };

        public func getPosition(teamId : Nat, position : FieldPosition.FieldPosition) : ?PlayerInfo {
            let ?player = IterTools.find(
                players.vals(),
                func(player : MutablePlayerInfo) : Bool = player.teamId == teamId and player.position == position,
            ) else return null;
            ?mapPlayerInfo(player);
        };

        public func getAll(teamId : ?Nat) : [PlayerInfo] {
            let allPlayers = switch (teamId) {
                case (null) players.vals();
                case (?teamId) {
                    players.vals()
                    |> Iter.filter(
                        _,
                        func(player : MutablePlayerInfo) : Bool = player.teamId == teamId,
                    );
                };
            };
            allPlayers
            |> Iter.map(
                _,
                mapPlayerInfo,
            )
            |> Iter.toArray(_);
        };

        public func addFluff(fluff : Player.PlayerFluff) : Result.Result<(), { #invalid : [InvalidError] }> {
            Debug.print("Adding player fluff: " # debug_show (fluff));
            let errors = Buffer.Buffer<InvalidError>(0);
            if (TextX.isEmptyOrWhitespace(fluff.name)) {
                errors.add(#nameNotSpecified);
            };
            if (isNameTaken(fluff.name)) {
                errors.add(#nameTaken);
            };
            if (errors.size() > 0) {
                return #err(#invalid(Buffer.toArray(errors)));
            };

            unusedFluff.add(fluff);
            #ok;
        };

        public func addMatchStats(
            matchGroupId : Nat,
            playerStats : [Player.PlayerMatchStatsWithId],
        ) : Result.Result<(), { #playerNotFound : Nat32; #matchGroupStatsExist : { playerId : Nat32; matchGroupId : Nat } }> {
            for (playerStat in Iter.fromArray(playerStats)) {
                let ?player = players.get(playerStat.playerId) else return #err(#playerNotFound(playerStat.playerId));
                if (player.matchGroupStats.get(matchGroupId) != null) {
                    return #err(#matchGroupStatsExist({ playerId = playerStat.playerId; matchGroupId }));
                };
                player.matchGroupStats.put(matchGroupId, playerStat);
            };
            #ok;
        };

        public func applyEffects(effects : [Scenario.PlayerEffectOutcome]) : {
            #ok;
        } {

            for (effect in effects.vals()) {
                switch (effect) {
                    case (#skill(skillEffect)) {
                        let targetPlayer = getTargetPlayer(skillEffect.target);
                        targetPlayer.skills := Skill.modify(targetPlayer.skills, skillEffect.skill, skillEffect.delta);
                    };
                    case (#injury(injuryEffect)) {
                        let targetPlayer = getTargetPlayer(injuryEffect.target);
                        // TODO how to remove effect?
                        targetPlayer.condition := #injured;
                    };
                };
            };
            #ok;
        };

        public func swapTeamPositions(
            teamId : Nat,
            position1 : FieldPosition.FieldPosition,
            position2 : FieldPosition.FieldPosition,
        ) : {
            #ok;
        } {
            let getPlayerFromPosition = func(position : FieldPosition.FieldPosition) : MutablePlayerInfo {
                let iter = Iter.filter(
                    players.vals(),
                    func(player : MutablePlayerInfo) : Bool = player.teamId == teamId and player.position == position,
                );
                let ?player = iter.next() else Debug.trap("Player not found for team " # Nat.toText(teamId) # " and position " # debug_show (position1));
                return player;
            };

            let player1 = getPlayerFromPosition(position1);
            let player2 = getPlayerFromPosition(position2);
            let temp = player1.position;
            player1.position := player2.position;
            player2.position := temp;

            #ok;
        };

        public func populateTeamRoster(teamId : Nat) : Result.Result<[PlayerInfo], { #missingFluff }> {
            Debug.print("Populating team roster for team " # Nat.toText(teamId));
            // TODO validate that the teamid is valid?
            let teamPlayers = players.vals()
            |> Iter.filter(
                _,
                func(player : MutablePlayerInfo) : Bool = player.teamId == teamId,
            )
            |> Iter.toArray(_);
            let allPositions : [FieldPosition.FieldPosition] = [
                #pitcher,
                #firstBase,
                #secondBase,
                #thirdBase,
                #shortStop,
                #leftField,
                #centerField,
                #rightField,
            ];
            var nextPlayerId = getNextPlayerId();
            let newPlayersBuffer = Buffer.Buffer<PlayerInfo>(1);
            label l for (position in Iter.fromArray(allPositions)) {
                let positionIsFilled = teamPlayers
                |> Iter.fromArray(_)
                |> IterTools.any(
                    _,
                    func(p : MutablePlayerInfo) : Bool {
                        p.position == position;
                    },
                );
                if (positionIsFilled) {
                    continue l;
                };
                let ?playerFluff : ?Player.PlayerFluff = unusedFluff.getOpt(0) else return #err(#missingFluff); // TODO random or next?

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
                let newPlayer : MutablePlayerInfo = {
                    id = nextPlayerId;
                    name = playerFluff.name;
                    title = playerFluff.title;
                    description = playerFluff.description;
                    dislikes = playerFluff.dislikes;
                    likes = playerFluff.likes;
                    quirks = playerFluff.quirks;
                    var skills = skills;
                    var position = position;
                    var teamId = teamId;
                    var condition = #ok;
                    matchGroupStats = HashMap.HashMap<Nat, Player.PlayerMatchStats>(0, Nat.equal, Nat32.fromNat);
                };
                newPlayersBuffer.add(mapPlayerInfo(newPlayer));
                players.put(newPlayer.id, newPlayer);
                nextPlayerId += 1;
                ignore unusedFluff.remove(0);
            };
            #ok(Buffer.toArray(newPlayersBuffer));
        };

        private func mapPlayerInfo(mutable : MutablePlayerInfo) : PlayerInfo {
            let matchGroupStats = mutable.matchGroupStats.entries()
            |> Iter.toArray(_);
            {
                mutable with
                id = mutable.id;
                teamId = mutable.teamId;
                position = mutable.position;
                skills = {
                    battingAccuracy = mutable.skills.battingAccuracy;
                    battingPower = mutable.skills.battingPower;
                    throwingAccuracy = mutable.skills.throwingAccuracy;
                    throwingPower = mutable.skills.throwingPower;
                    catching = mutable.skills.catching;
                    defense = mutable.skills.defense;
                    speed = mutable.skills.speed;
                };
                condition = mutable.condition;
                matchGroupStats = matchGroupStats;
            };
        };

        private func getNextPlayerId() : Nat32 {
            var nextId : Nat32 = 0;
            for (player in players.vals()) {
                if (player.id >= nextId) {
                    nextId := player.id + 1;
                };
            };
            for (player in retiredPlayers.vals()) {
                if (player.id >= nextId) {
                    nextId := player.id + 1;
                };
            };
            nextId;
        };

        private func getTargetPlayer(target : Scenario.TargetPositionInstance) : MutablePlayerInfo {
            let ?player = IterTools.find(
                players.vals(),
                func(player : MutablePlayerInfo) : Bool = player.teamId == target.teamId and player.position == target.position,
            ) else Debug.trap("Player not found for team " # Nat.toText(target.teamId) # " and position " # debug_show (target.position));
            player;
        };

        private func isNameTaken(name : Text) : Bool {
            for (player in getAll(null).vals()) {
                if (player.name == name) {
                    return true;
                };
            };
            for (player in unusedFluff.vals()) {
                if (player.name == name) {
                    return true;
                };
            };
            for (player in retiredPlayers.vals()) {
                if (player.name == name) {
                    return true;
                };
            };
            false;
        };
    };

    private func buildPlayerMap(players : [PlayerInfo]) : HashMap.HashMap<Nat32, MutablePlayerInfo> {
        players.vals()
        |> Iter.map<PlayerInfo, (Nat32, MutablePlayerInfo)>(
            _,
            func(p : PlayerInfo) : (Nat32, MutablePlayerInfo) {
                let mutableMatchGroupStats = HashMap.fromIter<Nat, Player.PlayerMatchStats>(p.matchGroupStats.vals(), p.matchGroupStats.size(), Nat.equal, Nat32.fromNat);
                let mutablePlayer : MutablePlayerInfo = {
                    id = p.id;
                    var teamId = p.teamId;
                    name = p.name;
                    title = p.title;
                    description = p.description;
                    dislikes = p.dislikes;
                    likes = p.likes;
                    quirks = p.quirks;
                    var skills = p.skills;
                    var position = p.position;
                    var condition = p.condition;
                    matchGroupStats = mutableMatchGroupStats;
                };
                (p.id, mutablePlayer);
            },
        )
        |> HashMap.fromIter<Nat32, MutablePlayerInfo>(_, players.size(), Nat32.equal, func(x : Nat32) : Nat32 = x);
    };

    private func buildRetiredPlayerMap(retiredPlayers : [RetiredPlayer]) : HashMap.HashMap<Nat32, RetiredPlayer> {
        retiredPlayers.vals()
        |> Iter.map<RetiredPlayer, (Nat32, RetiredPlayer)>(
            _,
            func(player : RetiredPlayer) : (Nat32, RetiredPlayer) {
                (player.id, player);
            },
        )
        |> HashMap.fromIter<Nat32, RetiredPlayer>(_, retiredPlayers.size(), Nat32.equal, func(x : Nat32) : Nat32 = x);
    };
};
