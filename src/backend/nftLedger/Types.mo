import ICRC7 "mo:icrc7-mo";
import ICRC30 "mo:icrc30-mo";
import ICRC3 "mo:icrc3-mo";

module {
    public type NftLedgerActor = ICRC3.Service and ICRC7.Service and ICRC30.Service and actor {

    };

    public type NftLedgerActorInfo = {

    };

    public type NftLedgerActorInfoWithId = NftLedgerActorInfo and {
        id : Text;
    };
};
