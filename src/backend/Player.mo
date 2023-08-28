module {
    public type Player = {
        name : Text;
        energy : Int;
        energyRecoveryRate : Nat;
        condition : PlayerCondition;
        skills : PlayerSkills;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type PlayerSkills = {
        batting : Int;
        throwing : Int;
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
};
