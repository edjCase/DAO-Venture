import Array "mo:base/Array";
import Vec "mo:vector";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import D "mo:base/Debug";
import CertifiedData "mo:base/CertifiedData";
import CertTree "mo:cert/CertTree";
import ICRC7 "mo:icrc7-mo";
import ICRC30 "mo:icrc30-mo";
import ICRC3 "mo:icrc3-mo";

module NftLedger {

    type Account = ICRC7.Account;
    type Environment = ICRC7.Environment;
    type Value = ICRC7.Value;
    type NFT = ICRC7.NFT;
    type NFTShared = ICRC7.NFTShared;
    type NFTMap = ICRC7.NFTMap;
    type OwnerOfResponse = ICRC7.OwnerOfResponse;
    type OwnerOfResponses = ICRC7.OwnerOfResponses;
    type TransferArgs = ICRC7.TransferArgs;
    type TransferResponse = ICRC7.TransferResponse;
    type TransferError = ICRC7.TransferArgs;
    type TokenApproval = ICRC30.TokenApproval;
    type CollectionApproval = ICRC30.CollectionApproval;
    type ApprovalInfo = ICRC30.ApprovalInfo;
    type ApprovalResponse = ICRC30.ApprovalResponse;
    type ApprovalResult = ICRC30.ApprovalResult;
    type ApprovalCollectionResponse = ICRC30.ApprovalCollectionResponse;
    type RevokeTokensArgs = ICRC30.RevokeTokensArgs;
    type RevokeTokensResponseItem = ICRC30.RevokeTokensResponseItem;
    type RevokeCollectionArgs = ICRC30.RevokeCollectionArgs;
    type RevokeCollectionResponseItem = ICRC30.RevokeCollectionResponseItem;
    type TransferFromArgs = ICRC30.TransferFromArgs;
    type TransferFromResponse = ICRC30.TransferFromResponse;
    type RevokeTokensResponse = ICRC30.RevokeTokensResponse;
    type RevokeCollectionResponse = ICRC30.RevokeCollectionResponse;

    public type InitArgs = {
        icrc7_args : ICRC7.InitArgs;
        icrc30_args : ICRC30.InitArgs;
        icrc3_args : ICRC3.InitArgs;
    };

    public type InitMsg = {
        caller : Principal;
    };

    public class NftLedger(_init_msg : InitMsg, _args : InitArgs) {
        var init_msg = _init_msg; // TODO stable

        stable var icrc7_migration_state = ICRC7.init(
            ICRC7.initialState(),
            #v0_1_0(#id),
            _args.icrc7_args,
            init_msg.caller,
        );

        let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state;

        var icrc30_migration_state = ICRC30.init(
            ICRC30.initialState(),
            #v0_1_0(#id),
            _args.icrc30_args,
            init_msg.caller,
        ); // TODO stable

        let #v0_1_0(#data(icrc30_state_current)) = icrc30_migration_state;

        private var _icrc7 : ?ICRC7.ICRC7 = null;
        private var _icrc30 : ?ICRC30.ICRC30 = null;

        private func get_icrc7_state() : ICRC7.CurrentState {
            return icrc7_state_current;
        };

        private func get_icrc30_state() : ICRC30.CurrentState {
            return icrc30_state_current;
        };

        stable var icrc3_migration_state = ICRC3.init(
            ICRC3.initialState(),
            #v0_1_0(#id),
            _args.icrc3_args,
            init_msg.caller,
        );

        let #v0_1_0(#data(icrc3_state_current)) = icrc3_migration_state;

        private var _icrc3 : ?ICRC3.ICRC3 = null;

        private func get_icrc3_state() : ICRC3.CurrentState {
            return icrc3_state_current;
        };

        stable let cert_store : CertTree.Store = CertTree.newStore();
        let ct = CertTree.Ops(cert_store);

        private func get_certificate_store() : CertTree.Store {
            D.print("returning cert store " # debug_show (cert_store));
            return cert_store;
        };

        private func updated_certification(cert : Blob, lastIndex : Nat) : Bool {

            D.print("updating the certification " # debug_show (CertifiedData.getCertificate(), ct.treeHash()));
            ct.setCertifiedData();
            D.print("did the certification " # debug_show (CertifiedData.getCertificate()));
            return true;
        };

        private func get_icrc3_environment() : ICRC3.Environment {
            ?{
                updated_certification = ?updated_certification;
                get_certificate_store = ?get_certificate_store;
            };
        };

        func icrc3() : ICRC3.ICRC3 {
            switch (_icrc3) {
                case (null) {
                    let initclass : ICRC3.ICRC3 = ICRC3.ICRC3(?icrc3_migration_state, Principal.fromActor(this), get_icrc3_environment());
                    _icrc3 := ?initclass;
                    initclass;
                };
                case (?val) val;
            };
        };

        private func get_icrc7_environment() : ICRC7.Environment {
            {
                canister = get_canister;
                get_time = get_time;
                refresh_state = get_icrc7_state;
                add_ledger_transaction = ?icrc3().add_record;
                can_mint = null;
                can_burn = null;
                can_transfer = null;
            };
        };

        private func get_icrc30_environment() : ICRC30.Environment {
            {
                canister = get_canister;
                get_time = get_time;
                refresh_state = get_icrc30_state;
                icrc7 = icrc7();
                can_transfer_from = null;
                can_approve_token = null;
                can_approve_collection = null;
                can_revoke_token_approval = null;
                can_revoke_collection_approval = null;
            };
        };

        func icrc7() : ICRC7.ICRC7 {
            switch (_icrc7) {
                case (null) {
                    let initclass : ICRC7.ICRC7 = ICRC7.ICRC7(?icrc7_migration_state, Principal.fromActor(this), get_icrc7_environment());
                    _icrc7 := ?initclass;
                    initclass;
                };
                case (?val) val;
            };
        };

        func icrc30() : ICRC30.ICRC30 {
            switch (_icrc30) {
                case (null) {
                    let initclass : ICRC30.ICRC30 = ICRC30.ICRC30(?icrc30_migration_state, Principal.fromActor(this), get_icrc30_environment());
                    _icrc30 := ?initclass;
                    initclass;
                };
                case (?val) val;
            };
        };

        //we will use a stable log for this example, but encourage the use of ICRC3 in a full implementation.  see https://github.com/panindustrial/FullNFT.mo

        stable var trx_log = Vec.new<ICRC7.Value>();

        func add_trx(entry : Value, entrytop : ?Value) : Nat {
            let trx = Vec.new<(Text, Value)>();

            Vec.add(trx, ("tx", entry));

            switch (entrytop) {
                case (?top_level) {
                    switch (top_level) {
                        case (#Map(items)) {
                            for (thisItem in items.vals()) {
                                Vec.add(trx, (thisItem.0, thisItem.1));
                            };
                        };
                        case (_) {};
                    };
                };
                case (null) {};
            };

            let thisTrx = #Map(Vec.toArray(trx));
            Vec.add(trx_log, thisTrx);
            return (Vec.size(trx_log) - 1);
        };

        private var canister_principal : ?Principal = null;

        private func get_canister() : Principal {
            switch (canister_principal) {
                case (null) {
                    canister_principal := ?Principal.fromActor(this);
                    Principal.fromActor(this);
                };
                case (?val) {
                    val;
                };
            };
        };

        private func get_time() : Int {
            //note: you may want to implement a testing framework where you can set this time manually
            /* switch(state_current.testing.time_mode){
          case(#test){
              state_current.testing.test_time;
          };
          case(#standard){
               Time.now();
          };
      }; */
            Time.now();
        };
    };
};
