module {
    public type PagedResult<T> = {
        data : [T];
        offset : Nat;
        count : Nat;
        // isNext : Bool; // TODO
        // totalItems : ?Nat;
    };
};
