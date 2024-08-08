module {

    public type StableData = {
        choices : [Choice];
    };

    public type Choice = {
        day : Nat;
    };

    public class Handler<system>(
        data : StableData
    ) {

        public func start() {

        };

    };
};
