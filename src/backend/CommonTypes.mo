module {
    public type PagedResult<T> = {
        data : [T];
        offset : Nat;
        count : Nat;
        totalCount : Nat;
    };
};
