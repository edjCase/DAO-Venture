import IcWebSocketCdk "mo:ic-websocket-cdk";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Stadium "../Stadium";

module {
    public type LiveStreamActor = actor {
        broadcast : (LiveStreamMessage) -> ();
        add_stadium : (Principal) -> ();
        on_message : (IcWebSocketCdk.OnMessageCallbackArgs) -> ();
        on_open : (IcWebSocketCdk.OnOpenCallbackArgs) -> ();
        on_close : (IcWebSocketCdk.OnCloseCallbackArgs) -> ();
    };

    public type AddStadiumResult = {
        #ok;
        #notAuthorized;
    };

    public type StadiumId = Principal;
    public type Context<T> = {
        ws_state : IcWebSocketCdk.IcWebSocketState;
        stadiumIds : Trie.Trie<StadiumId, ()>;
        caller : Principal;
        var clientIds : Trie.Trie<Principal, ()>;
        msg : T;
    };

    public type SubscribeRequest = {
        #subscribe;
        #unsubscribe;
    };

    public type LiveStreamMessage = Stadium.LiveStreamMessage;

    public func broadcast(context : Context<LiveStreamMessage>) : async* () {
        let key = {
            key = context.caller;
            hash = Principal.hash(context.caller);
        };
        let stadiumId = switch (Trie.get(context.stadiumIds, key, Principal.equal)) {
            case (null) return (); // TODO not authorized
            case (?s) s;
        };
        let serializedMsg = to_candid ({
            stadiumId = stadiumId;
            msg = context.msg;
        });

        let clientIdIter : Iter.Iter<Principal> = Trie.iter(context.clientIds)
        |> Iter.map(_, func(x : (Principal, ())) : Principal = x.0);
        for (clientId in clientIdIter) {
            try {
                ignore IcWebSocketCdk.ws_send(context.ws_state, clientId, serializedMsg);
            } catch (err) {
                // TODO error handling
                let clientKey = {
                    key = clientId;
                    hash = Principal.hash(clientId);
                };
                let (newClientIds, _) = Trie.remove(context.clientIds, clientKey, Principal.equal);
                context.clientIds := newClientIds;
            };
        };
    };

    public func on_message(context : Context<IcWebSocketCdk.OnMessageCallbackArgs>) : async* () {
        let ?message : ?SubscribeRequest = from_candid (context.msg.message) else return (); // TODO error handling
        let clientKey = {
            key = context.msg.client_principal;
            hash = Principal.hash(context.msg.client_principal);
        };
        let (newClientIds, _) = switch (message) {
            case (#subscribe) Trie.put(context.clientIds, clientKey, Principal.equal, ());
            case (#unsubscribe) Trie.remove(context.clientIds, clientKey, Principal.equal);
        };
        context.clientIds := newClientIds;
    };

    public func on_open(context : Context<IcWebSocketCdk.OnOpenCallbackArgs>) : async* () {
        Debug.print("Client connected: " # debug_show (context.msg.client_principal));
    };

    public func on_close(context : Context<IcWebSocketCdk.OnCloseCallbackArgs>) : async* () {
        Debug.print("Client disconnected: " # debug_show (context.msg.client_principal));
    };

};
