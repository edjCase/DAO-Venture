import Player "Player";
import Skill "Skill";

module {
    public type Curse = {
        #skill : Skill.Skill;
        #injury : Player.Injury;
    };
};
