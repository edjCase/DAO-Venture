import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
module {

    public type PlayerPositionOffense = {
        #atBat;
        #first;
        #second;
        #third;
    };

    public type TeamId = {
        #team1;
        #team2;
    };

    public type EventEffect = {
        #increaseScore : {
            teamId : TeamId;
            amount : Int;
        };
        #changePlayer : {
            teamId : TeamId;
            playerInId : Nat32;
            playerOutId : Nat32;
        };
        #injurePlayer : {
            playerId : Nat32;
        };
        #killPlayer : {
            playerId : Nat32;
        };
        #increaseEnergy : {
            playerId : Nat32;
            amount : Int;
        };
        #movePlayerOffsense : {
            playerId : Nat32;
            position : PlayerPositionOffense;
        };
    };

    public type Event = {
        description : Text;
        effect : EventEffect;
    };

    public type Injury = {
        #twistedAnkle;
        #brokenLeg;
        #brokenArm;
        #concussion;
    };

    public type PlayerCondition = {
        #ok;
        #injured : Injury;
        #dead;
    };

    public type PlayerState = {
        id : Nat32;
        name : Text;
        energy : Nat;
        condition : PlayerCondition;
    };

    public type TeamState = {
        score : Int;
        battingOrder : [Nat32];
        players : [PlayerState];
    };

    public type BaseInfo = {
        player : ?Nat;
    };

    public type MatchState = {
        team1StartOffense : Bool;
        team1 : TeamState;
        team2 : TeamState;
        events : [Event];
        firstBase : BaseInfo;
        secondBase : BaseInfo;
        thirdBase : BaseInfo;
        atBat : ?Nat;
        inning : Nat;
        outs : Nat;
        strikes : Nat;
        balls : Nat;
    };

    public func tick(state : MatchState) : MatchState {
        let simulation = MatchSimulation(state);
        let atBat = if (state.atBat == null) {
            sendNextPlayerToBat(simulation);
        };

        state;
    };

    public func sendNextPlayerToBat(simulation : MatchSimulation) {
        let nextBatter = simulation.incrementBattingOrder();
        let nextBatterName = simulation.getPlayerName(nextBatter);
        simulation.addEvent({
            description = "Player " + nextBatter + " is up to bat";
            effect = #movePlayerOffsense({
                playerId = nextAtBat;
                position = #atBat;
            });
        });
    };

    class MatchSimulation(initialState : MatchState) {
        type MutableTeamState = {
            var score : Int;
            var battingOrder : Buffer.Buffer<Nat32>;
            var players : Buffer.Buffer<PlayerState>;
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
            var inning : Nat;
            var outs : Nat;
            var strikes : Nat;
            var balls : Nat;
        };

        let state : MutableMatchState = toMutableState(initialState);
        var playerNameMapCache : ?Trie.Trie<Nat32, Text> = null;

        public func incrementBattingOrder() : Nat32 {
            let team = if (state.team1StartOffense) {
                state.team1;
            } else {
                state.team2;
            };
            let nextBatter = team.battingOrder[0];
            team.battingOrder := Buffer.shift(team.battingOrder);
            team.battingOrder := Buffer.push(team.battingOrder, nextBatter);
            nextBatter;
        };

        public func getPlayerName(playerId : Nat32) : Text {
            let playerMap = switch (playerNameMapCache) {
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
            Trie.get(playerMap, key, Nat32.equal);
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

        private func toMutableState(state : MatchState) : MutableMatchState {
            {
                team1StartOffense = initialState.team1StartOffense;
                var team1 = toMutableTeam(initialState.team1);
                var team2 = toMutableTeam(initialState.team2);
                var events = Buffer.fromArray<Event>(initialState.events);
                var firstBase = initialState.firstBase;
                var secondBase = initialState.secondBase;
                var thirdBase = initialState.thirdBase;
                var atBat = initialState.atBat;
                var inning = initialState.inning;
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
            };
        };
    };
};
