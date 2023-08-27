module {
    public type Player = {
        name : Text;
        energy : Nat;
        energyRecoveryRate : Nat;
        condition : PlayerCondition;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
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
