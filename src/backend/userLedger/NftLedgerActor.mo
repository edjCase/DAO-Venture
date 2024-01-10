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
import Types "Types";

shared (_init_msg) actor class NftLedgerActor(_args : InitArgs) : Types.NftLedgerActor = this {

    private let ledger : NftLedger.NftLedger = NftLedger.NftLedger(_args, init_msg);

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

    public query func icrc30_max_approvals_per_token_or_collection() : async ?Nat {
        return ?icrc30().get_ledger_info().max_approvals_per_token_or_collection;
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

    public query func icrc30_max_revoke_approvals() : async ?Nat {
        return ?icrc30().get_ledger_info().max_revoke_approvals;
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

    public query func icrc30_metadata() : async { metadata : [(Text, Value)] } {

        let ledger_info30 = icrc30().get_ledger_info();
        let results = Vec.new<(Text, Value)>();

        Vec.add(results, ("max_approvals_per_token_or_collection", #Nat(ledger_info30.max_approvals_per_token_or_collection)));

        Vec.add(results, ("icrc7:name", #Nat(ledger_info30.max_revoke_approvals)));

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

    public query func icrc30_is_approved(spender : Account, from_subaccount : ?Blob, token_id : Nat) : async Bool {
        return icrc30().is_approved(spender, from_subaccount, token_id);
    };

    public query func icrc30_get_approvals(token_ids : [Nat], prev : ?TokenApproval, take : ?Nat) : async [TokenApproval] {

        return icrc30().get_token_approvals(token_ids, prev, take);
    };

    public query func icrc30_get_collection_approvals(owner : Account, prev : ?CollectionApproval, take : ?Nat) : async [CollectionApproval] {

        return icrc30().get_collection_approvals(owner, prev, take);
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

    public shared (msg) func icrc30_approve(token_ids : [Nat], approval : ApprovalInfo) : async ApprovalResponse {

        switch (icrc30().approve_transfers(msg.caller, token_ids, approval)) {
            case (#ok(val)) val;
            case (#err(err)) D.trap(err);
        };
    };

    public shared (msg) func icrc30_approve_collection(approval : ApprovalInfo) : async ApprovalCollectionResponse {
        icrc30().approve_collection(msg.caller, approval);
    };

    public shared (msg) func icrc7_transfer(args : TransferArgs) : async TransferResponse {
        icrc7().transfer(msg.caller, args);
    };

    public shared (msg) func icrc30_transfer_from(args : TransferFromArgs) : async TransferFromResponse {
        icrc30().transfer_from(msg.caller, args);
    };

    public shared (msg) func icrc30_revoke_token_approvals(args : RevokeTokensArgs) : async RevokeTokensResponse {
        icrc30().revoke_token_approvals(msg.caller, args);
    };

    public shared (msg) func icrc30_revoke_collection_approvals(args : RevokeCollectionArgs) : async RevokeCollectionResponse {
        icrc30().revoke_collection_approvals(msg.caller, args);
    };

    /////////
    // ICRC3 endpoints
    /////////

    public query func icrc3_get_blocks(args : [ICRC3.TransactionRange]) : async ICRC3.GetTransactionsResult {
        return icrc3().get_blocks(args);
    };

    public query func icrc3_get_archives(args : ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult {
        return icrc3().get_archives(args);
    };

    public query func icrc3_get_tip_certificate() : async ?ICRC3.DataCertificate {
        return icrc3().get_tip_certificate();
    };

    public query func get_tip() : async ICRC3.Tip {
        return icrc3().get_tip();
    };

};
