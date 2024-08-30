module {
    public type PixelImage = {
        palette : [(Nat8, Nat8, Nat8)];
        pixelData : [PixelData];
    };

    public type PixelData = {
        count : Nat;
        paletteIndex : ?Nat8;
    };
};
