module {

    public type Outcome<TChoice> = {
        choice : ?TChoice;
        description : [Text];
        effects : [Effect];
    };

    public type Item = {
        #echoCrystal;
        #ancientRunes;
        #mysticalTome;
        #scryingOrb;
    };

    public type Trait = {
        #natureAttuned;
        #thirdEye;
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #item : Item;
        #trait : Trait;
    };

    public type Effect = {
        #money : Int;
        #item : {
            item : Item;
            kind : { #gain; #lose };
        };
        #trait : {
            trait : Trait;
            kind : { #gain; #lose };
        };
        #health : {
            amount : Int;
        };
    };
};
