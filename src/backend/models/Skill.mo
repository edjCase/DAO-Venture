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
            #speed,
        ]; // TODO how to get this list from variant
        let skillIndex = prng.nextNat(0, allSkills.size() - 1);
        return allSkills[skillIndex];
    };

    public func get(skills : Player.Skills, skill : Skill) : Int {
        switch (skill) {
            case (#battingAccuracy) skills.battingAccuracy;
            case (#battingPower) skills.battingPower;
            case (#throwingAccuracy) skills.throwingAccuracy;
            case (#throwingPower) skills.throwingPower;
            case (#catching) skills.catching;
            case (#defense) skills.defense;
            case (#speed) skills.speed;
        };
    };

    public func modify(skills : Player.Skills, skill : Skill, delta : Int) : Player.Skills {
        switch (skill) {
            case (#battingAccuracy) {
                return {
                    skills with
                    battingAccuracy = skills.battingAccuracy + delta
                };
            };
            case (#battingPower) {
                return {
                    skills with
                    battingPower = skills.battingPower + delta
                };
            };
            case (#throwingAccuracy) {
                return {
                    skills with
                    throwingAccuracy = skills.throwingAccuracy + delta
                };
            };
            case (#throwingPower) {
                return {
                    skills with
                    throwingPower = skills.throwingPower + delta
                };
            };
            case (#catching) {
                return {
                    skills with
                    catching = skills.catching + delta
                };
            };
            case (#defense) {
                return {
                    skills with
                    defense = skills.defense + delta
                };
            };
            case (#speed) {
                return {
                    skills with
                    speed = skills.speed + delta
                };
            };
        };
    };
};
