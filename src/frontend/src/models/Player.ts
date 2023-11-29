import { IDL } from "@dfinity/candid";
import type { Principal } from '@dfinity/principal';

export type Nat32 = number;
export type Int = number;
export type Text = string;

export type PlayerId = Nat32;

export type Deity =
    | { mischief: null }
    | { war: null }
    | { pestilence: null }
    | { indulgence: null };
export const DeityIdl = IDL.Variant({
    mischief: IDL.Null,
    war: IDL.Null,
    pestilence: IDL.Null,
    indulgence: IDL.Null,
});

export type PlayerSkills = {
    battingAccuracy: Int;
    battingPower: Int;
    throwingAccuracy: Int;
    throwingPower: Int;
    catching: Int;
    defense: Int;
    piety: Int;
    speed: Int;
};
export const PlayerSkillsIdl = IDL.Record({
    battingAccuracy: IDL.Int,
    battingPower: IDL.Int,
    throwingAccuracy: IDL.Int,
    throwingPower: IDL.Int,
    catching: IDL.Int,
    defense: IDL.Int,
    piety: IDL.Int,
    speed: IDL.Int,
});

export type FieldPosition =
    | { firstBase: null }
    | { secondBase: null }
    | { thirdBase: null }
    | { shortStop: null }
    | { leftField: null }
    | { centerField: null }
    | { rightField: null }
    | { pitcher: null };
export const FieldPositionIdl = IDL.Variant({
    firstBase: IDL.Null,
    secondBase: IDL.Null,
    thirdBase: IDL.Null,
    shortStop: IDL.Null,
    leftField: IDL.Null,
    centerField: IDL.Null,
    rightField: IDL.Null,
    pitcher: IDL.Null,
});

export type Player = {
    name: Text;
    teamId: Principal | null;
    skills: PlayerSkills;
    position: FieldPosition;
    deity: Deity;
};
export const PlayerIdl = IDL.Record({
    name: IDL.Text,
    teamId: IDL.Opt(IDL.Principal),
    skills: PlayerSkillsIdl,
    position: FieldPositionIdl,
    deity: DeityIdl,
});

export type PlayerWithId = Player & {
    id: Nat32;
};
export const PlayerWithIdIdl = IDL.Record({
    id: IDL.Nat32,
    name: IDL.Text,
    teamId: IDL.Opt(IDL.Principal),
    skills: PlayerSkillsIdl,
    position: FieldPositionIdl,
    deity: DeityIdl,
});

export type Injury =
    | { twistedAnkle: null }
    | { brokenLeg: null }
    | { brokenArm: null }
    | { concussion: null };
export const InjuryIdl = IDL.Variant({
    twistedAnkle: IDL.Null,
    brokenLeg: IDL.Null,
    brokenArm: IDL.Null,
    concussion: IDL.Null,
});

export type PlayerCondition =
    | { ok: null }
    | { injured: Injury }
    | { dead: null };
export const PlayerConditionIdl = IDL.Variant({
    ok: IDL.Null,
    injured: InjuryIdl,
    dead: IDL.Null,
});

