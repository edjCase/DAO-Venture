import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import D "mo:base/Debug";
import Vec "mo:base/Vec";

import ICRC7 "mo:icrc7-mo";

shared (_init_msg) actor class Example(
    _args : {
        icrc7_args : ?ICRC7.InitArgs;
    }
) = this {

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

    stable var init_msg = _init_msg; //preserves original initialization;

    stable var icrc7_migration_state = ICRC7.init(
        ICRC7.initialState(),
        #v0_1_0(#id),
        switch (_args.icrc7_args) {
            case (null) {
                ?{
                    symbol = ?"NBL";
                    name = ?"NASA Nebulas";
                    description = ?"A Collection of Nebulas Captured by NASA";
                    logo = ?"https://www.nasa.gov/wp-content/themes/nasa/assets/images/nasa-logo.svg";
                    supply_cap = null;
                    allow_transfers = null;
                    max_query_batch_size = ?100;
                    max_update_batch_size = ?100;
                    default_take_value = ?1000;
                    max_take_value = ?10000;
                    max_memo_size = ?512;
                    permitted_drift = null;
                    burn_account = null; //burned nfts are deleted
                    deployer = init_msg.caller;
                    supported_standards = null;
                } : ICRC7.InitArgs;
            };
            case (?val) val;
        },
        init_msg.caller,
    );

    let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state;

    private var _icrc7 : ?ICRC7.ICRC7 = null;

    private func get_icrc7_state() : ICRC7.CurrentState {
        return icrc7_state_current;
    };

    private func updated_certification(cert : Blob, lastIndex : Nat) : Bool {

        D.print("updating the certification " # debug_show (CertifiedData.getCertificate(), ct.treeHash()));
        ct.setCertifiedData();
        D.print("did the certification " # debug_show (CertifiedData.getCertificate()));
        return true;
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

    public query func icrc7_symbol() : async Text {

        return switch (icrc7().get_ledger_info().symbol) {
            case (?val) val;
            case (null) "";
        };
    };

    public query func icrc7_name() : async Text {
        return switch (icrc7().get_ledger_info().name) {
            case (?val) val;
            case (null) "";
        };
    };

    public query func icrc7_description() : async ?Text {
        return icrc7().get_ledger_info().description;
    };

    public query func icrc7_logo() : async ?Text {
        return icrc7().get_ledger_info().logo;
    };

    public query func icrc7_max_memo_size() : async ?Nat {
        return ?icrc7().get_ledger_info().max_memo_size;
    };

    public query func icrc7_total_supply() : async Nat {
        return icrc7().get_stats().nft_count;
    };

    public query func icrc7_supply_cap() : async ?Nat {
        return icrc7().get_ledger_info().supply_cap;
    };

    public query func icrc7_max_query_batch_size() : async ?Nat {
        return ?icrc7().get_ledger_info().max_query_batch_size;
    };

    public query func icrc7_max_update_batch_size() : async ?Nat {
        return ?icrc7().get_ledger_info().max_update_batch_size;
    };

    public query func icrc7_default_take_value() : async ?Nat {
        return ?icrc7().get_ledger_info().default_take_value;
    };

    public query func icrc7_max_take_value() : async ?Nat {
        return ?icrc7().get_ledger_info().max_take_value;
    };

    public query func icrc7_collection_metadata() : async {
        metadata : [(Text, Value)];
    } {

        let ledger_info = icrc7().get_ledger_info();
        let ledger_info30 = icrc30().get_ledger_info();
        let results = Vec.new<(Text, Value)>();

        switch (ledger_info.symbol) {
            case (?val) Vec.add(results, ("icrc7:symbol", #Text(val)));
            case (null) {};
        };

        switch (ledger_info.name) {
            case (?val) Vec.add(results, ("icrc7:name", #Text(val)));
            case (null) {};
        };

        switch (ledger_info.description) {
            case (?val) Vec.add(results, ("icrc7:description", #Text(val)));
            case (null) {};
        };

        switch (ledger_info.logo) {
            case (?val) Vec.add(results, ("icrc7:logo", #Text(val)));
            case (null) {};
        };

        Vec.add(results, ("icrc7:total_supply", #Nat(icrc7().get_stats().nft_count)));

        switch (ledger_info.supply_cap) {
            case (?val) Vec.add(results, ("icrc7:supply_cap", #Nat(val)));
            case (null) {};
        };

        Vec.add(results, ("icrc30:max_approvals_per_token_or_collection", #Nat(ledger_info30.max_approvals_per_token_or_collection)));
        Vec.add(results, ("icrc7:max_query_batch_size", #Nat(ledger_info.max_query_batch_size)));
        Vec.add(results, ("icrc7:max_update_batch_size", #Nat(ledger_info.max_update_batch_size)));
        Vec.add(results, ("icrc7:default_take_value", #Nat(ledger_info.default_take_value)));
        Vec.add(results, ("icrc7:max_take_value", #Nat(ledger_info.max_take_value)));
        Vec.add(results, ("icrc30:max_revoke_approvals", #Nat(ledger_info30.max_revoke_approvals)));

        return {
            metadata = Vec.toArray(results);
        };
    };

    public query func icrc7_token_metadata(token_ids : [Nat]) : async [{
        token_id : Nat;
        metadata : [(Text, Value)];
    }] {
        return icrc7().token_metadata(token_ids);
    };

    public query func icrc7_owner_of(token_ids : [Nat]) : async OwnerOfResponses {

        switch (icrc7().get_token_owners(token_ids)) {
            case (#ok(val)) val;
            case (#err(err)) D.trap(err);
        };
    };

    public query func icrc7_balance_of(account : Account) : async Nat {
        return icrc7().get_token_owners_tokens_count(account);
    };

    public query func icrc7_tokens(prev : ?Nat, take : ?Nat) : async [Nat] {
        return icrc7().get_tokens_paginated(prev, take);
    };

    public query func icrc7_tokens_of(account : Account, prev : ?Nat, take : ?Nat) : async [Nat] {
        return icrc7().get_tokens_of_paginated(account, prev, take);
    };

    public query func icrc7_supported_standards() : async ICRC7.SupportedStandards {
        //todo: figure this out
        return [
            {
                name = "ICRC-7";
                url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-7";
            },
            {
                name = "ICRC-30";
                url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-30";
            },
        ];
    };

    //Update calls

    public shared (msg) func icrc7_transfer(args : TransferArgs) : async TransferResponse {
        icrc7().transfer(msg.caller, args);
    };

};
