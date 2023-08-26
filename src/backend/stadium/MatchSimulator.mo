module {
    public type EventEffect = {
        #increaseScore : {
            team : Nat;
            amount : Nat;
        };
        #changePlayer : {
            team : Nat;
            playerIn : Nat;
            playerOut : Nat;
        };
        #injurePlayer : {
            player : Nat;
        };
        #killPlayer : {
            player : Nat;
        };
        #increaseEnergy : {
            player : Nat;
            amount : Int;
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
        id : Nat;
        name : Text;
        energy : Nat;
        condition : PlayerCondition;
    };

    public type TeamState = {
        score : Nat;
        battingOrder : [Nat32];
        players : [PlayerState];
    };

    public type BaseInfo = {
        player : ?Nat;
    };

    public type MatchState = {
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
        // TODO
        state;
    };
};
