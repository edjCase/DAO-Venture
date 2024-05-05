import Player "../models/Player";
import Types "./Types";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Result "mo:base/Result";
import TextX "mo:xtended-text/TextX";
import Scenario "../models/Scenario";
import FieldPosition "../models/FieldPosition";
import IterTools "mo:itertools/Iter";
import Skill "../models/Skill";

module {

    type PlayerInfo = Player.PlayerFluff and {
        id : Nat32;
        teamId : Nat;
        position : FieldPosition.FieldPosition;
        skills : Player.Skills;
        condition : Player.PlayerCondition;
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
        let players : HashMap.HashMap<Nat32, PlayerInfo> = buildPlayerMap(stableData.players);
        let retiredPlayers : HashMap.HashMap<Nat32, RetiredPlayer> = buildRetiredPlayerMap(stableData.retiredPlayers);
        let unusedFluff : Buffer.Buffer<Player.PlayerFluff> = Buffer.fromArray(stableData.unusedFluff);

        public func toStableData() : StableData {
            {
                players = Iter.toArray(players.vals());
                retiredPlayers = Iter.toArray(retiredPlayers.vals());
                unusedFluff = Buffer.toArray(unusedFluff);
            };
        };

        public func get(id : Nat32) : ?PlayerInfo {
            players.get(id);
        };

        public func getAll(teamId : ?Nat) : [PlayerInfo] {
            switch (teamId) {
                case (null) Iter.toArray(players.vals());
                case (?teamId) {
                    players.vals()
                    |> Iter.filter(
                        _,
                        func(player : PlayerInfo) : Bool = player.teamId == teamId,
                    )
                    |> Iter.toArray(_);
                };
            };
        };

        public func addFluff(fluff : Player.PlayerFluff) : Result.Result<(), { #invalid : [Types.InvalidError] }> {
            let errors = Buffer.Buffer<Types.InvalidError>(0);
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

        public func applyEffects(effects : [Scenario.PlayerEffectOutcome]) : {
            #ok;
        } {

            for (effect in effects.vals()) {
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

        public func swapTeamPositions(
            teamId : Nat,
            position1 : FieldPosition.FieldPosition,
            position2 : FieldPosition.FieldPosition,
        ) : {
            #ok;
        } {
            let getPlayerFromPosition = func(position : FieldPosition.FieldPosition) : PlayerInfo {
                let iter = Iter.filter(
                    players.vals(),
                    func(player : PlayerInfo) : Bool = player.teamId == teamId and player.position == position,
                );
                let ?player = iter.next() else Debug.trap("Player not found for team " # Nat.toText(teamId) # " and position " # debug_show (position1));
                return player;
            };

            let player1 = getPlayerFromPosition(position1);
            let player2 = getPlayerFromPosition(position2);

            players.put(player1.id, { player1 with position = position2 });
            players.put(player2.id, { player2 with position = position1 });

            #ok;
        };

        public func populateTeamRoster(teamId : Nat) : Result.Result<[PlayerInfo], { #missingFluff }> {
            // TODO validate that the teamid is valid?
            let teamPlayers = getAll(?teamId);
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
                    func(p : PlayerInfo) : Bool {
                        p.position == position;
                    },
                );
                if (positionIsFilled) {
                    continue l;
                };
                let ?playerFluff = unusedFluff.getOpt(0) else return #err(#missingFluff); // TODO random or next?

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
                let newPlayer : PlayerInfo = {
                    playerFluff with
                    id = nextPlayerId;
                    skills = skills;
                    position = position;
                    teamId = teamId;
                    condition = #ok;
                };
                newPlayersBuffer.add({
                    newPlayer with
                    teamId = teamId;
                    id = nextPlayerId;
                });
                players.put(newPlayer.id, newPlayer);
                nextPlayerId += 1;
                ignore unusedFluff.remove(0);
            };
            #ok(Buffer.toArray(newPlayersBuffer));
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

        private func updatePlayer(playerId : Nat32, updateFunc : (player : PlayerInfo) -> PlayerInfo) {
            let ?player = players.get(playerId) else Debug.trap("Player not found: " # Nat32.toText(playerId)); // TODO trap?

            let newPlayer = updateFunc(player);

            players.put(playerId, newPlayer);
        };

        private func getTargetPlayerIds(target : Scenario.TargetInstance) : [Nat32] {
            let filterFunc : PlayerInfo -> Bool = switch (target) {
                case (#league) func(player : PlayerInfo) : Bool = true;
                case (#teams(teamIds)) func(player : PlayerInfo) : Bool {
                    Array.indexOf(player.teamId, teamIds, Nat.equal) != null;
                };
                case (#positions(positions)) func(player : PlayerInfo) : Bool {
                    IterTools.any(positions.vals(), func(p : Scenario.TargetPositionInstance) : Bool = p.position == player.position and p.teamId == player.teamId);
                };
            };
            players.vals()
            |> Iter.filter<PlayerInfo>(
                _,
                filterFunc,
            )
            |> Iter.map(
                _,
                func(player : PlayerInfo) : Nat32 = player.id,
            )
            |> Iter.toArray(_);
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

    private func buildPlayerMap(players : [PlayerInfo]) : HashMap.HashMap<Nat32, PlayerInfo> {
        players.vals()
        |> Iter.map<PlayerInfo, (Nat32, PlayerInfo)>(
            _,
            func(p : PlayerInfo) : (Nat32, PlayerInfo) { (p.id, p) },
        )
        |> HashMap.fromIter<Nat32, PlayerInfo>(_, players.size(), Nat32.equal, func(x : Nat32) : Nat32 = x);
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
