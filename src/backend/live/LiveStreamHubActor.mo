import IcWebSocketCdk "mo:ic-websocket-cdk";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import LiveStream "LiveStream";

actor {
    // Paste here the principal of the gateway obtained when running the gateway
    //  let gateway_principal : Text = "3656s-3kqlj-dkm5d-oputg-ymybu-4gnuq-7aojd-w2fzw-5lfp2-4zhx3-4ae";

    let gateway_principal_text : Text = "jkhgq-q7bza-ztzvn-swx6g-dgkdp-24g7z-54mt2-2edmj-7j4n7-x7qnj-oqe";
    let gateway_principal = Principal.fromText(gateway_principal_text);

    var ws_state = IcWebSocketCdk.IcWebSocketState(gateway_principal_text);

    var clientIds = Trie.empty<Principal, ()>();
    var stadiumIds = Trie.empty<Principal, ()>();

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

    public shared ({ caller }) func broadcast(msg : LiveStream.LiveStreamMessage) : async () {
        await* LiveStream.broadcast({
            caller = caller;
            var clientIds = clientIds;
            stadiumIds;
            ws_state;
            msg = msg;
        });
    };

    func on_open(args : IcWebSocketCdk.OnOpenCallbackArgs) : async () {
        await* LiveStream.on_open({
            caller = gateway_principal;
            var clientIds = clientIds;
            stadiumIds;
            ws_state;
            msg = args;
        });
    };

    /// The custom logic is just a ping-pong message exchange between frontend and canister.
    /// Note that the message from the WebSocket is serialized in CBOR, so we have to deserialize it first

    func on_message(args : IcWebSocketCdk.OnMessageCallbackArgs) : async () {
        await* LiveStream.on_message({
            caller = gateway_principal;
            var clientIds = clientIds;
            stadiumIds;
            ws_state;
            msg = args;
        });
    };

    func on_close(args : IcWebSocketCdk.OnCloseCallbackArgs) : async () {
        await* LiveStream.on_close({
            caller = gateway_principal;
            var clientIds = clientIds;
            stadiumIds;
            ws_state;
            msg = args;
        });
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
