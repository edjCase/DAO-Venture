import Item "entities/Item";
import Trait "entities/Trait";
import Image "Image";
import Scenario "entities/Scenario";
import Race "entities/Race";
import Class "entities/Class";
import Zone "entities/Zone";
import Achievement "entities/Achievement";
import Creature "entities/Creature";
import Weapon "entities/Weapon";
module {

    public type ProposalContent = {
        #motion : MotionContent;
        #modifyGameContent : ModifyGameContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ModifyGameContent = {
        #item : Item.Item;
        #trait : Trait.Trait;
        #image : Image.Image;
        #scenario : Scenario.ScenarioMetaData;
        #race : Race.Race;
        #class_ : Class.Class;
        #zone : Zone.Zone;
        #achievement : Achievement.Achievement;
        #creature : Creature.Creature;
        #weapon : Weapon.Weapon;
    };
};
