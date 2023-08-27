import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Stadium "../Stadium";
import Player "../Player";
import Array "mo:base/Array";
import Nat "mo:base/Nat";

module {
    type PlayerState = Stadium.PlayerState;
    type Event = Stadium.Event;
    type BaseInfo = Stadium.BaseInfo;
    type MatchState = Stadium.MatchState;
    type TeamState = Stadium.TeamState;
    type TeamLineup = Stadium.TeamLineup;
    type InProgressMatchState = Stadium.InProgressMatchState;
    type PlayerWithId = Player.PlayerWithId;

    type MutableTeamState = {
        var score : Int;
        var battingOrder : Buffer.Buffer<Nat32>;
        var players : Buffer.Buffer<PlayerState>;
        var currentBatterIndex : Nat;
    };

    type MutableMatchState = {
        team1StartOffense : Bool;
        var team1 : MutableTeamState;
        var team2 : MutableTeamState;
        var events : Buffer.Buffer<Event>;
        var firstBase : BaseInfo;
        var secondBase : BaseInfo;
        var thirdBase : BaseInfo;
        var atBat : ?Nat;
        var round : Nat;
        var outs : Nat;
        var strikes : Nat;
        var balls : Nat;
    };

    public type TeamInitData = {
        id : Principal;
        lineup : ?TeamLineup;
        players : [PlayerWithId];
    };

    public func initState(team1 : TeamInitData, team2 : TeamInitData) : MatchState {

        let (team1Lineup, team2Lineup) : (TeamLineup, TeamLineup) = switch (team1.lineup, team2.lineup) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?team1Lineup, ?team2Lineup)(team1Lineup, team2Lineup);
        };
        let mapPlayerState = func(player : PlayerWithId) : PlayerState {
            {
                id = player.id;
                name = player.name;
                position = null;
                energy = player.energy;
                condition = player.condition;
            };
        };
        let team1Players : [PlayerState] = Array.map(team1.players, mapPlayerState);
        let team2Players : [PlayerState] = Array.map(team2.players, mapPlayerState);
        #inProgress({
            team1StartOffense = true; // TODO randomize
            team1 = {
                score = 0;
                battingOrder = team1Lineup.battingOrder;
                players = team1Players;
                currentBatterIndex = 0;
            };
            team2 = {
                score = 0;
                battingOrder = team2Lineup.battingOrder;
                players = team2Players;
                currentBatterIndex = 0;
            };
            events = [];
            firstBase = {
                player = null;
            };
            secondBase = {
                player = null;
            };
            thirdBase = {
                player = null;
            };
            atBat = null;
            round = 0;
            outs = 0;
            strikes = 0;
            balls = 0;
        });
    };

    public func tick(state : InProgressMatchState) : MatchState {
        let simulation = MatchSimulation(state);
        let atBat = if (state.atBat == null) {
            sendNextPlayerToBat(simulation);
        };

        simulation.getState();
    };

    private func sendNextPlayerToBat(simulation : MatchSimulation) {
        let nextBatter = simulation.incrementBattingOrder();
        let nextBatterName = simulation.getPlayerName(nextBatter);
        simulation.addEvent({
            description = "Player " # nextBatterName # " is up to bat";
            effect = #movePlayerOffsense({
                playerId = nextBatter;
                position = #atBat;
            });
        });
    };

    class MatchSimulation(initialState : InProgressMatchState) {

        private func toMutableState(state : InProgressMatchState) : MutableMatchState {
            {
                team1StartOffense = initialState.team1StartOffense;
                var team1 = toMutableTeam(initialState.team1);
                var team2 = toMutableTeam(initialState.team2);
                var events = Buffer.fromArray<Event>(initialState.events);
                var firstBase = initialState.firstBase;
                var secondBase = initialState.secondBase;
                var thirdBase = initialState.thirdBase;
                var atBat = initialState.atBat;
                var round = initialState.round;
                var outs = initialState.outs;
                var strikes = initialState.strikes;
                var balls = initialState.balls;
            };
        };

        private func toMutableTeam(team : TeamState) : MutableTeamState {
            {
                var score = team.score;
                var battingOrder = Buffer.fromArray<Nat32>(team.battingOrder);
                var players = Buffer.fromArray<PlayerState>(team.players);
                var currentBatterIndex = team.currentBatterIndex;
            };
        };

        let state : MutableMatchState = toMutableState(initialState);
        var playerNameMapCache : ?Trie.Trie<Nat32, Text> = null;

        public func getState() : MatchState {
            #inProgress({
                team1StartOffense = state.team1StartOffense;
                team1 = {
                    score = state.team1.score;
                    battingOrder = Buffer.toArray(state.team1.battingOrder);
                    players = Buffer.toArray(state.team1.players);
                    currentBatterIndex = state.team1.currentBatterIndex;
                };
                team2 = {
                    score = state.team2.score;
                    battingOrder = Buffer.toArray(state.team2.battingOrder);
                    players = Buffer.toArray(state.team2.players);
                    currentBatterIndex = state.team2.currentBatterIndex;
                };
                events = Buffer.toArray(state.events);
                firstBase = state.firstBase;
                secondBase = state.secondBase;
                thirdBase = state.thirdBase;
                atBat = state.atBat;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
                balls = state.balls;
            });
        };

        public func incrementBattingOrder() : Nat32 {
            let team = if (state.team1StartOffense) {
                state.team1;
            } else {
                state.team2;
            };
            team.currentBatterIndex += 1;
            if (team.currentBatterIndex >= team.battingOrder.size()) {
                team.currentBatterIndex := 0;
            };
            team.battingOrder.get(team.currentBatterIndex);
        };

        public func getPlayerName(playerId : Nat32) : Text {
            let playerMap : Trie.Trie<Nat32, Text> = switch (playerNameMapCache) {
                case (null) {
                    var map = Trie.empty<Nat32, Text>();
                    let add = func(players : Buffer.Buffer<PlayerState>) : () {
                        for (player in players.vals()) {
                            let key = {
                                key = player.id;
                                hash = player.id;
                            };
                            let (newMap, _) = Trie.put<Nat32, Text>(map, key, Nat32.equal, player.name);
                            map := newMap;
                        };
                    };
                    add(state.team1.players);
                    add(state.team2.players);
                    playerNameMapCache := ?map;
                    map;
                };
                case (?map) {
                    map;
                };
            };
            let key = {
                key = playerId;
                hash = playerId;
            };
            let ?name = Trie.get(playerMap, key, Nat32.equal) else return "Unknown Player";
            name;
        };

        public func addEvent(event : Event) : () {
            state.events.add(event);
            switch (event.effect) {
                case (#changePlayer(changePlayer)) {
                    let team = switch (changePlayer.teamId) {
                        case (#team1) state.team1;
                        case (#team2) state.team2;
                    };
                    // Swap the players in the batting order
                    team.battingOrder := Buffer.map(
                        team.battingOrder,
                        func(playerId : Nat32) : Nat32 {
                            if (playerId == changePlayer.playerOutId) {
                                changePlayer.playerInId;
                            } else {
                                playerId;
                            };
                        },
                    );

                    // TODO - swap the players in the field or on base

                };
                case (#increaseScore(increaseScore)) {
                    let team = switch (increaseScore.teamId) {
                        case (#team1) state.team1;
                        case (#team2) state.team2;
                    };
                    team.score := team.score + increaseScore.amount;
                };
                case (#injurePlayer(injurePlayer)) {
                    // TODO modify player state
                    // TODO modify player position/sub
                    // TODO modify player energy?
                };
                case (#killPlayer(killPlayer)) {
                    // TODO modify player state
                    // TODO modify player position/sub
                };
                case (#increaseEnergy(increaseEnergy)) {
                    // TODO modify player state
                    // TODO if energy too low, sub out
                };
                case (#movePlayerOffsense(movePlayerOffsense)) {
                    // TODO modify player position/sub
                };
            };
        };

    };
};
