import { IDL } from "@dfinity/candid";

export type Nat32 = number;
export type Int = number;
export type Text = string;
export type Nat = bigint;

export type PlayerId = Nat32;


export type PlayerSkills = {
    battingAccuracy: Int;
    battingPower: Int;
    throwingAccuracy: Int;
    throwingPower: Int;
    catching: Int;
    defense: Int;
    speed: Int;
};
export const PlayerSkillsIdl = IDL.Record({
    battingAccuracy: IDL.Int,
    battingPower: IDL.Int,
    throwingAccuracy: IDL.Int,
    throwingPower: IDL.Int,
    catching: IDL.Int,
    defense: IDL.Int,
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

export type TeamPositions = {
    firstBase: PlayerId;
    secondBase: PlayerId;
    thirdBase: PlayerId;
    shortStop: PlayerId;
    pitcher: PlayerId;
    leftField: PlayerId;
    centerField: PlayerId;
    rightField: PlayerId;
};
export const TeamPositionsIdl = IDL.Record({
    firstBase: IDL.Nat32,
    secondBase: IDL.Nat32,
    thirdBase: IDL.Nat32,
    shortStop: IDL.Nat32,
    pitcher: IDL.Nat32,
    leftField: IDL.Nat32,
    centerField: IDL.Nat32,
    rightField: IDL.Nat32,
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


export type PlayerMatchStats = {
    battingStats: {
        atBats: Nat;
        hits: Nat;
        strikeouts: Nat;
        runs: Nat;
        homeRuns: Nat;
    };
    catchingStats: {
        successfulCatches: Nat;
        missedCatches: Nat;
        throws: Nat;
        throwOuts: Nat;
    };
    pitchingStats: {
        pitches: Nat;
        strikes: Nat;
        hits: Nat;
        strikeouts: Nat;
        runs: Nat;
        homeRuns: Nat;
    };
    injuries: Nat;
};

export const PlayerMatchStatsIdl = IDL.Record({
    battingStats: IDL.Record({
        atBats: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    catchingStats: IDL.Record({
        successfulCatches: IDL.Nat,
        missedCatches: IDL.Nat,
        throws: IDL.Nat,
        throwOuts: IDL.Nat,
    }),
    pitchingStats: IDL.Record({
        pitches: IDL.Nat,
        strikes: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    injuries: IDL.Nat,
});

export type PlayerMatchStatsWithId = PlayerMatchStats & {
    playerId: PlayerId;
};
export const PlayerMatchStatsWithIdIdl = IDL.Record({
    playerId: IDL.Nat32,
    battingStats: IDL.Record({
        atBats: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    catchingStats: IDL.Record({
        successfulCatches: IDL.Nat,
        missedCatches: IDL.Nat,
        throws: IDL.Nat,
        throwOuts: IDL.Nat,
    }),
    pitchingStats: IDL.Record({
        pitches: IDL.Nat,
        strikes: IDL.Nat,
        hits: IDL.Nat,
        strikeouts: IDL.Nat,
        runs: IDL.Nat,
        homeRuns: IDL.Nat,
    }),
    injuries: IDL.Nat,
});

