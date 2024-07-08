import Buffer "mo:base/Buffer";
module {

    public func arrayGetSafe<T>(array : [T], index : Nat) : ?T {
        if (index >= array.size()) {
            null;
        } else {
            ?array[index];
        };
    };

    public func arrayUpdateElementSafe<T>(array : [T], index : Nat, value : T) : ?[T] {
        if (index >= array.size()) {
            null;
        } else {
            ?arrayUpdateElement(array, index, value);
        };
    };

    public func arrayUpdateElement<T>(array : [T], index : Nat, value : T) : [T] {
        let newArray = Buffer.fromArray<T>(array);
        newArray.put(index, value);
        Buffer.toArray(newArray);
    };

};
