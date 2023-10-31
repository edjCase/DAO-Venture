import IcWebSocketCdk "mo:ic-websocket-cdk";
import Logger "mo:ic-websocket-cdk/Logger";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import LiveStream "LiveStream";

actor {
    // Paste here the principal of the gateway obtained when running the gateway
    let gateway_principal_text : Text = "lguro-akdab-ztueq-gj5sg-3rx63-dmgdc-bi6f3-aai7k-bm6d5-m53eh-5qe";
    let gateway_principal = Principal.fromText(gateway_principal_text);

    var ws_state = IcWebSocketCdk.IcWebSocketState(gateway_principal_text);

    var clientIds = Trie.empty<Principal, ()>();
    stable var stadiumIds = Trie.empty<Principal, ()>();

    public shared ({ caller }) func add_stadium(stadiumId : Principal) : async LiveStream.AddStadiumResult {
        // TODO
        // if (caller != leagueId) {
        //     return #notAuthorized;
        // };
        let stadiumKey = {
            key = stadiumId;
            hash = Principal.hash(stadiumId);
        };
        let (newStadiumIds, _) = Trie.put(stadiumIds, stadiumKey, Principal.equal, ());
        stadiumIds := newStadiumIds;
        #ok;
    };

    public shared ({ caller }) func broadcast(msg : LiveStream.LiveStreamMessage) : async {
        #ok;
        #notAuthorized;
    } {
        let result = await* LiveStream.broadcast({
            caller = caller;
            clientIds = clientIds;
            stadiumIds;
            ws_state;
            msg = msg;
        });
        switch (result) {
            case (#ok({ failedClients })) {
                for (clientId in Iter.fromArray(failedClients)) {
                    removeClient(clientId);
                };
                #ok;
            };
            case (#notAuthorized) #notAuthorized;
        };
    };

    func on_open(args : IcWebSocketCdk.OnOpenCallbackArgs) : async () {
        addClient(args.client_principal);
    };

    func on_message(args : IcWebSocketCdk.OnMessageCallbackArgs) : async () {};

    func on_close(args : IcWebSocketCdk.OnCloseCallbackArgs) : async () {
        removeClient(args.client_principal);
    };

    private func addClient(clientId : Principal) : () {
        Logger.custom_print("Client added: " # Principal.toText(clientId));
        let clientKey = {
            key = clientId;
            hash = Principal.hash(clientId);
        };
        let (newClientIds, _) = Trie.put(clientIds, clientKey, Principal.equal, ());
        clientIds := newClientIds;
    };

    private func removeClient(clientId : Principal) : () {
        Logger.custom_print("Client removed: " # Principal.toText(clientId));
        let clientKey = {
            key = clientId;
            hash = Principal.hash(clientId);
        };
        let (newClientIds, _) = Trie.remove(clientIds, clientKey, Principal.equal);
        clientIds := newClientIds;
    };

    let handlers = IcWebSocketCdk.WsHandlers(
        ?on_open,
        ?on_message,
        ?on_close,
    );

    let params = IcWebSocketCdk.WsInitParams(
        handlers,
        null,
        null,
        null,
    );
    var ws = IcWebSocketCdk.IcWebSocket(ws_state, params);

    system func postupgrade() {
        ws_state := IcWebSocketCdk.IcWebSocketState(gateway_principal_text);
        ws := IcWebSocketCdk.IcWebSocket(ws_state, params);
    };

    // method called by the WS Gateway after receiving FirstMessage from the client
    public shared ({ caller }) func ws_open(args : IcWebSocketCdk.CanisterWsOpenArguments) : async IcWebSocketCdk.CanisterWsOpenResult {
        await ws.ws_open(caller, args);
    };

    // method called by the Ws Gateway when closing the IcWebSocket connection
    public shared ({ caller }) func ws_close(args : IcWebSocketCdk.CanisterWsCloseArguments) : async IcWebSocketCdk.CanisterWsCloseResult {
        await ws.ws_close(caller, args);
    };

    // method called by the frontend SDK to send a message to the canister
    public shared ({ caller }) func ws_message(args : IcWebSocketCdk.CanisterWsMessageArguments) : async IcWebSocketCdk.CanisterWsMessageResult {
        await ws.ws_message(caller, args);
    };

    // method called by the WS Gateway to get messages for all the clients it serves
    public shared query ({ caller }) func ws_get_messages(args : IcWebSocketCdk.CanisterWsGetMessagesArguments) : async IcWebSocketCdk.CanisterWsGetMessagesResult {
        ws.ws_get_messages(caller, args);
    };
};
