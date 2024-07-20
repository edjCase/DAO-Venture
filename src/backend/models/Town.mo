import ImageFile "ImageFile";

module {

    public type Town = {
        id : Nat;
        name : Text;
        motto : Text;
        flagImage : ImageFile.ImageFile;

        entropy : Nat;
        currency : Int;
        links : [Link];
    };

    public type Link = {
        name : Text;
        url : Text;
    };
};
