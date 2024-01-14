import { IDL } from "@dfinity/candid";

export type Nat32 = number;
export type Int = number;
export type Text = string;

export type PlayerId = Nat32;


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

export const positionToString = (position: FieldPosition): string => {
    if ("pitcher" in position) {
        return "Pitcher";
    } else if ("firstBase" in position) {
        return "1st Base";
    } else if ("secondBase" in position) {
        return "2nd Base";
    } else if ("thirdBase" in position) {
        return "3rd Base";
    } else if ("shortStop" in position) {
        return "Short Stop";
    } else if ("leftField" in position) {
        return "Left Field";
    } else if ("centerField" in position) {
        return "Center Field";
    } else if ("rightField" in position) {
        return "Right Field";
    }
    return "Unknown";
};

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

