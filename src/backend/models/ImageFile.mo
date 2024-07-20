module {

    public type ImageFile = {
        format : ImageFormat;
        data : Blob;
    };

    public type ImageFormat = {
        #jpg;
        #png;
        #webp;
    };
};
