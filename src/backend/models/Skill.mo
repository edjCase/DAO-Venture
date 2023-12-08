import Player "Player";
import PseudoRandomX "mo:random/PseudoRandomX";

module {

    public type Skill = {
        #battingAccuracy;
        #battingPower;
        #throwingAccuracy;
        #throwingPower;
        #catching;
        #defense;
        #piety;
        #speed;
    };

    public func getRandom(prng : PseudoRandomX.PseudoRandomGenerator) : Skill {
        let allSkills = [
            #battingAccuracy,
            #battingPower,
            #throwingAccuracy,
            #throwingPower,
            #catching,
            #defense,
            #piety,
            #speed,
        ]; // TODO how to get this list from variant
        let skillIndex = prng.nextNat(0, allSkills.size() - 1);
        return allSkills[skillIndex];
    };

    public func modifySkill(skills : Player.Skills, skill : Skill, value : Int) : Player.Skills {
        switch (skill) {
            case (#battingAccuracy) {
                return {
                    skills with
                    battingAccuracy = skills.battingAccuracy + value
                };
            };
            case (#battingPower) {
                return {
                    skills with
                    battingPower = skills.battingPower + value
                };
            };
            case (#throwingAccuracy) {
                return {
                    skills with
                    throwingAccuracy = skills.throwingAccuracy + value
                };
            };
            case (#throwingPower) {
                return {
                    skills with
                    throwingPower = skills.throwingPower + value
                };
            };
            case (#catching) {
                return {
                    skills with
                    catching = skills.catching + value
                };
            };
            case (#defense) {
                return {
                    skills with
                    defense = skills.defense + value
                };
            };
            case (#piety) {
                return {
                    skills with
                    piety = skills.piety + value
                };
            };
            case (#speed) {
                return {
                    skills with
                    speed = skills.speed + value
                };
            };
        };
    };
};
