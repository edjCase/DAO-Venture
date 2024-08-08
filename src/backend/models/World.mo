import HexGrid "HexGrid";
module {
    public type WorldLocation = {
        kind : LocationKind;
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        // anomoly : ?Anomoly;
    };

    public type LocationKind = {
        #unexplored : UnexploredLocation;
        #town : TownLocation;
        #resource : ResourceLocation;
    };

    public type UnexploredLocation = {
        currentExploration : Nat;
        explorationNeeded : Nat;
    };

    public type TownLocation = {
        townId : Nat;
    };

    public type ResourceLocation = {
        kind : ResourceKind;
        rarity : ResourceRarity;
        claimedByTownIds : [Nat];
    };

    public type ResourceRarity = {
        #common;
        #uncommon;
        #rare;
    };

    public type ResourceKind = {
        #gold;
        #wood;
        #food;
        #stone;
    };

    public type ResourceList = {
        gold : Nat;
        wood : Nat;
        food : Nat;
        stone : Nat;
    };
};
