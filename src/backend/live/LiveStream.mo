import IcWebSocketCdk "mo:ic-websocket-cdk";
import Logger "mo:ic-websocket-cdk/Logger";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Stadium "../Stadium";

module {
    public type LiveStreamHubActor = actor {
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
        clientIds : Trie.Trie<Principal, ()>;
        msg : T;
    };

    public type SubscribeRequest = {
        #subscribe;
        #unsubscribe;
    };

    public type BroadcastResult = {
        #ok : { failedClients : [Principal] };
        #notAuthorized;
    };

    public type LiveStreamMessage = Stadium.LiveStreamMessage;

    public func broadcast(context : Context<LiveStreamMessage>) : async* BroadcastResult {
        let key = {
            key = context.caller;
            hash = Principal.hash(context.caller);
        };
        let stadiumId = switch (Trie.get(context.stadiumIds, key, Principal.equal)) {
            case (null) return #notAuthorized; // TODO not authorized
            case (?()) context.caller;
        };
        let serializedMsg = to_candid ({
            matchId = context.msg.matchId;
            stadiumId = stadiumId;
            state = context.msg.state;
        });
        let clientIds : [Principal] = Trie.iter(context.clientIds)
        |> Iter.map(_, func(x : (Principal, ())) : Principal = x.0)
        |> Iter.toArray(_);
        let failedClients = Buffer.Buffer<Principal>(0);
        for (clientId in Iter.fromArray(clientIds)) {
            try {
                let result = await IcWebSocketCdk.ws_send(context.ws_state, clientId, serializedMsg);
                switch (result) {
                    case (#Err(e)) {
                        Debug.print("Failed to send message to client: " # debug_show (clientId) # " with error: " # debug_show (e));
                        failedClients.add(clientId);
                    };
                    case (#Ok) {};
                };
            } catch (err) {
                Debug.print("Error sending message to client: " # Error.message(err));
                failedClients.add(clientId);
            };
        };
        let failedClientsArray = if (failedClients.size() == 0) {
            [];
        } else {
            Buffer.toArray(failedClients);
        };
        #ok({ failedClients = failedClientsArray });
    };

};
