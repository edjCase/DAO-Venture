import FieldPosition "FieldPosition";
module {
    public type PlayerId = Nat32;

    public type PlayerFluff = {
        name : Text;
        title : Text;
        description : Text;
        quirks : [Text];
        likes : [Text];
        dislikes : [Text];
    };

    public type Player = PlayerFluff and {
        id : Nat32;
        teamId : Nat;
        skills : Skills;
        position : FieldPosition.FieldPosition;
    };
    public type Skills = {
        battingAccuracy : Int;
        battingPower : Int;
        throwingAccuracy : Int;
        throwingPower : Int;
        catching : Int;
        defense : Int;
        speed : Int;

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

    public type PlayerMatchStats = {
        battingStats : {
            atBats : Nat;
            hits : Nat;
            strikeouts : Nat;
            runs : Nat;
            homeRuns : Nat;
        };
        catchingStats : {
            successfulCatches : Nat;
            missedCatches : Nat;
            throws : Nat;
            throwOuts : Nat;
        };
        pitchingStats : {
            pitches : Nat;
            strikes : Nat;
            hits : Nat;
            strikeouts : Nat;
            runs : Nat;
            homeRuns : Nat;
        };
        injuries : Nat;
    };

    public type PlayerMatchStatsWithId = PlayerMatchStats and {
        playerId : PlayerId;
    };
};
