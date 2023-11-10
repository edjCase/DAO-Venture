import type { Principal } from "@dfinity/principal";
import type { FieldPosition } from "./FieldPosition";
import { Deity } from "./Deity";
import { PlayerSkills } from "../ic-agent/PlayerLedger";

export interface Player {
    'id': number,
    'name': string,
    'teamId': [] | [Principal],
    'position': FieldPosition
    'deity': Deity,
    'skills': PlayerSkills
}