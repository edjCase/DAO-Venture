import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
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

    public type FreeAgentPlayer = PlayerFluff and {
        skills : Skills;
        position : FieldPosition.FieldPosition;
    };

    public type TeamPlayer = FreeAgentPlayer and {
        teamId : Principal;
    };

    public type FreeAgentPlayerWithId = FreeAgentPlayer and {
        id : Nat32;
    };

    public type TeamPlayerWithId = TeamPlayer and {
        id : Nat32;
    };

    public type Skills = {
        battingAccuracy : Int;
        battingPower : Int;
        throwingAccuracy : Int;
        throwingPower : Int;
        catching : Int;
        defense : Int;
        piety : Int;
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

};
