// import { IDL, } from "@dfinity/candid";
// import IcWebSocket, { generateRandomIdentity } from "ic-websocket-js";
// import type { Principal } from "@dfinity/principal";
// import { type StartedMatchState, StartedMatchStateIdl } from "./Stadium";

// let gatewayUrl;
// let icUrl;
// if (process.env.DFX_NETWORK === "ic") {
//     gatewayUrl = "wss://gateway.icws.io";
//     icUrl = "https://icp0.io";
// } else {
//     gatewayUrl = "ws://127.0.0.1:8080";
//     icUrl = "http://127.0.0.1:4943";
// }

// const backendCanisterId = process.env.CANISTER_ID_LIVE_STREAM_HUB || "";


// export type LiveStreamMessage = {
//     matchId: number;
//     stadiumId: Principal;
//     state: StartedMatchState;
// };
// export const LiveStreamMessageIdl = IDL.Record({
//     'matchId': IDL.Nat32,
//     'stadiumId': IDL.Principal,
//     'state': StartedMatchStateIdl
// });


// export function subscribe(callback: (LiveStreamMessage) => void): { close: () => void } {
//     let ws = new IcWebSocket(gatewayUrl, undefined, {
//         canisterId: backendCanisterId,
//         identity: generateRandomIdentity(),
//         networkUrl: icUrl,
//     });
//     let initMessageBytes = new Uint8Array(); // TODO? 
//     ws.send(initMessageBytes);
//     ws.onopen = () => {
//         console.log("WebSocket state:", ws.readyState, "is open:", ws.readyState === ws.OPEN);

//     };

//     ws.onmessage = (event) => {
//         console.log("Received message:", event);
//         let message = IDL.decode([LiveStreamMessageIdl], event.data)[0] as unknown as LiveStreamMessage;
//         callback(message);
//     };

//     ws.onclose = () => {
//         console.log("WebSocket state:", ws.readyState, "is open:", ws.readyState === ws.OPEN);
//     };

//     ws.onerror = (event) => {
//         console.log("WebSocket error observed:", event);
//     };
//     return {
//         close: ws.close
//     };
// }

export function subscribe(callback: (LiveStreamMessage) => void): { close: () => void } {
    return {
        close: () => { }
    };
}