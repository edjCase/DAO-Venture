import type { Principal } from "@dfinity/principal";
import type { FieldPosition } from "./FieldPosition";

export interface Player {
    'id': number,
    'name': string,
    'teamId': [] | [Principal],
    'position': FieldPosition
}